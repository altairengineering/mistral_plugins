PLUGIN_NAME = mistral_mysql

LDLIBS := $(shell mysql_config --libs) \
	-luuid

INCLUDE_FLAGS := $(shell mysql_config --include)

include ../common.mk
