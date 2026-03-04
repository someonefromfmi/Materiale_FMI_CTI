-module(lab10).
-export([
    main/1, fibo/1, pbThread/0, main2/1
]).

% Erlang: modelul de concurenta cu actori
% Sintaxa: 
% limbaj de programare functional
% Avem:
% - variabile: Majuscule, _Var, _ (match cu orice)
% - atomi - minuscula (corespund literalilor), 'atom'
% - Problema egalitatii
%   - egalitate extensionala - =:= (4 * 4 = 3 + 5), reducere
%   - egalitate intensionala - 2 * x != x + x, matching
%   - mai avem si ==, egalitate stricta, ca la siruri de caractere
% Programare functionala:
% tipuri inductive si fc recursive: if-then-else, guards
% recursia pe liste ([], |): se adauga si HOF (map, filter, etc.)
% tuples: {,}
% operatori importanti: 
% - . finalul instructiunii
% - , conjunctie (intre instr)
% - ; disjunctie (instr)
% guards: 
% - and : andalso
% - or: orelse
% Comprehensiune: [N || N <- [1,2,3]] = [1,2,3]

% sum / 2 
sum(X, Y) -> X + Y. 

% fibo / 1 
fibo(X) when X < 1 -> 0 ; 
fibo(X) when X =:= 1 -> 1 ;
fibo(X) -> fibo(X - 1) + fibo(X - 2).

% sum_even / 1
sum_even([]) -> 0 ; 
sum_even([H | T]) -> 
  if H rem 2 =:= 0 -> 
    H + sum_even(T) ; 
  true -> 
    sum_even(T)
  end. 


% functiile inline (anonime) au sintaxa fun (arg) -> body end 
% lists:map(fun(X) -> X + 1 end, L)
% lists:filter(fun(X) -> cond(X) end, L)

% pentru a pornit un thread se foloseste functia spawn 
% spawn(inline function)

% Pid ! msg 
% receive ... end. 

myThread() -> 
  io:format("Running ~p...~n", [self()]),
  receive 
    { hello, From } -> io:format("Hello, ~p!~n", [From]) , myThread() ; 
    { sum_even, List } -> io:format("Sum even of ~p is ~p~n", [List, sum_even(List)]), myThread() ;
    { send_random, From} -> From ! random, myThread() ;
    _ -> io:format("Unknown command~n"), myThread()
  end. 

main(_) -> 
  io:format("O   diimineata ~p  ..... FRUMOASA ~p !!! .... ~n Spor la cafeluta ! ~n", [[1,2,3], 2]),
  Sum = sum(2, 5),
  io:format("Suma este ~p~n", [Sum]),
  X = 10,
  io:format("Fibo(~p) = ~p~n", [X, fibo(X)]),
  L = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  io:format("Suma elementelor pare din ~p este ~p~n", [L, sum_even(L)]),
  io:format("Map (+1) ~p = ~p~n", [L, lists:map(fun(X) -> X + 1 end, L)]),
  People = [{andrew, male, 42}, {olivia, female, 35}, {peter, male, 60}, {andy, male, 25}, {mary, female, 36}],
  % determinam numele barbatilor care au peste 40 de ani -> [andrew, peter] 
  FilteredPeople = lists:filter(fun ({_, Gender, Age}) -> Gender == male andalso Age >= 40 end, People),
  io:format("Barbatii peste 40 de ani sunt ~p~n", [lists:map(fun ({Name, _, _}) -> Name end, FilteredPeople)]),
  Pid = spawn(fun () -> myThread() end),
  io:format("Pornim thread-ul ~p~n", [Pid]),
  Pid ! { hello, self() }, 
  Pid ! taci,
  Pid ! { sum_even, L },
  Pid ! { send_random, self() },
  receive
    random -> io:format("Am primit~n"); 
    _ -> io:format("Unknown command")
  end,
  timer:sleep(500),
  MyList = [N || N <- L, N rem 2 =:= 0],
  io:format("MyList = ~p~n", [MyList]).

% Problema
% Scrieti un thread care primeste mesaje constituind operatii pe liste,
% de forma {map, plus_1, , list, From}, 
% {filter, odd, list, From}
% {sum, List, From}
% {product, List, From}
% comanda invalida

pbThread() ->
    receive 
        {map, plus_1, L, From} -> 
            NewList = lists:map(fun(X) -> X + 1 end, L),
            io:format(
                "Rezultat map + 1: ~p de la ~p ~n", 
                [NewList,From]
            ), pbThread();
        {filter, odd, L, From} -> 
            NewList = [N || N <- L, N rem 2 =:= 1],
            io:format(
                "Rezultat filter odd: ~p de la ~p ~n", 
                [NewList,From]
            ), pbThread();
        {filter, even, L, From} -> 
            NewList = [N || N <- L, N rem 2 =:= 0],
            io:format(
                "Rezultat filter even: ~p de la ~p ~n", 
                [NewList,From]
            ), pbThread();
        {sum, L, From} -> 
            Res = lists:foldr(fun(X,Y) -> X + Y end, 0, L),
            io:format(
                "Rezultat sum: ~p de la ~p ~n", 
                [Res, From]
            ), pbThread();
        {prod, L, From} -> 
            Res = lists:foldr(fun(X,Y) -> X * Y end, 1, L),
            io:format(
                "Rezultat prod: ~p de la ~p ~n", 
                [Res, From]
            ), pbThread();
        _ -> io:format("Comanda invalida lol~n"), pbThread()
    end,
    timer:sleep(500).

main2(_) ->
    NewTh = spawn(lab10, pbThread, []),
    L = [1,2,3,4,5],
    NewTh ! {sum, L, self()},
    NewTh ! {prod, L, self()},
    timer:sleep(700).

