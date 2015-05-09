-module(petite_SUITE).

-export([all/0
	,init_per_suite/1
	,end_per_suite/1
	,init_per_testcase/2
	,end_per_testcase/2]).

-export([get_latest/1
	,get_uri/1]).

-include_lib("common_test/include/ct.hrl").

all() ->
    [get_latest, get_uri].

init_per_suite(Config) ->
    uri_server:install(),
    mnesia:start(),
    Config.

end_per_suite(_Config) ->
    mnesia:stop(),
    ok.

init_per_testcase(_, Config) ->
    uri_server:start_link(),
    Config.

end_per_testcase(_, _Config) ->
    ok.

get_latest(_Config) ->
    {ok, _} = uri_server:put_uri("https://github.com/rebar/rebar"),
    {ok, _} = uri_server:put_uri("https://github.com/rebar/rebar3"),
    {ok, _} = uri_server:put_uri("https://pragprog.com/"),
    {ok, [{link, "2", "https://pragprog.com/"},
	  {link, "1", "https://github.com/rebar/rebar3"}]} = uri_server:get_latest(2).

get_uri(_Config) ->
    {ok, Id} = uri_server:put_uri("https://pragprog.com/"),
    {ok, "https://pragprog.com/"} = uri_server:get_uri(Id),
    {error, not_found} = uri_server:get_uri(make_ref()).
