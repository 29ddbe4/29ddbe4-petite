-module(toppage_handler).

%% API
-export([to_html/2
	,to_json/2]).

%% cowboy_rest callbacks
-export([init/2
	,content_types_provided/2]).

%%====================================================================
%% API functions
%%====================================================================

to_html(Req, State) ->
    {<<"<p>Hello World!</p>">>, Req, State}.

to_json(Req, State) ->
    {<<"{}">>, Req, State}.

%%====================================================================
%% cowboy_rest callbacks
%%====================================================================

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    CTP = [{{<<"text">>, <<"html">>, []}, to_html},
	   {{<<"application">>, <<"json">>, []}, to_json}],
    {CTP, Req, State}.

%%====================================================================
%% Internal functions
%%====================================================================
