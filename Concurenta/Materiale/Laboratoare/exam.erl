-module(exam).
-compile(export_all). %% Exports everything so we can test easily

%% --- MAIN TEST FUNCTION ---
start() ->
    %% 1. Start the Terminal
    TerminalPid = start_terminal(),
    io:format("System: Terminal started at ~p~n", [TerminalPid]),

    %% 2. Start 3 Persons at the same time
    %% They will compete for the terminal
    start_person(TerminalPid),
    start_person(TerminalPid),
    start_person(TerminalPid).

start_terminal() ->
    spawn(fun() -> loop_terminal(idle, none) end).

loop_terminal(State, From)->
    case State of idle ->
        receive 
            {request, Person} ->
                io:format("Terminal: Request received from ~p. Granting access.~n", [Person]),
                Person ! access_granted, 
                loop_terminal(in_use, Person)
        end;
    in_use -> timer:sleep(3000),
        io:format("Terminal: Access period over for ~p. Revoking access.~n", [From]),
        From ! access_revoked,
        loop_terminal(idle, none)
    end.
           

start_person(TerminalPid) ->
    spawn(fun () -> loop_person(waiting, TerminalPid) end).

loop_person(State, TerminalPid) ->
    case State of waiting ->
        TerminalPid ! {request, self()},
        io:format("Person ~p: Waiting for terminal access.~n", [self()]),
        receive
            access_granted ->
                loop_person(searching, TerminalPid)
        end;
    searching ->
        io:format("Person ~p: Using terminal.~n", [self()]),
        receive
            access_revoked ->
                loop_person(waiting, TerminalPid)
        end
    end.
            