-module(b52_url_parser).
-vsn['0.1'].
%% API
-export([parse/1]).

%%====================================================================
%% API
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: parse/1: parse([Url]) -> {ok, {CleanOriginalUrl, Host,
%% /Path, FileName}} Description: just parse URL for saving this page
%% to hard disk, show how to build directory list to file
%% --------------------------------------------------------------------

parse(["www." ++ Url]) ->
    parse_http(Url, "www.");
parse(["http://www." ++ Url]) ->
    parse_http(Url, "http://www.");
parse(["http://" ++ Url]) ->
    parse_http(Url, "http://");
parse([Url]) ->
    parse_http(Url, "http://www.").


%%====================================================================
%% Internal functions
%%====================================================================
%% Want to return {Original url, domain for folder, [] -- array of folders, page}
%%
%% url_parser:parse_http("bankconference.ru/articles/summer/index.html") will return
%%
%% {ok,{"bankconference.ru/articles/summer/index.html",
%%   "bankconference.ru",
%%   "articles/summer"],
%%   "index.html"}}

parse_http(Url, Prefix) ->
    CleanUrl = string:strip(Url, right, $/),
    case string:chr(string:strip(CleanUrl, right, $/), $/) of
	0 ->
	    {ok, {Prefix ++ CleanUrl, CleanUrl, "", ["index"]}};
	N ->
	    Host = string:substr(Url, 1, N-1),
	    {ParsedPath, ParsedPage} = parse_path_and_page(string:substr(Url, N+1, length(Url)), ""),
	    {ok, {Prefix ++ Url, Host, ParsedPath, ParsedPage}}
    end.

%% from 2009/03/08/congratulations.html -> {ok, {[2009, 03, 08], congratulations.html}}
parse_path_and_page(RawPath, ParsedPath) ->
    case string:chr(RawPath, $/) of
	0 ->
	    {ParsedPath, RawPath};
	N ->
	    parse_path_and_page(
	      string:substr(RawPath, N+1, length(RawPath)),
	      ParsedPath ++ "/" ++ string:substr(RawPath, 1, N-1))
    end.
