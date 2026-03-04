-module(s3).
-export([main/1]).

start_compresor() -> 
    spawn(fun() -> compresor_loop(free, []) end).

compresor_loop(State, Queue) ->
    io:format("Compresor: ~p, coada: ~p~n", [State, length(Queue)]),
    receive
        {request_access, IngPid} when State =:= free ->
          io:format("Permit accesul ~p~n", [IngPid]),
          IngPid ! {access_granted, self()},
          compresor_loop(busy, Queue);
        {request_access, IngPid} when State =:= busy ->
          io:format("Compresor ocupat, ~p sta la coada ~n", [IngPid]),
          IngPid ! {access_denied, self()},
          compresor_loop(State, Queue ++ [IngPid]);
        {release_comp, _IngPid} ->
          case Queue of
              [Next | Rest] ->
                  io:format("Inginerul ~p primeste acces ~n", [Next]),
                  Next ! {access_granted, self()},
                  compresor_loop(busy, Rest);
              [] -> compresor_loop(free, [])
          end;
      _Other -> compresor_loop(State, Queue)
  end.

start_ing(CompPid) ->
    spawn(fun() -> ing_loop(waiting, CompPid) end).

ing_loop(waiting, CompPid) ->
    io:format("Inginerul ~p asteapta ~n", [self()]),
    CompPid ! {request_access, self()},
    receive
        {access_granted, _} ->
            io:format("Acces permis pentru inginerul ~p ~n", [self()]),
            ing_loop(mastering, CompPid);
        _ -> 
            timer:sleep(1000),
            ing_loop(waiting, CompPid)
    end;
ing_loop(mastering, CompPid) ->
    io:format("Inginerul ~p foloseste compresorul ~n", [self()]),
    timer:sleep(3000),
    io:format("Inginerul ~p a terminat~n", [self()]),
    CompPid ! {release_comp, self()},
    timer:sleep(2000),
    ing_loop(waiting, CompPid).

main(_) -> 
    CompPid = start_compresor(),
    _ = start_ing(CompPid),
    _ = start_ing(CompPid),
    _ = start_ing(CompPid),
    _ = start_ing(CompPid),
    _ = start_ing(CompPid),
    timer:sleep(3000).
