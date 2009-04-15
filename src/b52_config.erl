-module(b52_config).
-author('dmitrii.golub@gmail.com').
-vsn('0.1').
-behaviour(gen_server).

-export([start/0, stop/0, get/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-define(CONFIG, "../config/b52_crawler.cfg").
-define(CONFIG_TABLE, tb_config).

start() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() ->
    gen_server:cast(?SERVER, stop).

get(Key) ->
    gen_server:call(?SERVER, {get, Key}).


init(_) ->
    ok = load_config(),
    {ok, []}.

handle_call({get, Key}, _From, State) ->
    {reply, do_get(Key), State};
handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Why, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%
%% INTERNAL API
%%

load_config() ->
    case file:consult(?CONFIG) of
	{ok, Terms} ->
	    insert_config(Terms);
	_Error ->
	    {error, config_error}
    end.


insert_config(Terms) ->
    ets:new(?CONFIG_TABLE, [set, private, named_table, {keypos, 1}]),
    insert_pairs(Terms).

insert_pairs([]) ->
    ok;
insert_pairs([{_Key, _Value} = Pair | Terms]) ->
    ets:insert(?CONFIG_TABLE, Pair),
    insert_pairs(Terms).


do_get(Key) ->
    case ets:lookup(?CONFIG_TABLE, Key) of
	[Val] ->
	    {value, Val};
	[] ->
	    undefined
    end.
