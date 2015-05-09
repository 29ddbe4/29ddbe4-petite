%%%-------------------------------------------------------------------
%% @doc petite public API
%% @end
%%%-------------------------------------------------------------------

-module(petite_app).

-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Dispatch    = cowboy_router:compile(
		    [{'_', [{"/", toppage_handler, []},
			    {"/latest", petite_latest_resource, []},
			    {"/shorten", petite_shorten_resource, []},
			    {"/:id", petite_fetch_resource, []}]}]
		   ),
    Ref         = http,
    NbAcceptors = 100,
    TransOpts   = [{port, 8080}],
    ProtoOpts   = [{env, [{dispatch, Dispatch}]}],
    cowboy:start_http(Ref, NbAcceptors, TransOpts, ProtoOpts),
    petite_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
