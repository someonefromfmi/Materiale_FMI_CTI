-module(c11).
-export([
    start/0, squirrel/1, pet/1, bark/0, wag_tail/0,
    sit/0, myproc/0, chain/1, mytry/1, start_critic/0,
    start_critic1/0, critic/0, judge1/2, restarter/0,
    judge2/2, start_critic2/0, critic2/0
]).

% implementarea unui automat finit
squirrel(Pid) -> Pid ! squirrel.

pet(Pid) -> Pid ! pet.

start() ->
    spawn(fun() -> bark() end). % starea initiala

bark() -> 
    io:format("Dog says: BARK! BARK!~n"),
    receive
        pet -> wag_tail();
        _ -> io:format("Dog is confused~n"),
        bark()
    after 2000 -> bark()
end. 

wag_tail() -> 
    io:format("Dog wags tail!~n"),
    receive
        pet -> sit();
        _ -> io:format("Dog is confused~n"),
        wag_tail()
    after 30000 -> bark() % actiunea waits
end. 

sit() -> 
    io:format("Dog is sitting! Goooood boy!~n"),
    receive
        squirrel -> bark();
        _ -> io:format("Dog is confused~n"),
        sit()
    after 30000 -> bark() % actiunea waits
end. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tratarea erorilor

myproc() ->
    timer:sleep(5000),
    exit(reason).

chain(0) -> 
    receive
        _ -> ok
    after 2000 ->
        exit("chain dies here")
    end;

chain(N) -> 
    Pid = spawn(fun() -> chain(N-1) end),
    link(Pid),
    receive
        _ -> ok
    end.

mytry(Reason) -> 
    try myproc() of
        _ -> ok
    catch
        exit:Reason -> io:format("caught ~p~n", [Reason]),
        mytry(Reason)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_critic() ->
    spawn(?MODULE, critic, []).

critic() ->
    receive
        {From, {"Rage Against the Turing Machine", "Unit Testify"}} -> 
            From ! {self(), "They are great!"};
        {From, {_Band, _Album}} -> 
            From ! {self(), "They are terrible!"}
    end.

judge1(Band, Album) ->
    critic ! {self(), {Band, Album}},
    Pid = whereis(critic),
    receive
        {Pid, Criticism} -> Criticism
    after 2000 -> timeout
    end.

start_critic1() ->
    spawn(?MODULE, restarter, []).

restarter() ->
    process_flag(trao_exit, true),
    Pid = spawn_link(?MODULE, critic, []),
    register(critic, Pid),
    receive
        {'EXIT', Pid, normal} -> % not a crash
                                ok;
        {'EXIT', Pid, shutdown} -> % manual termination
                                ok;
        {'EXIT', Pid, _} -> restarter()
    end.

judge2(Band, Album) -> 
    Ref = make_ref(),
    critic ! {self(), Ref, {Band, Album}},
    receive
        {Ref, Criticism} -> Criticism
    after 200 ->
        timeout
    end.

critic2() ->
    receive
        {From, Ref, {"Rage Against the Turing Machine", "Unit Testify"}} -> 
            From ! {Ref, "They are great!"};
        {From, Ref, {_Band, _Album}} -> 
            From ! {Ref, "They are terrible!"}
    end.

start_critic2() ->
    spawn(?MODULE, restarter, []).