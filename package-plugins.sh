#!/bin/bash

# Produce compressed tar files for each of our example plugins, so that these
# can be distributed to customers. Simply run the script without any parameters,
# and the resulting files should be saved in "./releases".

# Exit immediately if there's an error. We want to be sure that bad builds are
# discovered immediately.

set -e

# Build the sample plugins on the same machines that we use to build mistral.

REMOTE_BUILD_MACHINE_32=ellexus@10.33.0.103
REMOTE_BUILD_MACHINE_64=ellexus@10.33.0.104
REMOTE_BUILD_MACHINE_ARM64=ellexus@10.33.0.110
REMOTE_BUILD_MACHINE_DOCS=ellexus@build-doc


# Cleanup all temporary files on the local machine, and arrange for this to
# happen when the script completes, whether or not it succeeds.

function cleanup() {
    rm -rf ${SOURCE_DIR} ${BUILD_DIR}
}

function finish {
    cleanup
    echo "Package plugins finished."
}
trap finish EXIT

function finish_term {
    cleanup
    echo "Package plugins was terminated."
}
trap finish_term TERM INT

# remote_build machine source result compiled ...
#
# Copy sources to a temporary directory on the remote machine and run "make
# package". The remaining arguments are the compiled files which are copied back
# from the remote machine to the result directory.

remote_build() {
    local machine=$1
    local source=$2
    local result=$3
    local make_command=$4
    shift 4

    echo "Remote build on ${machine}"

    local remote=$(ssh "${machine}" mktemp -d)

    ( tar -cz --directory=${source} ./ | ssh "${machine}" "cd ${remote} && tar -xz && ${make_command}" )

    local compiled
    for compiled in "${@}"; do
        echo "remote_build - getting ${compiled}"
        scp -q "${machine}:${remote}/${compiled}" "${result}"
    done

    ssh "${machine}" "rm -rf ${remote}"
    echo "remote_build - complete"
}

# We will save the resulting tar files in the releases subdirectory. Make sure
# it exists.

mkdir -p ./releases

# Export a copy of the sources to a temporary location. This will include any
# files added but not yet committed to the repository.

SOURCE_DIR=$(mktemp -d)
git checkout-index -a --prefix=${SOURCE_DIR}/

# We will package any plugin which has a PACKAGE file in it. For the moment we
# just use these files to identify directories to be packaged, but later on we
# expect the PACKAGE file to list the files that should be distributed.

# If packages is set to a list of packages, then use that - otherwise package them
# all.
if [ -z "$PACKAGES" ]; then
    PACKAGES=$(find . -name PACKAGE -print)
fi

# Construct lists of the plugins to be built. The plugin takes its name from the
# directory with ".i386" appended for 32-bit builds, ".x86_64" for 64-bit
# builds and ".aarch64" for 64-bit ARM builds.

BUILD32=""
BUILD64=""
BUILD_ARM64=""
for PACKAGE in ${PACKAGES}; do
    PLUGIN_DIRECTORY=$(dirname ${PACKAGE})
    PLUGIN=$(basename ${PLUGIN_DIRECTORY})
    BUILD32="${BUILD32} ${PLUGIN_DIRECTORY}/${PLUGIN}.i386"
    BUILD64="${BUILD64} ${PLUGIN_DIRECTORY}/${PLUGIN}.x86_64"
    BUILD_ARM64="${BUILD_ARM64} ${PLUGIN_DIRECTORY}/${PLUGIN}.aarch64"
done

# Create another temporary directory where we can store the compiled plugins and
# collect together the files to be distributed.

BUILD_DIR=$(mktemp -d)


if [ -z "$MAKE_PACKAGE" ]; then
    MAKE_PACKAGE="package"
fi

# Build both the 32-bit and 64-bit versions of the plugins on the appropriate
# build machines.

ARM64_ARGUMENTS="GCC=aarch64-linux-gnu-gcc TGT_ARCH=aarch64"

remote_build ${REMOTE_BUILD_MACHINE_32} ${SOURCE_DIR} ${BUILD_DIR} "make ${MAKE_PACKAGE}" ${BUILD32}
remote_build ${REMOTE_BUILD_MACHINE_64} ${SOURCE_DIR} ${BUILD_DIR} "make ${MAKE_PACKAGE}" ${BUILD64}
remote_build ${REMOTE_BUILD_MACHINE_ARM64} ${SOURCE_DIR} ${BUILD_DIR} "make ${ARM64_ARGUMENTS} ${MAKE_PACKAGE}" ${BUILD_ARM64}

DOC_DIR="${SOURCE_DIR}/docs"
ALL_DOCS=$(make -s -C "${SOURCE_DIR}/docs" echo-all 2>/dev/null)
remote_build ${REMOTE_BUILD_MACHINE_DOCS} ${DOC_DIR} ${BUILD_DIR} "make pdf" ${ALL_DOCS}

# Iterate over all plugins, collecting up the files and creating tar files which
# can be distributed.

for PACKAGE in ${PACKAGES}; do
    PLUGIN_SRC=$(dirname ${PACKAGE})
    PLUGIN_NAME=$(basename ${PLUGIN_SRC})
    VERSION=$(cat ${PLUGIN_SRC}/VERSION)
    PLUGIN_DST=${BUILD_DIR}/${PLUGIN_NAME}_${VERSION}
    mkdir -p ${PLUGIN_DST}

    # Copy the plugin binaries and any files mentioned in the PACKAGE file to an
    # appropriately named directory, then create a tar file of that directory.

    for binary in ${BUILD_DIR}/${PLUGIN_NAME}.*; do
        arch=${binary#${BUILD_DIR}/${PLUGIN_NAME}.}
        mkdir -p ${PLUGIN_DST}/${arch}
        cp $binary ${PLUGIN_DST}/${arch}/${PLUGIN_NAME}
    done

    tar -c --directory=${PLUGIN_SRC} --files-from=${PACKAGE} | tar -x --directory=${PLUGIN_DST}

    # Add documentation
    cp "${BUILD_DIR}/mistral_plugin_api.pdf" "${PLUGIN_DST}/mistral_plugin_api.pdf"
    if [ -f "${BUILD_DIR}/${PLUGIN_NAME}_plugin_manual.pdf" ]; then
        cp "${BUILD_DIR}/${PLUGIN_NAME}_plugin_manual.pdf" "${PLUGIN_DST}/${PLUGIN_NAME}_plugin_manual.pdf"
    fi

    tar -czf ./releases/${PLUGIN_NAME}_${VERSION}.tar.gz --directory=${BUILD_DIR} $(basename ${PLUGIN_DST})

done
