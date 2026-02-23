% Laboratorul 3

% Exercitiul 1

vars(X, [X]) :- atom(X).
vars(non(P), Res) :- vars(P, Res).
vars(imp(P, Q), Res) :-
    vars(P, ResP),
    vars(Q, ResQ),
    union(ResP, ResQ, Res).
vars(and(P, Q), Res) :-
    vars(P, ResP),
    vars(Q, ResQ),
    union(ResP, ResQ, Res).
vars(or(P, Q), Res) :-
    vars(P, ResP),
    vars(Q, ResQ),
    union(ResP, ResQ, Res).

% Exercitiul 2

val(X, [(X, E) | _], E) :- !.
val(X, [_ | T], E) :-
    val(X, T, E).

% Exercitiul 3

bnon(0, 1) :- !.
bnon(1, 0) :- !.
bor(1, _, 1) :- !.
bor(_, 1, 1) :- !.
bor(0, 0, 0) :- !.
bimp(P, Q, Res) :-
    bnon(P, NonP),
    bor(NonP, Q, Res).
band(P, Q, Res) :-
    bnon(P, NonP),
    bnon(Q, NonQ),
    bor(NonP, NonQ, NonRes),
    bnon(NonRes, Res).

% Exercitiul 4 

eval(X, List, Res) :- val(X, List, Res).
eval(non(P), List, Res) :-
    eval(P, List, ResP),
    bnon(ResP, Res).
eval(imp(P, Q), List, Res) :-
    eval(P, List, ResP),
    eval(Q, List, ResQ),
    bimp(ResP, ResQ, Res).
eval(and(P, Q), List, Res) :-
    eval(P, List, ResP),
    eval(Q, List, ResQ),
    band(ResP, ResQ, Res).
eval(or(P, Q), List, Res) :-
    eval(P, List, ResP),
    eval(Q, List, ResQ),
    bor(ResP, ResQ, Res).


% Exercitiul 5

evals(_, [], []) :- !.
evals(P, [H | T], [HR | TR]) :-
    eval(P, H, HR),
    evals(P, T, TR).

% Exercitiul 6

cartesian_product([], _, [_], []) :- !.
cartesian_product([], L1, [_ | T2], R) :-
    cartesian_product(L1, L1, T2, R).
cartesian_product([H1 | T1], L1, [H2 | T2], [HR | TR]) :-
    append(H1, H2, HR),
    cartesian_product(T1, L1, [H2 | T2], TR).

cartesian_product(L1, L2, R) :- 
    cartesian_product(L1, L1, L2, R).

repeat(L, 1, L) :- !.
repeat(L, N, Result) :-
    cartesian_product(L, [[0],[1]], TempResult),
    NewN is N - 1,
    repeat(TempResult, NewN, Result).

repeat(RepNumber, Result) :-
    repeat([[0],[1]], RepNumber, Result).

zip([], _, []) :- !.
zip(_, [], []) :- !.
zip([H1 | T1], [H2 | T2], [(H1, H2) | TR]) :-
    zip(T1, T2, TR).

ziplist(_, [], []) :- !.
ziplist(L, [H | T], [HR | TR]) :-
    zip(L, H, HR),
    ziplist(L, T, TR).

evs(Vars, Es) :-
    length(Vars, Length),
    repeat(Length, AllEvals),
    ziplist(Vars, AllEvals, Es).

% Exercitiul 7

all_evals(Form, Res) :-
    vars(Form, Vars),
    evs(Vars, AllEvals),
    evals(Form, AllEvals, Res).

% Exercitiul 8

all_eq_1([1]) :- !.
all_eq_1([1 | T]) :- all_eq_1(T).

taut(Form) :-
    all_evals(Form, Evals),
    all_eq_1(Evals).