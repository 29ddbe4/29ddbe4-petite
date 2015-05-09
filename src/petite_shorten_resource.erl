-module(petite_shorten_resource).

%% API
-export([process_post/2
	,to_json/2]).

%% cowboy_rest callbacks
-export([init/2
	,allowed_methods/2
	,content_types_accepted/2
	,content_types_provided/2]).

%%====================================================================
%% API functions
%%====================================================================

process_post(Req, State) ->
    HostURL = cowboy_req:host_url(Req),
    {ok, Qs, Req2} = cowboy_req:body_qs(Req),
    URI = proplists:get_value(<<"uri">>, Qs),
    {ok, Id} = uri_server:put_uri(URI),
    Body = list_to_binary(["{\"uri\": \"", HostURL, $/, Id, "\"}"]),
    Req3 = cowboy_req:set_resp_body(Body, Req2),
    {true, Req3, State}.

to_json(Req, State) ->
    {<<"{}">>, Req, State}.

%%====================================================================
%% cowboy_rest callbacks
%%====================================================================

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    CTA = [{{<<"application">>, <<"x-www-form-urlencoded">>, []}, process_post}],
    {CTA, Req, State}.

content_types_provided(Req, State) ->
    CTP = [{{<<"application">>, <<"json">>, []}, to_json}],
    {CTP, Req, State}.

%%====================================================================
%% Internal functions
%%====================================================================
