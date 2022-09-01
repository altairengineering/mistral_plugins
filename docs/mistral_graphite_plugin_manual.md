% Ellexus - Graphite Plug-in Configuration Guide

# Installing the Graphite Plug-in

Extract the Mistral plug-ins archive that has been provided to you
somewhere sensible. Please make sure that you use the appropriate
version of the plug-ins (32 or 64 bit) for the architecture of the
machine on which the plug-in will run.

In addition, if the Mistral Plug-ins package was obtained separately
from the main Mistral product, please ensure that the version of the
plug-in downloaded is compatible with the version of Mistral in use.
Currently there is only one version of the Graphite Plug-in available
which is compatible with Mistral v2.10.0 and above.

The Graphite plug-in can be found in:

    <installation directory>/output/mistral_graphite_v1.0/

The plug-in must be available in the same location on all execution
hosts in your cluster.

# Configuring Mistral to use the Graphite Plug-in

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
        path: plugins/mistral_graphite/x86_64/mistral_graphite

This section describes the specific settings required to enable the
Graphite Plug-in.

### Path

The `path` key must be set to the path of the grahite plguin-in
executable. This must be either absolute or relative to the 
`MISTRAL_INSTALL_DIRECTORY` environment variable and needs to be accessible
and the same on all hosts. Environment variables are not supported in the
value.

    path: plugins/mistral_graphite/x86_64/mistral_graphite

### Interval

The `interval` key takes a single integer value parameter. This
value represents the time in seconds the Mistral application will wait
between calls to the specified plug-in e.g.

    interval: 300

The value chosen is at the discretion of the user, however care should
be taken to balance the need for timely updates with the scalability of
the Graphite installation and the average length of jobs on the
cluster.

### Options

The `options` mapping is optional and lists all options to be passed to
the plug-in as command line arguments to the executable. A full
list of valid options for this plug-in can be found in section
[2.2](#anchor-9) [Plug-in Configuration File Options](#anchor-9). The order of
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
[2.3](#anchor-10) [Plug-in Configuration File Switches](#anchor-10). The order of
switches is not preserved. Switches not present are presumed to be off. These
switches are passed to the plug-in executable as `--key`. For example,

    switches:
        4: on
        6: off

will pass to the plug-in executable the command line argument `--4`.

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

The following command line options are supported by the Graphite
plug-in.

    error: [filename]

Set the location of the file which should be used to log any errors
encountered by the plug-in. Defaults to sending messages to *stderr* for
handling by Mistral.

    host: [hostname]

Set the location of the Graphite host the plug-in should connect to.
Defaults to “localhost”

    instance: [metric]

Set the root metric node name of the plug-in should create data under.
This value can contain ‘.’ characters to allow more precise
classification of metrics. Defaults to “mistral”.

    mode: [octal-mode]

Permissions used to create the error log file specified by the *-e*
option. If not specified the file will be created with permissions as
specified by the user’s current *umask* value.

    port: [number]

Set the port the plug-in should use for the connection. Defaults to
“2003”

## Plug-in Configuration File Switches

    4: on

Use IPv4 only.

    6: on

Use IPv6 only.

# Mistral’s Graphite data model

This section describes how the Mistral Graphite plug-in stores data
within Graphite.

The plug-in will create data using the following metric:

    instance.scope.logtype.measurement.label.path.call-type.size.job-group.job-id.host.cpu-id.mpi-rank

Instance will default to “mistral” but can be overridden by use of the
“*--instance*” option to the plug-in. The use of ‘.’ characters in a
custom instance value is permitted to allow additional, job-level data
to be stored if needed.

Measurement refers to the type of statistic being recorded e.g.
bandwidth versus mean-latency. The following is a list of all possible
measurement values that can be produced by Mistral. As above where this
list conflicts with information in the main Mistral User Guide please
verify that the plug-in version available is compatible with the version
of Mistral in use and, if so, the information in the User Guide should
be assumed to be correct.

|                        |                                                                                                                                                                                                                                                                  |
| :--------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bandwidth`     | Amount of data processed by calls of the specified type in the time frame. This applies only to “read” and “write” calls.                                                                                                                                        |
| `count`         | The number of calls of the specified type in the time frame.                                                                                                                                                                                                     |
| `seek-distance` | Total distance moved within files by calls of the specified type in the time frame. This applied only to “seek” calls.                                                                                                                                           |
| `max-latency`   | The maximum duration of any call of the specified type in the time frame. Subject to data sampling, see the Mistral User Guide for more information.                                                                                                             |
| `mean-latency`  | The mean duration of any call of the specified type in the time frame, provided the number of calls is higher than the value of ***MISTRAL\_MONITOR\_LATENCY\_MIN\_IO***. Subject to data sampling, see the Mistral User Guide for more information.             |
| `total-latency` | The total duration of time spent in calls of the specified type in the time frame, provided the number of calls is higher than the value of ***MISTRAL\_MONITOR\_LATENCY\_MIN\_IO***. Subject to data sampling, see the Mistral User Guide for more information. |

The remaining metric components are defined as follows:

<table>
<tbody>
<tr class="odd">
<td style="text-align: left;">scope</td>
<td style="text-align: left;">Either “local” or “global” indicating the scope of the contract containing the rule that generated the log.</td>
</tr>
<tr class="even">
<td style="text-align: left;">logtype</td>
<td style="text-align: left;">Either “monitor” or “throttle” indicating the type of rule that generated the log.</td>
</tr>
<tr class="odd">
<td style="text-align: left;">label</td>
<td style="text-align: left;">Copied from the log message <em>LABEL</em> field unchanged.</td>
</tr>
<tr class="even">
<td style="text-align: left;">path</td>
<td style="text-align: left;">Copied from the log message <em>PATH</em> field. All ‘/’ characters will be replaced with ‘:’. Any character that is not an alphanumeric, a hyphen ‘-’ or an underscore ‘_’ character will be replaced with ‘-’.</td>
</tr>
<tr class="odd">
<td style="text-align: left;">call-type</td>
<td style="text-align: left;"><p>The list of call types specified in the log message <em>CALL-TYPE</em>field. The Mistral Graphite plug-in will always log compound types in alphabetical order.</p>
<p>E.g. if the log message listed call types as “<em>read+write+seek</em>” the plug-in will normalise this to “<em>read+seek+write</em>”</p></td>
</tr>
<tr class="even">
<td style="text-align: left;">size</td>
<td style="text-align: left;">Copied from the log message <em>SIZE-RANGE</em> field unchanged.</td>
</tr>
<tr class="odd">
<td style="text-align: left;">job-group</td>
<td style="text-align: left;"><p>Copied from the log message <em>JOB-GROUP-ID</em> field. All ‘/’ characters will be replaced with ‘:’. Any character that is not an alphanumeric, a hyphen ‘-’ or an underscore ‘_’ character will be replaced with ‘-’.</p>
<p>Set to “None” if this log field is blank.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;">job-id</td>
<td style="text-align: left;"><p>Copied from the log message <em>JOB-ID</em> field. All ‘/’ characters will be replaced with ‘:’. Any character that is not an alphanumeric, a hyphen ‘-’ or an underscore ‘_’ character will be replaced with ‘-’.</p>
<p>Set to “None” if this log field is blank.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;">host</td>
<td style="text-align: left;">Copied from the log message <em>HOSTNAME</em> field with any domain component removed.</td>
</tr>
<tr class="even">
<td style="text-align: left;">cpu-id</td>
<td style="text-align: left;">Copied from the log message <em>CPU</em> field unchanged.</td>
</tr>
<tr class="odd">
<td style="text-align: left;">mpi-rank</td>
<td style="text-align: left;">Copied from the log message <em>MPI-WORLD-RANK</em> field unchanged.</td>
</tr>
</tbody>
</table>

The Mistral Graphite plug-in records the observed value as reported in
the log message *MEASURED-DATA* field converted into the smallest unit
for the measurement type.

For bandwidth rules this field will be bytes, for latency rules it is
microseconds and for count rules the simple raw count.
