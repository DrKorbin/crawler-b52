-module(b52_app).
-behavior(application).

-export([start/2, stop/1]).

start(_Type, StartArgs) ->
    b52_system_sup:start_link(StartArgs).

stop(_State) ->
    ok.
