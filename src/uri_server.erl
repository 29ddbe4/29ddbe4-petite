%%%-------------------------------------------------------------------
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(uri_server).

-behaviour(gen_server).

%% API
-export([start_link/0
	,get_latest/1
	,get_uri/1
	,put_uri/1
	,install/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {next}).
-record(link, {id, uri}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

get_latest(N) ->
    gen_server:call(?SERVER, {get_latest, N}).

get_uri(X) ->
    gen_server:call(?SERVER, {get_uri, X}).

put_uri(X) ->
    gen_server:call(?SERVER, {put_uri, X}).

install() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(link, [{attributes, record_info(fields, link)}]),
    mnesia:stop().

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    mnesia:create_table(link, [{attributes, record_info(fields, link)}]),
    {ok, #state{next=0}}.

handle_call({get_latest, Count}, _From, State=#state{next=N}) ->
    Start = N - 1,
    End = max(N - Count, 0),
    Ids = [b36_encode(I) || I <- lists:seq(Start, End, -1)],
    Result = lists:map(
	       fun(Id) ->
		       F = fun() ->
				   mnesia:read({link, Id})
			   end,
		       [Record] = mnesia:activity(transaction, F),
		       Record
	       end, Ids),
    {reply, {ok, Result}, Start};
handle_call({get_uri, Id}, _From, State) ->
    F = fun() ->
		mnesia:read({link, Id})
	end,
    Reply = case mnesia:activity(transaction, F) of
		[#link{uri=URI}] ->
		    {ok, URI};
		[] ->
		    {error, not_found}
	    end,
    {reply, Reply, State};
handle_call({put_uri, URI}, _From, State=#state{next=N}) ->
    Id = b36_encode(N),
    Link = #link{id=Id, uri=URI},
    F = fun() ->
		mnesia:write(Link)
	end,
    mnesia:activity(transaction, F),
    {reply, {ok, Id}, State#state{next=N+1}}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

b36_encode(N) ->
    integer_to_list(N, 36).
