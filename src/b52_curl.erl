-module(b52_curl).

-behaviour(gen_server).

%% API
-export([start/0, stop/0, get_and_save/1, do/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

%% -record(state, {}). don't need it for now, then here we will store data for
%% syncronization
-define(SERVER, ?MODULE).
%%====================================================================
%% API
%%====================================================================

start() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() ->
    gen_server:cast(?SERVER, stop).

do(Url) ->
    gen_server:cast(?SERVER, {download_page, Url}).


%%====================================================================
%% SERVER
%%====================================================================
init([]) ->
    inets:start(),
    {ok, []}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.


handle_cast(stop, State) ->
    {stop, normal, State};

handle_cast({download_page, Url}, State) ->
    spawn(b52_tcpip2http, get_http, [Url]),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.



handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
