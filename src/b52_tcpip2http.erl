-module(b52_tcpip2http).
-vsn('0.1').
%% API
%%-export([]).
-compile(export_all).

get_http(URL) ->
    {ok, {CleanUrl, Host, Path, File}} = b52_url_parser:parse([URL]),
    case gen_tcp:connect(Host, 80, [binary, {packet, 0}]) of
	{ok, Socket} ->
	    Command = "GET " ++ CleanUrl ++ " HTTP/1.1\r\nHost: http://www." ++ Host ++ "\r\n\r\n",
	    ok = gen_tcp:send(Socket, Command),
	    {ok, Bin} = binary_receiver(Socket, list_to_binary([])),
	    DirectoryToSave = b52_config:get(where_to_save_web)++Host++"/"++Path,
	    filelib:ensure_dir(DirectoryToSave),
	    egd:save(Bin, DirectoryToSave ++ File),
	    ok = gen_tcp:close(Socket);
	{error, Why} ->
	    {error, Why}
    end.

binary_receiver(Socket, Bin) ->
	receive
	    {tcp, Socket, B} ->
		binary_receiver(Socket, concat_binary([Bin, B]));
	    {tcp_closed, Socket} ->
		{ok, Bin};
	    {tcp_error, Socket, Reason} ->
		{error, Reason};
	    Other ->
		{error, {socket, Other}}
	end.
