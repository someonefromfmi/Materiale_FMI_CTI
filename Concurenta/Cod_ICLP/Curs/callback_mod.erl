-module(callback_mod).
-export([client1/1, client2/1, handle/1]).
-import(c12, [client/2]).

%% client
client1(N) -> client(myserver, {add, N}).
client2(Name) -> client(c12, {hello, Name}).

%% callback
handle({add, N}) -> {ok, N + 1};
handle({hello, Name}) -> {ok, "hello " ++ Name}.

%% ! modulul nu contine nimic legat de concurenta!