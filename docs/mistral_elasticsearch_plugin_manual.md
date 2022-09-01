% Ellexus - Elasticsearch Plug-in Configuration Guide

# Installing the Elasticsearch Plug-in

Extract the Mistral plug-ins archive that has been provided to you
somewhere sensible. Please make sure that you use the appropriate
version of the plug-ins for the architecture of the machine on which the
plug-in will run.

In addition, if the Mistral Plug-ins package was obtained separately
from the main Mistral product, please ensure that the version of the
plug-in downloaded is compatible with the version of Mistral in use.
Version 5.3.2 of the Elasticsearch Plug-in as described in this document
is compatible with all versions of Mistral compatible with plug-in API
version 5. At the time of writing this is Mistral v2.11.2 and above.

The Elasticsearch plug-in can be found in, for example:

    <installation directory>/output/mistral_elasticsearch_v5.4.4/x86_64/

for the 64 bit Intel compatible version, and in:

    <installation directory>/output/mistral_elasticsearch_v5.4.4/aarch32/

for the 32 bit ARM compatible version.

The plug-in must be available in the same location on all execution
hosts in your cluster.

## Installing the Elasticsearch Index Mapping Template

Prior to using the Mistral Elasticsearch plug-in the index datatype
mapping template should be configured within Elasticsearch. The files
mappings\_`<n>`.x.json contains the appropriate configuration for
Elasticsearch installations where `<n>` corresponds to the major version
of Elasticsearch in use.

The provided templates ensure that date fields are correctly identified.
The template for Elasticsearch version 2.x also specifies some key
fields should not be analysed to make working with Grafana simpler.
Other, site specific, configuration can be added at the user’s
discretion.

If you have access to curl the file
mistral\_create\_elastic\_template.sh can be run to create the template
from the command line. This script will attempt to detect the
Elasticsearch version in use and create the template using the
appropriate mapping file.

The script takes the following command line options:

    -?, --help

Display usage instructions

    -i idx_name, --index=idx_name

The basename of the index. If not specified the template will be created
for indexes called mistral. If a custom value is used here a matching
option must be provided to the plug-in.

    -h hostname, --host=hostname

The name of the machine on which Elasticsearch is hosted. If not
specified the script will use localhost.

    -p filename, --password=filename

The name of a file containing the password to be used when creating the
index if needed. The password must be on a single line.

    -P n, --port=n

The port to be used when connecting to Elasticsearch. If not specified
the script will use port 9200.

    -s, --ssl

Use HTTPS protocol instead of HTTP to connect to Elasticsearch.

    -u user, --username=user

The username to be used when connecting to Elasticsearch if needed.

    -d, --date

Use date based index naming. By default the indexes are named 
idx_name-00000N, if you would prefer to use idx_name-YYYY-MM-DD then
specify this option.


# Configuring Mistral to use the Elasticsearch Plug-in

Please see the Plug-in Configuration section of the main Mistral User
Guide for full details of the plug-in configuration specification.
Where these instructions conflict with information in the main Mistral
User Guide please verify that the plug-in version available is
compatible with the version of Mistral in use and, if so, the
information in the User Guide should be assumed to be correct.

## Mistral Plug-in Configuration

The Mistral plug-in configuration is in YAML and goes in the same file
as the main Mistral Configuration File. The plug-in is declared with the
`plugin` mapping and requires at minimum a `path` key-value pair. All of
the specified settings are members of the `plugin` mapping.

    plugin:
        path: plugins/mistral_elasticsearch/x86_64/mistral_elasticsearch

This section describes the specific settings required to enable the
Elasticsearch Plug-in.

### Path

The `path` key must be set to the path of the elasticsearch plguin-in
executable. This must be either absolute or relative to the 
`MISTRAL_INSTALL_DIRECTORY` environment variable and needs to be accessible
and the same on all hosts. Environment variables are not supported in the
value.

    path: plugins/mistral_elasticsearch/x86_64/mistral_elasticsearch

### Interval

The `interval` key takes a single integer value parameter. This
value represents the time in seconds the Mistral application will wait
between calls to the specified plug-in e.g.

    interval: 300

The value chosen is at the discretion of the user, however care should
be taken to balance the need for timely updates with the scalability of
the Elasticsearch installation and the average length of jobs on the
cluster.

### Options

The `options` mapping is optional and lists all options to be passed to
the plug-in as command line arguments to the executable. A full
list of valid options for this plug-in can be found in section
[2.2](#anchor-10) [Plug-in Configuration File Options](#anchor-10). The order of
options is not preserved. These values are passed to the plug-in executable
as `--key=value`. For example,

    options:
        host: hostname
        error: filename

will pass to the plug-in executable the command line arguments 
`--host=hostname` and `--error=filename`.

### Switches

The `switches` mapping is optional and lists all switches to be passed to
the plug-in as command line arguments to the executable. A full
list of valid switches for this plug-in can be found in section
[2.3](#anchor-11) [Plug-in Configuration File Switches](#anchor-11). The order of
switches is not preserved. Switches not present are presumed to be off. These
switches are passed to the plug-in executable as `--key`. For example,

    switches:
        date: on
        ssl: off

will pass to the plug-in executable the command line argument `--date`.

### Environment Variable Reporting
The `vars` mapping is optional and lists all environment variables that
the plug-in should store and report on. Environment variables not listed
are not reported on. These will be passed to the plug-in executable as
`--var=key`. For example,

    vars:
        USER: yes
        HOME: yes
        SHELL: no

will pass to the plug-in executable the command line arguments `--var=USER` and
`--var=HOME`.

## Plug-in Configuration File Options

The following configuration file key-value options are supported by the 
Elasticsearch plug-in.

    error: file

Specify location for error log. If not specified all errors will be
output on `stderr` and handled by Mistral error logging.

    host: hostname

The hostname of the Elasticsearch server with which to establish a
connection. If not specified the plug-in will default to `localhost`.

    index: index_name

Set the index to be used for storing data. This should match the index
name provided when defining the index mapping template (see section
[1.1](#anchor-2)). The plug-in will create indexes named
`<idx_name>-yyyy-MM-dd`. If not specified the plug-in will default to
`mistral`.

    mode: octal-mode

Permissions used to create the error log file specified by the -e
option.

    password: secret

The password required to access the Elasticsearch server if needed.

    port: number

Specifies the port to connect to on the Elasticsearch server host. If
not specified the plug-in will default to `9200`.

    username: user

The username required to access the Elasticsearch server if needed.

    es-version: num

The major version of the Elasticsearch server to connect to. If not
specified the plug-in will default to "`5`".

## Plug-in Configuration File Switches

The following configuration file options are supported by the Elasticsearch
plug-in.

    ssl: on

Connect to the Elasticsearch server via secure HTTP.

    date: on

Use date based index naming. By default the indexes are named 
idx_name-00000N, if you would prefer to use idx_name-YYYY-MM-DD then
specify this option.

# Mistral’s Elasticsearch Document Model

This section describes how the Mistral Elasticsearch Plug-in stores data
within Elasticsearch.

The Mistral Elasticsearch Plug-in will create indexes with a trailing
index number `mistral-00000N`. This allows for easy managing of the
indexes in Kibana using lifecycle policies and rollover. Previously
the default was to  create indexes with a date appended, by default
these would be named `mistral-YYYY-MM-DD`. This allows for easy manual
management of historic data. The old behaviour can be restored with
the `-d` option if preferred.

Documents are inserted into these indexes with the following labels and
structure:

```json
{
    "@timestamp",
    "rule": {
        "scope",
        "type",
        "label",
        "measurement",
        "calltype",
        "path",
        "fstype",
        "fsname",
        "fshost",
        "threshold",
        "timeframe",
        "size-min",
        "size-max"
    },
    "job": {
        "host",
        "job-group-id",
        "job-id"
    },
    "process": {
        "pid",
        "command",
        "file",
        "cpu-id",
        "mpi-world-rank"
    },
    "environment": {
        "var-name",
        …
    },
    "value"
}
```

By default, the only explicit type mapping defined is for `@timestamp`
which is set to be a date field.

The Mistral Elasticsearch Plug-in will insert documents as described in
the following table.

| Field                    | Value                                                   |
| :----------------------- | :------------------------------------------------------ |
| `@timestamp`             | Inserted as a UTC text date in the format `yyyy-MM-ddTHH:mm:ss.nnnZ `for example `2017-04-25T15:27:28.345Z` |
| `rule.scope`             | Inserted as a text string, set to either local or global indicating the scope of the contract containing the rule that generated the log. |
| `rule.type`              | Inserted as a text string, set to either monitor or throttle indicating the type of rule that generated the log. |
| `rule.label`             | Inserted as a text string, copied from the log message `LABEL` field unchanged. |
| `rule.measurement`       | Inserted as a text string, copied from the log message `MEASUREMENT` field unchanged. |
| `rule.calltype`          | Inserted as a text string, the list of call types specified in the log message `CALL-TYPE` field. The Mistral Elasticsearch plug-in will always log compound types in alphabetical order. E.g. if the log message listed call types as `read+write+seek` the plug-in will normalise this to `read+seek+write`. |
| `rule.path`              | Inserted as a text string, copied from the log message `PATH` field unchanged. |
| `rule.fstype`            | Inserted as a text string, copied from the log message `FSTYPE` field unchanged. |
| `rule.fsname`            | Inserted as a text string, copied from the log message `FSNAME` field unchanged. |
| `rule.fshost`            | Inserted as a text string, copied from the log message `FSHOST` field unchanged. |
| `rule.threshold`         | Inserted as a number, the rule limit as reported in the log message `THRESHOLD` field converted into the smallest unit for the measurement type. For bandwidth rules this field will be bytes, for latency rules it is microseconds and for count rules the simple raw count. |
| `rule.timeframe`         | Inserted as a number, the timeframe the measurement was taken over as reported in the log message `THRESHOLD` field, converted into microseconds. |
| `rule.size-min`          | Inserted as a number, the lower bound of the operation size range as reported in the log message `SIZE-RANGE` field, converted into bytes. If this field was set to `all` in the log message this value will be set to 0. |
| `rule.size-max`          | Inserted as a number, the upper bound of the operation size range as reported in the log message `SIZE-RANGE` field, converted into bytes. If this field was set to `all` in the log message this value will be set to the maximum value of an `ssize_t`. This value is system dependent but for 64 bit machines this will typically be `9223372036854775807`. |
| `job.host`               | Inserted as a text string, copied from the log message `HOSTNAME` field with any domain component removed. |
| `job.job-group-id`       | Inserted as a text string, copied from the log message `JOB-GROUP-ID` field unchanged or `N/A` if this field is blank. |
| `job.job-id`             | Inserted as a text string, copied from the log message `JOB-ID` field unchanged or `N/A` if this field is blank. |
| `process.pid`            | Inserted as a number, copied from the log message `PID` field unchanged. |
| `process.command`        | Inserted as a text string, copied from the log message `COMMAND-LINE` field unchanged. |
| `process.file`           | Inserted as a text string, copied from the log message `FILE-NAME` field unchanged. |
| `process.cpu-id`         | Inserted as a number, copied from the log message `CPU` field unchanged. |
| `process.mpi-world-rank` | Inserted as a number, copied from the log message `MPI-WORLD-RANK` field unchanged. |
| `environment.var-name`   | Inserted as a text string. The string `var-name` will be replaced by an environment variable name as specified in a `--var` option. The value stored will be the value of this variable as detected when the plug-in is initialised. If no `--var` options are specified the environment block will be omitted. |
| `value`                  | Inserted as a number, copied from the log message `MEASURED-DATA` field converted into the smallest unit for the measurement type. For bandwidth rules this field will be bytes, for latency rules it is microseconds and for count rules the simple raw count. |
