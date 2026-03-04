% sum / 2
sum(X, Y) -> X + Y. 

% fibo / 1
fibo(X) when X < 1 -> 0;
fibo(X) when X =:= 1 -> 1;
fibo(X) -> fibo(X - 1) + fibo(X - 2).

% sum_even / 1
sum_even([]) -> 0;
sum_even([H | T]) -> 
  if H rem 2 =:= 0 ->
    H + sum_even(T);
  true -> sum_even(T)
  end.
  
% functiile inline (anonime) au sintaxa fun (arg) -> body end

% pentru a porni un thread se foloseste functia spawn
% spawn(inline function)

% Pid ! msg
% receive ... end.

myThread() -> 
  io:format("Hello from thread ~p~n", [self()]),
  receive
    {hello, From} -> io:format("Hello ~p~n", [From]), myThread();
    {sum_even, List} -> io:format("Sumeven of ~p is ~p~n", [List, sum_even(List)]), myThread();
    {send_random, From} -> From ! random, myThread();
    _  -> io:format("Unknown cmd~n"), myThread()
  end.
  
% scrieti un thread care primeste mesaje continand operatii pe lista de forma (
%  {map, plus_1, list ,From},
%  {filter, odd, List, From},
%  {sum, List, From},
%  {product, List, From}).

list_proc() ->
  receive
    {map, plus_1, List, From} -> From ! lists:map(fun(X) -> X + 1 end, List), list_proc();
    {filter, odd, List, From} -> From ! lists:filter(fun(X) -> X rem 2 =:= 1 end, List), list_proc();
    {sum, List, From} -> From ! sum_even(List), list_proc();
    {product, List, From} -> From ! sum_even(List), list_proc(); 
    _ -> io:format("idk bro")
  end.

main(_) -> 
  io:format("Hello, world ~p!~n", [2]),
  Sum = sum(2,3),
  io:format("Suma este ~p~n", [Sum]),
  X = 10,
  io:format("Fibo(~p) = ~p~n", [X, fibo(X)]),
  L = [1,2,3,4,5,6,7,8,9,10],
  io:format("Suma elem pare din ~p este ~p~n", [L, sum_even(L)]),
  io:format("Map (+1) ~p = ~p~n", [L, lists:map(fun(X) -> X + 1 end, L)]),
  People = [{andreo, male, 42}, {olivia, female, 35}, {peter, male, 60}, {andy, male, 25}, {mary, female, 36}],
  % determinam numele barb care au peste 40 de ani -> [andreo, peter]
  FilteredPeople = lists:filter(fun({_, Gender, Age}) -> Gender == male andalso Age >= 40 end, People),
  io:format("Barbatii peste 40 de ani sunt ~p~n", [lists:map(fun({Name, _, _}) -> Name end, FilteredPeople)]),
  Pid = spawn(fun () -> myThread() end),
  io:format("Pornim thread ul cu pid ~p~n", [Pid]),
  Pid ! {hello, self()},
  Pid ! taci,
  Pid ! {sum_even, L},
  Pid ! {send_random, self()},
  receive
    random -> io:format("Am primit~n");
    _ -> io:format("Unknown command")
  end,
  timer:sleep(500),
  MyList = [N || N <- L, N rem 2 =:= 0],
  io:format("MyList = ~p~n", [MyList]),
  Pp = spawn(fun() -> list_proc() end),
  Pp ! {map, plus_1, L, self()},
  receive
    Msg -> io:format("Response recceived ~p~n", [Msg]);
    _ -> io:format("cry")
  end
  .