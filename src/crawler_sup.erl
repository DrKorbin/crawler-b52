-module(crawler_sup).
-vsn['0.1'].
-define(SERVER, ?MODULE).

-behaviour(supervisor).


-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    io:format("~p (~p) starting...~n", [?MODULE, self()]),
    CurlSup = {b52_curl_sup, {b52_curl_sup, start_link, []},
	       permanent, infinity, supervisor, [b52_curl_sup]},
    {ok, {{one_for_one, 5, 60}, [CurlSup]}}.
