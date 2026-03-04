-module(lab11).
-export([
    server_loop/0, client/2, client_loop/3, main/1,
    client/3, map_parallel/2
]).

% Examen: 2 ore
% Concurenta standard, 3p
% Haskell (STM, canale, def de canale cu tipuri custom), 3p
% Erlang (automat) 3p
% oficiu 1p oficiu, 2p prezenta lab
% receive...end pentru transmiterea mesajelor
% Pid ! message pentru transmiterea mesajelor
% spawn(anon function) pentru a crea un thread
% fun (args) -> body end functii anonime
server_loop() ->
    receive
        {From, {double, Number}} -> 
            From ! {self(), Number * 2},
            server_loop();
        {From, {triple, Number}} ->
            From ! {self(), Number * 3},
            server_loop();
        {From, {succ, Number}} ->
            From ! {self(), Number + 1},
            server_loop();
        {From, {add, Number, ToAdd}} ->
            From ! {self(), Number + ToAdd},
            server_loop();
        {From, {mul, Number, ToMul}} ->
            From ! {self(), Number * ToMul},
            server_loop();
        {From, _} -> 
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
    ServerPid ! {self(), "end"}, L;
client_loop(ServerPid, X, L) ->
    R = client(ServerPid, {double, X}),
    io:format("double(~p) = ~p~n", [X, R]),
    client_loop(ServerPid, X - 1, [R|L]).

parallel_client_loop(ServerPid, Length) ->
    Parent = self(),
    Pids = [spawn(fun () -> client(ServerPid, Parent, {double, X}) end) 
        || X <- lists:seq(Length, 1, -1)],
    gather_results(length(Pids), []).

map_parallel(F, List) ->
    Parent = self(),
    Pids = [spawn(fun () -> Parent ! {self(), F(X)} end )|| X <- List],
    collect(Pids).

collect([]) -> [];
collect([Pid|Rest]) ->
    receive
        {Pid, Result} -> [Result | collect(Rest)]
    end.

gather_results(0, List) -> List;
gather_results(N, List) ->
    receive
        {_Pid, X, R} -> gather_results(N-1, [{X,R} | List])
    end.

main(_) -> 
    Server = spawn(fun () -> server_loop() end),
    Results = parallel_client_loop(Server, 5),
    io:format("~p~n", [Results]).
    % Server ! {self(), {double, 3}},
    % receive
    %     {From, Result} -> 
    %         io:format("Result from Server ~p is ~p~n", [From, Result]);
    %     {From, error} ->
    %         io:format("Error from ~p~n", [From])
    %     end.

% Exercitii
% 1. Completati cu alte tipuri de requesturi, nu doar {double, X} 
% 2. In loc de parallel_client_loop, definiti o functie map_parallel, care simuleaza acelasi comportament
%  mapeaza o functie pe o lista si permite procesarea aceasta in paralel 
% 3. Sa ajungeti voi la 3
% 4. Diferentele intre tipurile de extinctoare; cum se foloseste furtunul pentru stins incendii?
