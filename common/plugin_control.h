/* Utilities to read and store log messages received from mistral that do not need to be exposed to
 * someone writing a plug-in outside of Ellexus.
 */

#ifndef MISTRAL_PLUGIN_CONTROL_H
#define MISTRAL_PLUGIN_CONTROL_H

#include <stddef.h>             /* size_t */
#include <stdint.h>             /* uint32_t */
#include <stdio.h>              /* FILE */
#include <fcntl.h>              /* open */
#include <sys/time.h>           /* struct timeval */
#include <sys/stat.h>           /* open, umask */
#include <sys/types.h>          /* open, umask */

#include "mistral_plugin.h"     /* Definitions that need to be available to plug-in developers */

/* Version of the API used by the plug-in */
#define MISTRAL_API_VERSION 6

/* Define the number of fields in the plugin message string */
#define PLUGIN_MESSAGE_FIELDS 3

/* Define the separator as a character that is not valid in a contract label */
#define PLUGIN_MESSAGE_SEP_C ':'
#define PLUGIN_MESSAGE_SEP_S ":"
#define PLUGIN_MESSAGE_END PLUGIN_MESSAGE_SEP_S

/* Define the maximum length of a command line in a Mistral log message */
#define PLUGIN_MESSAGE_CMD_LEN 1405

/* Set up message type strings */
#define PLUGIN_MESSAGE(X)                                                   \
    X(USED_VERSION, PLUGIN_MESSAGE_SEP_S "PGNVERSION" PLUGIN_MESSAGE_SEP_S) \
    X(SUP_VERSION, PLUGIN_MESSAGE_SEP_S "PGNSUPVRSN" PLUGIN_MESSAGE_SEP_S)  \
    X(INTERVAL, PLUGIN_MESSAGE_SEP_S "PGNINTRVAL" PLUGIN_MESSAGE_SEP_S)     \
    X(DATA_START, PLUGIN_MESSAGE_SEP_S "PGNDATASRT" PLUGIN_MESSAGE_SEP_S)   \
    X(DATA_LINE, PLUGIN_MESSAGE_SEP_S "PGNDATALIN" PLUGIN_MESSAGE_SEP_S)    \
    X(DATA_END, PLUGIN_MESSAGE_SEP_S "PGNDATAEND" PLUGIN_MESSAGE_SEP_S)     \
    X(SHUTDOWN, PLUGIN_MESSAGE_SEP_S "PGNSHUTDWN" PLUGIN_MESSAGE_END)

enum mistral_message {
    PLUGIN_FATAL_ERR = -2,
    PLUGIN_DATA_ERR = -1,
    #define X(P, V) PLUGIN_MESSAGE_ ## P,
    PLUGIN_MESSAGE(X)
    #undef X
    PLUGIN_MESSAGE_LIMIT
};

#define ARRAY_LENGTH(array) (sizeof(array) / sizeof((array)[0]))

#define CALL_IF_DEFINED(function, ...) \
    if (function) {                    \
        function(__VA_ARGS__);         \
    }

#endif

#define LOG_FIELD(X) \
    X(TIMESTAMP)     \
    X(LABEL)         \
    X(PATH)          \
    X(FSTYPE)        \
    X(FSNAME)        \
    X(FSHOST)        \
    X(CALL_TYPE)     \
    X(SIZE_RANGE)    \
    X(MEASUREMENT)   \
    X(MEASURED)      \
    X(THRESHOLD)     \
    X(HOSTNAME)      \
    X(PID)           \
    X(CPU)           \
    X(COMMAND)       \
    X(FILENAME)      \
    X(JOB_GROUP_ID)  \
    X(JOB_ID)        \
    X(MPI_RANK)      \
    X(SEQUENCE)

enum mistral_log_fields {
    #define X(P) FIELD_ ## P,
    LOG_FIELD(X)
    #undef X
    FIELD_MAX
};

/** Logging code **/

#define LOG_MODULES(X) \
   X(plugin)

#define LOG_LEVELS(X) \
   X(ERROR)           \
   X(WARNING)         \
   X(MAJOR)           \
   X(NOTICE)          \
   X(MINOR)           \
   X(TRIVIAL)         \
   X(DEBUG)

#define LOG(module, level, format, ...)                        \
    ((log_level[LOG_module_ ## module] >= DR_LOG_ ## level) && \
     (mistral_err("LOG (" #module " %d): %s(%d)" format "\n",  \
                     DR_LOG_ ## level, __FILE__, __LINE__, ## __VA_ARGS__), false))

__attribute__((__format__(printf, 3, 4)))
extern void dr_output_log(size_t module, int level, const char * restrict fmt, ...);

#define IF_LOGGING(module, level) \
    do {                          \
        if (log_level[LOG_module_ ## module] >= DR_LOG_ ## level)

#define ENDIF_LOGGING \
    } while(0)

#define LOG_MODULE_ENUM(module) LOG_module_ ## module,
enum {
    LOG_MODULES(LOG_MODULE_ENUM)
    LOG_module_MAX,
};

#define LOG_LEVEL_ENUM(level) DR_LOG_ ## level,
enum log_levels_e {
    LOG_LEVELS(LOG_LEVEL_ENUM)
    DR_LOG_LEVEL_MAX,
};

extern int log_level[LOG_module_MAX];

/** End of Logging **/