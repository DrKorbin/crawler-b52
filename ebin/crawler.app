{application, crawler,
	[{description, "Yet another crawler"},
	{vsn, "0.1"},
	{modules, [b52_config, b52_curl, b52_curl_sup, b52_tcpip2http,
		  b52_telnet_server, b52_url_parser, crawler, crawler_sup]},
	{registered, []},
	{applications, [kernel, stdlib]},
	{env, []},
	{mod, {crawler, []}}]}.
