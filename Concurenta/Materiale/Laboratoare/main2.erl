% receive ... end         pentru primirea mesajelor 
% Pid ! message           pentru transmiterea mesajelor 
% spawn(anon function)    pentru a crea un thread 
% fun (args) -> body end  functii anonime 


server_loop() ->
  receive 
    {From, {double, Number}} ->
      From ! {self(), Number * 2}, 
      server_loop(); 
    {From, {square, Number}} ->
      From ! {self(), Number * Number}, 
      server_loop(); 
    {From, {plus_1, Number}} ->
      From ! {self(), Number + 1}, 
      server_loop(); 
    {From, _ } -> 
      From ! {self(), error},
      server_loop() 
  end. 

client(ServerPid, Request) ->
  ServerPid ! {self(), Request}, 
  receive 
    {ServerPid, Response} -> Response
  end.
  
client(ServerPid, Parent, Request) -> 
  R = 
    begin 
      ServerPid ! {self(), Request},
      receive 
        {ServerPid, Response} -> Response 
      end
    end,
  Parent ! {self(), Request, R}. 

client_loop(ServerPid, 0, L) -> 
  ServerPid ! {self(), "end"}, 
  L; 
client_loop(ServerPid, X, L) -> 
  R = client(ServerPid, {double, X}),
  io:format("double(~p) = ~p~n", [X, R]),
  client_loop(ServerPid, X - 1, [R | L]).
  
parallel_client_loop(ServerPid, Length) -> 
  Parent = self(), 
  Pids = [spawn(fun () -> client(ServerPid, Parent, {double, X}) end) || X <- lists:seq(Length, 1, -1)],
  gather_results(length(Pids), []).
  
map_parallel(ServerPid, Length, Action) ->
  Parent = self(),
  Pids = lists:map(fun(X) -> spawn(fun() -> client(ServerPid, Parent, {Action, X}) end) end, lists:seq(Length, 1, -1)),
  gather_results(length(Pids), []).
  
gather_results(0, List) -> List; 
gather_results(N, List) -> 
  receive 
    {_Pid, X, R} -> gather_results(N-1, [{X, R} | List])
  end. 

main(_) -> 
  Server = spawn(fun () -> server_loop() end),
  Results = map_parallel(Server, 5, double),
  io:format("Parallel results: ~p~n", [Results]).
  % Result = client_loop(Server, 10, []),
  % io:format("Result is ~p~n", [Result]).
  % Response = client(Server, {double, 3}),
  % io:format("~p~n", [Response]).
  
  % Server ! {self(), {double, 3}},
  % receive 
  %   {From, Result} ->
  %    io:format("Result from Server ~p is ~p~n", [From, Result]);
  %   {From, error} ->
  %   io:format("Error from ~p~n", [From])
  % end.
  % Exercitii laborator
  % 1. Completati cu alte tipuri de requesturi, nu doar {double, X} 
  % 2. In loc de parallel_client_loop, definiti o functie map_parallel, care simuleaza acelasi comportament
  %  mapeaza o functie pe o lista si permite procesarea aceasta in paralel 
  % 3. Sa ajungeti voi la 3 