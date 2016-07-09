#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname factorial -mnesia debug verbose
main([]) ->
    {ok, Input} = read_input(),
    io:format("input is ~p~n", [Input]),
    {ok, {Floor, Basement}} = calculate_floor(Input),
    io:format("Floor is: ~p~n", [Floor]),
    case Basement of
    	0 -> io:format("Never entered basement");
    	X -> io:format("Entered based on ~pth direction~n", [X])
    end;

main(_) ->
    usage().

calculate_floor(Directions) -> {ok, calculate_floor(Directions, 0, 0, 1)}.

% L - current level
% B - first direction to cause basement
% P - current position
calculate_floor([], L, B, _P) -> {L, B};
calculate_floor([$)|R], L, B, P) -> 
	B1 = go_down(L, B, P),
	calculate_floor(R, L - 1, B1, P + 1);
calculate_floor([$(|R], L, B, P) -> 
	calculate_floor(R, L + 1, B, P + 1).

go_down(0, 0, P) -> P;
go_down(_, B, _) -> B.
	

read_input() ->
	{ok, Binary} = file:read_file("input.txt"),
	{ok, binary_to_list(Binary)}.


usage() ->
    io:format("usage: factorial integer\n"),
    halt(1).