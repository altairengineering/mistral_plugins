.PHONY: all
all: build-common build-mistral_elasticsearch build-mistral_graphite \
    build-mistral_influxdb build-mistral_mysql build-mistral_rtm

.PHONY: build-common
build-common:
	$(MAKE) -C common

.PHONY: build-mistral_elasticsearch
build-mistral_elasticsearch:
	$(MAKE) -C output/mistral_elasticsearch

.PHONY: build-mistral_graphite
build-mistral_graphite:
	$(MAKE) -C output/mistral_graphite

.PHONY: build-mistral_mysql
build-mistral_mysql:
	$(MAKE) -C output/mistral_mysql

.PHONY: build-mistral_influxdb
build-mistral_influxdb:
	$(MAKE) -C output/mistral_influxdb

.PHONY: build-mistral_rtm
build-mistral_rtm:
	$(MAKE) -C output/mistral_rtm

.PHONY: package
package:
	$(MAKE) -C common
	$(MAKE) -C output/mistral_elasticsearch package
	$(MAKE) -C output/mistral_graphite package
	$(MAKE) -C output/mistral_mysql package
	$(MAKE) -C output/mistral_influxdb package
	$(MAKE) -C output/mistral_rtm package

.PHONY: clean
clean:
	$(MAKE) -C common clean
	$(MAKE) -C output/mistral_elasticsearch clean
	$(MAKE) -C output/mistral_graphite clean
	$(MAKE) -C output/mistral_mysql clean
	$(MAKE) -C output/mistral_influxdb clean
	$(MAKE) -C output/mistral_rtm clean
