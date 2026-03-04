-module(sub3).
-export([main/1]).

start_terminal() -> 
    spawn(fun() -> terminal_loop(idle, []) end).

terminal_loop(State, Queue) ->
    io:format("Terminal: ~p, coada: ~p~n", [State, length(Queue)]),
    receive
        {request_access, StudentPid} when State =:= idle ->
            io:format("Permit accesul ~p~n", [StudentPid]),
            StudentPid ! {access_granted, self()},
            terminal_loop(in_use, Queue);
        {request_access, StudentPid} when State =:= in_use ->
            io:format("Terminal ocupat, ~p sta la coada ~n", [StudentPid]),
            StudentPid ! {access_denied, self()},
            terminal_loop(State, Queue ++ [StudentPid]);
        {release_terminal, _StudentPid} ->
            case Queue of
                [Next | Rest] ->
                    io:format("Studentul ~p primeste acces ~n", [Next]),
                    Next ! {access_granted, self()},
                    terminal_loop(in_use, Rest);
                [] -> terminal_loop(idle, [])
            end;
        _Other -> terminal_loop(State, Queue)
    end.

start_student(TermPid) ->
    spawn(fun() -> student_loop(waiting, TermPid) end).

student_loop(waiting, TermPid) ->
    io:format("Studentul ~p asteapta ~n", [self()]),
    TermPid ! {request_access, self()},
    receive
        {access_granted, _} ->
            io:format("Acces permis pentru studentul ~p ~n", [self()]),
            student_loop(searching, TermPid);
        _ -> 
            timer:sleep(1000),
            student_loop(waiting, TermPid)
    end;
student_loop(searching, TermPid) ->
    io:format("Studentul ~p cauta ~n", [self()]),
    timer:sleep(3000),
    io:format("Studentul ~p a terminat~n", [self()]),
    TermPid ! {release_terminal, self()},
    timer:sleep(2000),
    student_loop(waiting, TermPid).

main(_) -> 
    TermPid = start_terminal(),
    _ = start_student(TermPid),
    _ = start_student(TermPid),
    _ = start_student(TermPid),
    _ = start_student(TermPid),
    _ = start_student(TermPid),
    timer:sleep(3000).
