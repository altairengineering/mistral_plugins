.PHONY: all
all: build-common build-mistral_elasticsearch build-mistral_graphite \
    build-mistral_influxdb build-mistral_mysql build-mistral_rtm \
    build-mistral_splunk build-mistral_fluentbit build-mistral_postgresql

.PHONY: build-common
build-common:
	$(MAKE) -C common

.PHONY: build-mistral_elasticsearch
build-mistral_elasticsearch:
	$(MAKE) -C output/mistral_elasticsearch

.PHONY: build-mistral_fluentbit
build-mistral_fluentbit:
	$(MAKE) -C output/mistral_fluentbit

.PHONY: build-mistral_graphite
build-mistral_graphite:
	$(MAKE) -C output/mistral_graphite

.PHONY: build-mistral_mysql
build-mistral_mysql:
	$(MAKE) -C output/mistral_mysql

.PHONY: build-mistral_influxdb
build-mistral_influxdb:
	$(MAKE) -C output/mistral_influxdb

.PHONY: build-mistral_postgresql
build-mistral_postgresql:
	$(MAKE) -C output/mistral_postgresql

.PHONY: build-mistral_rtm
build-mistral_rtm:
	$(MAKE) -C output/mistral_rtm

.PHONY: build-mistral_splunk
build-mistral_splunk:
	$(MAKE) -C output/mistral_splunk

.PHONY: package-mistral_elasticsearch
package-mistral_elasticsearch:
	$(MAKE) -C common
	$(MAKE) -C output/mistral_elasticsearch package

.PHONY: package
package:
	$(MAKE) -C common
	$(MAKE) -C output/mistral_elasticsearch package
	$(MAKE) -C output/mistral_fluentbit package
	$(MAKE) -C output/mistral_graphite package
	$(MAKE) -C output/mistral_influxdb package
	$(MAKE) -C output/mistral_mysql package
	$(MAKE) -C output/mistral_postgresql package
	$(MAKE) -C output/mistral_rtm package
	$(MAKE) -C output/mistral_splunk package

.PHONY: package-aarch64
package-aarch64:
	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C common
	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C output/mistral_elasticsearch package
	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C output/mistral_fluentbit package
	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C output/mistral_graphite package
	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C output/mistral_influxdb package
	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C output/mistral_splunk package
# Not yet supported on aarch64
#	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C output/mistral_mysql package
#	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C output/mistral_postgresql package
#	$(MAKE) TGT_ARCH=aarch64 GCC=aarch64-linux-gnu-gcc -C output/mistral_rtm package

.PHONY: clean
clean:
	$(MAKE) -C common clean
	$(MAKE) -C output/mistral_elasticsearch clean
	$(MAKE) -C output/mistral_fluentbit clean
	$(MAKE) -C output/mistral_graphite clean
	$(MAKE) -C output/mistral_influxdb clean
	$(MAKE) -C output/mistral_mysql clean
	$(MAKE) -C output/mistral_postgresql clean
	$(MAKE) -C output/mistral_rtm clean
	$(MAKE) -C output/mistral_splunk clean
