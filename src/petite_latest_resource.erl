-module(petite_latest_resource).

%% API
-export([to_json/2]).

%% cowboy_rest callbacks
-export([init/2
	,content_types_provided/2]).

%%====================================================================
%% API functions
%%====================================================================

to_json(Req, State) ->
    HostURL = cowboy_req:host_url(Req),
    {ok, LatestLinkList} = uri_server:get_latest(20),
    List = lists:map(
	     fun({link, Id, URI}) ->
		     #{ <<"shortLink">> => list_to_binary([HostURL, $/, Id]),
			<<"uri">> => list_to_binary([URI]) }
	     end, LatestLinkList),
    Body = jsx:encode(#{<<"latest">> => List}),
    {Body, Req, State}.

%%====================================================================
%% cowboy_rest callbacks
%%====================================================================

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    CTP = [{{<<"application">>, <<"json">>, []}, to_json}],
    {CTP, Req, State}.

%%====================================================================
%% Internal functions
%%====================================================================
