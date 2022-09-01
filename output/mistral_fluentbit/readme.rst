Mistral Fluent Bit plug-in
==========================

This plug-in receives violation data from Mistral and sends it to Fluent Bit.

This Mistral plug-in sends data to the Fluent Bit TCP input plug-in. The Fluent Bit
TCP input plug-in allows to listen for JSON messages through a network interface (TCP port).


Plug-in Configuration
---------------------

The plug-in accepts the following command line options:

--error=filename | -e filename
  The name of the file to which any error messages will be written.

--host=hostname | -h hostname
  The name of the machine on which Fluent Bit is hosted. If not specified the
  plug-in will use "localhost".

--mode=octal-mode | -m octal-mode
  Permissions used to create the error log file specified by the -e option.

--port=number | -p number
  The port to be used when connecting to the Fluent Bit TCP input plug-in. If not specified 
  the Mistral plug-in will use port 5170.

--var=var-name | -v var-name
  The name of an environment variable, the value of which should be stored by
  the plug-in. This option can be specified multiple times.

The options would normally be included in a Mistral configuration file, such as

::
    plugin:
        path: /path/to/mistral_fluentbit
        interval: 1
        options:
            host: 127.0.0.1
            port: 5170
            error: /path/to/mistral_fluentbit.log
        var:
            USER: yes
            SHELL: yes
