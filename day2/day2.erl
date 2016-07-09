#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname factorial -mnesia debug verbose
%-mode(compile).
-record(state, {area=0}).
-mode(compile).
main([]) ->
    {ok, Dims} = read_input(),
    io:format("input is ~p~n", [lists:nth(1, Dims)]),
    Calc = new_calc(),
    feed_data(Calc, Dims),
    {area, Msg} = calculate(Calc),
    io:format("Calculated: ~p~n", [Msg]),
    ok;


main(_) ->
    usage().

feed_data(_, []) -> ok;
feed_data(Calc, [{X,Y,Z}|Data]) ->
    ok = feed(Calc, X,Y,Z),
    feed_data(Calc, Data).

read_input() ->
    {ok, File} = file:open("input.txt", read),
    {ok, read_input(File, [])}.

read_input(File, Acc) ->
    case file:read_line(File) of
        {ok, Line} -> 
            read_input(File, [parse(Line)|Acc]);
        eof -> Acc
    end.

parse(Line) ->
    Clean = string:strip(Line, right, $\n),
    [X, Y, Z] = string:tokens(Clean, "x"),
    {list_to_integer(X), list_to_integer(Y), list_to_integer(Z)}.

%% Calculator process - calculates area
area_calculator(#state{area=Area}=State) ->
    receive
        {From, {input, X,Y,Z}} -> 
            Areas = [X*Y, Y*Z, X*Z],
            Min = lists:min(Areas),
            Incr = 2 * lists:sum(Areas) + Min,
            case {X,Y,Z} of
                {10,9,8} -> io:format("Incr is: ~p~n", [Incr]);
                _ -> ok
            end,
            From ! {self(), ok},
            area_calculator(State#state{area=Area+Incr});
        {From, done} -> 
            From ! {self(), {area, State#state.area}},
            ok
    end.

new_calc() ->
    spawn(fun() -> area_calculator(#state{}) end).

feed(Pid, X, Y, Z) ->
    Pid ! {self(), {input, X, Y,Z}},
    receive
        {Pid, Msg} -> Msg
    end.

calculate(Pid) ->
    Pid ! {self(), done},
    receive
        {Pid, Msg} -> Msg
    end.



usage() ->
    io:format("usage: factorial integer\n"),
    halt(1).