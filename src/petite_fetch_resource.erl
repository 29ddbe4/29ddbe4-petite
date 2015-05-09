-module(petite_fetch_resource).

%% API
-export([to_json/2]).

%% cowboy_rest callbacks
-export([init/2
	,content_types_provided/2
	,resource_exists/2
	,moved_permanently/2
	,previously_existed/2]).

%%====================================================================
%% API functions
%%====================================================================

to_json(Req, State) ->
    {<<"{}">>, Req, State}.

%%====================================================================
%% cowboy_rest callbacks
%%====================================================================

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    CTP = [{{<<"application">>, <<"json">>, []}, to_json}],
    {CTP, Req, State}.

resource_exists(Req, State) ->
    {false, Req, State}.

moved_permanently(Req, State) ->
    {{true, State}, Req, State}.

previously_existed(Req, State) ->
    Id = binary_to_list(cowboy_req:binding(id, Req)),
    case uri_server:get_uri(Id) of
	{ok, URI} ->
	    {true, Req, URI};
	{error, not_found} ->
	    {false, Req, State}
    end.

%%====================================================================
%% Internal functions
%%====================================================================
