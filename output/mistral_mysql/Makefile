# ------------------------------------------------------------------------------
# Set up targets and default required PHONY rules

PLUGIN_NAME = mistral_mysql
INCLUDE_CURL = 0

LDLIBS := \
	$(shell mysql_config --libs) \
	-luuid

INCLUDE_FLAGS := \
	$(shell mysql_config --include)

include ../common.mk
