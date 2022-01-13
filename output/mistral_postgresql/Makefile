PLUGIN_NAME = mistral_postgresql

LDLIBS := \
	-lpq \
	-luuid

INCLUDE_FLAGS := \
	-I$(shell pg_config --includedir)

include ../common.mk
