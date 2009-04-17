-module(crawler).
-behavior(application).

-export([start/2, stop/1, start/0]).

start() ->
    application:start(?MODULE).

start(_Type, _StartArgs) ->
    crawler_sup:start_link().

stop(_State) ->
    ok.
