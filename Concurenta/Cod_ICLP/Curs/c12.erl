-module(c12).
-export([
    start/2, client/2
]).

start(Name, Mod) -> register(Name, spawn(fun() -> loop(Name, Mod) end)).

client(Name, Request) -> 
    Name ! {self(), Request},
    receive
        {Name, Response} -> Response
    end.

loop(Name, Mod) ->
    receive
        {From, Request} -> Response = Mod:handle(Request),
        From ! {Name, Response},
        loop(Name, Mod)
    end.
