-module(curs9).
-export([
    hello/2, factorial/1, preli/1, pingN/2, start/0, pong/0, 
    hi/0, hi2/0, prels/1, prelg/1, prelc/1, run/0, prelA/1,
    prelB/1, myrec/0, myreceiver/0, start_game/0
]).
-define(Eu, "Cos"). % macros
% comment
% litere mari pt variabile
% variab incep litera mare cu _
% atomii incep cu litera mica
% termen = data de orice tip
% orice instructiune se termina cu punct .
% un program este format din module;
% numele fis coincide cu numele modulului
% compilarea se face folosind comanda c (nume_fis)
% clear terminal - io:format("\ec").

hello(S, X) -> io:format("Hello ~s, factorial este ~p!~n", [S,X]).

factorial(0) -> 1;
factorial(N) -> N * factorial(N-1).

start() ->
    {ok, [Name]} = io:fread("Your Name: ", "~s"),
    {ok, [Val]} = io:fread("Your No: ", "~d"),
    hello(Name, factorial(Val)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hi() -> io:format("Hi!~n").
hi2() -> io:format("Hi, ~s!~n", [?Eu]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% definirea functiilor se face folosind pattern-uri
prels("a" ++ L) -> io:format("~s~n", [L ++ L]);
prels("b" ++ L) -> io:format("~s~n", [L ++ "b"]);
prels(_) -> io:format("Nu incepe cu \"a\" sau \"b\".~n").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prelg(X) when (X rem 2 == 0) -> io:format("Este par ~n");
prelg(_) -> io:format("Este impar~n").
preli(X) ->
    Rez = if ((X =< 1) and (X >= 0)) -> "subunitar";
                            (X > 1)  -> "supraunitar";
                            true     -> "negativ" % obligatorie
        end,
    {X, Rez}.

prelc({S,X}) -> case {S,X} of
        {"pozitiv", X} when ((X =< 1) and (X >= 0)) -> "subunitar";
        {"pozitiv", X} when (X > 1)                 -> "supraunitar";
        {_, X}         when (X >= 0)                -> "pozitiv";
        _                                           -> "negativ"
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run() ->
    {ok, [Name]} = io:fread("Your name: ", "~s"),
    {ok, [Val]} = io:fread("Your number: ", "~d"),
    hello(Name, factorial(Val)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ? Concurenta in Erlang
prelA(X) when (X == 0) -> io:format("End A~n");
prelA(X) when (X > 0)  -> io:format("A ~n"), prelA(X - 1);
prelA(_)               -> io:format("error ~n").

prelB(X) when (X == 0) -> io:format("End B~n");
prelB(X) when (X > 0)  -> io:format("B ~n"), prelB(X - 1);
prelB(_)               -> io:format("error ~n").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trimiterea mesajelor: Pid ! msg

myrec() ->
    receive % raspunsul este definit in instructiunea receive ... end
        {do_A, X} -> prelA(X);
        {do_B, X} -> prelB(X);
        _         -> io:format("Nothing to do ~n")
    end.

% ! receive este singura instructiune care blocheaza procesul

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% schimb de mesaje intre procese

myreceiver() ->
    receive
        {From, {do_A, X}} -> From ! "Thanks! I do A", prelA(X);
        {From, {do_B, X}} -> From ! "Thanks! I do B", prelB(X);
        _                 -> io:format("Nothing to do~n")
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pingN(Pid, 0) -> Pid ! {self(), finished},
                io:format("Ping finished!~n");

pingN(Pid, N) -> Pid ! {self(), ping},
    receive
        {Pid, pong} -> io:format("Ping received Pong. ~n")
    end,
    pingN(Pid, N-1).

pong() -> 
    receive
        {_, finished} -> io:format("Game over. ~n");
        {Pid, ping} -> io:format("Pong received Ping. ~n"),
                       Pid ! {self(), pong},
                       pong()
    end.

start_game() -> PongId = spawn(curs9, pong, []),
                         spawn(curs9, pingN, [PongId, 5]).