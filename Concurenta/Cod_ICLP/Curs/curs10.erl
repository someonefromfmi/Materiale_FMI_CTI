-module(curs10).
-export([
    server_loop/0, start_server/0, client/1, client_loop/3,
    worker/2, calls/1, start_seq_clients/2, start_par_clients/1,
    sleep/1, flush/0, important/0, store/1, take/1, start/1,
    show/0, terminate/0, gata/0, waitone/1
]).

client(Request) ->
    serv ! {self(), Request}, 
    receive 
        {serv, Response} -> Response
        % functia client intoarce raspunsul primit de server
    end.

client_loop(Pid, 0, L) -> Pid ! {self(), "Good bye"}, L;
client_loop(Pid, X, L) -> 
    R = client({double, X}),
    io:fwrite("prel ~w~n!", [X]),
    client_loop(Pid, X - 1, L ++ [R]).
% ! functiile sunt executate secvential

% ! procesele client se executa in paralel si se intoarce lista rezultatelor

start_server() -> register(serv, spawn(fun() -> server_loop() end)).
% register(Name, Pid) - asociaza Name procesului cu id-ul Pid; 
% Name este atom si este "eliberat" cand procesul se termina
% whereis(Name) intoarce id-ul procesului inregistrat cu Name
% (sau undefined daca nu exista)
start_seq_clients(Pid,N) -> client_loop(Pid, N, []).
start_par_clients(N) -> calls(N).
worker(Parent, Number) ->
    spawn( fun() ->
        Result = client ({double,Number}),
        Parent ! {self(),Result}
    end ).

calls (N) ->
    Parent = self(), % id-ul procesului care creaza clientii
    Pids = [worker(Parent,X)|| X <- lists:seq(1,N)],
    % worker creaza un proces client si intoarce id-ul acestuia
    % Pid este id-ul procesului server
    [waitone(P)|| P <- Pids].

waitone (Pid) -> 
    receive 
        {Pid,Response} -> Response
    end. 

server_loop() ->
receive
{From, {double, Number}} -> From ! {serv,(Number*2)},
server_loop() ;
{From, "Good Bye"} -> From! {serv,"Good Bye"},
server_loop(); 
{From,_} -> From ! {serv,error},
server_loop()
end.

%%%%!!!!! posibil deadlock la server
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sleep(T) -> 
    receive
        after T -> 
            ok
        end.

flush() ->
    receive
        _   -> flush()
    after 0 -> ok
    end.

% varianta fc flush() care ordoneaza mesajele dupa prioritati
important() ->
    receive
        {Priority, X} when Priority > 10 -> [X|important()]
    after 0                              -> normal()
    end.

normal() ->
    receive
        {_, X} -> [X|normal()]
    after 0 -> []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Schimb de mesaje cu transmitera starii
fridgef(FoodList) ->
    receive
        {From, {store, Food}} -> From ! {fridge, ok},
                                fridgef([Food|FoodList]);
        {From, {take, Food}} -> 
            case lists:member(Food, FoodList) of
                true -> From ! {fridge, {ok, Food}},
                        fridgef(lists:delete(Food, FoodList));
                false -> From ! {fridge, not_found},
                        fridgef(FoodList)
            end;
        {From,show} -> From ! {fridge, FoodList},
                    fridgef(FoodList);
        {From,terminate} -> From ! {fridge, done}
    after 30000 -> timeout
    end,
    receive
        gata -> io:format("Sunt gata~n")
    end.

gata() -> fridge ! gata.

start(FoodList) -> register(
    fridge, 
    spawn(fun() -> fridgef(FoodList) end)
).

store(Food) ->
    fridge! {self(), {store, Food}},
    receive
        {fridge, Msg} -> Msg
    end.

take(Food) ->
    fridge ! {self(), {take, Food}},
    receive
        {fridge, Msg} -> Msg
    end.

show() ->
    fridge ! {self(), show},
    receive
        {fridge, Msg} -> Msg
    end.

terminate() -> 
    fridge ! {self(), terminate},
    receive
        {fridge, Msg} -> Msg
    end.
