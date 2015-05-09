%%%-------------------------------------------------------------------
%% @doc petite top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(petite_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    RestartStrategy = one_for_all,
    MaxR = 0,
    MaxT = 1,
    Child = {server,
	     {uri_server, start_link, []},
	     permanent,
	     5000,
	     worker,
	     [uri_server]},
    {ok, {{RestartStrategy, MaxR, MaxT}, [Child]}}.

%%====================================================================
%% Internal functions
%%====================================================================
