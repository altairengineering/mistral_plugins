Mistral Graphite plug-in
========================

This plug-in receives violation data from Mistral and enters it into a Graphite
database.

The plug-in accepts the following command line options:

-4 | --4
  Use IPv4 only. This is the default behaviour.

-6 | --4
  Use IPv6 only.

--error=file | -e file
  Specify location for error log. If not specified all errors will
  be output on stderr and handled by Mistral error logging.

--host=hostname | -h hostname
  The hostname of the Graphite server with which to establish a connection.
  If not specified the plug-in will default to "localhost".

--instance=metric | -i metric
  Set the root metric node name the plug-in should create data under. This
  value can contain '.' characters to allow more precise classification
  of metrics.  Defaults to "mistral".

--mode=octal-mode | -m octal-mode
  Permissions used to create the error log file specified by the -o
  option.

--port=port | -p port
  Specifies the port to connect to on the Graphite server host.
  If not specified the plug-in will default to "2003".

The options would normally be included in a Mistral configuration file, such as

::

    plugin:
        path: /path/to/mistral_graphite
        interval: 5
        options:
            instance: mistral.myuser
            host: 10.33.0.186
            port: 2003
            error: /path/to/mistral_graphite.log
