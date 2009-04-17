-module(b52_curl_sup).
-vsn('0.1').

-behaviour(supervisor).

-define(SERVER, ?MODULE).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    process_flag(trap_exit, true),
    io:format("~p (~p) starting...~n", [?MODULE, self()]),
    Curl = {b52_curl, {b52_curl, start, []},
	    permanent, 2000, worker, [b52_curl]},
    Config={b52_config, {b52_config, start, []},
	    permanent, 2000, worker, [b52_config]},
    {ok, {{one_for_all, 5, 30}, [Curl, Config]}}.
