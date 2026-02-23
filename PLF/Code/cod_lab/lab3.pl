/*
Liste in Prolog
[1, [], x, f(X,Y), ...]
nu au restrictii pe tipuri de date
generate plecand de la ([]-lista vida, | - append) => constructorii listei
Forma generala este [H - primul elem ala listei|T - lista elem ramase]

Alg pe liste ii impl recursiv. Ca forma generala:
alg([],...)
alg([H|T], ...) :- ... alg(T,...)....
*/

%% 7. scalarMult/3 - primeste,un scalar o lita de intregi, returneaza in al 3 lea
%% arg lista nou formata, prin inmultirea fiecarui element cu scalarul
scalarMult(_, [], []):-!.
scalarMult(X, [H|T], [HR|TR]):-
    HR is X*H,
    scalarMult(X,T,TR).

%% Ex8. dot/3
%% I = lista de intregi
%% II = au aceeasi lungime
dot([], [], 0):-!.
dot([H1|T1], [H2|T2], Res):-
    dot(T1, T2, ResT),
    Res is ResT + H1*H2.

%% concat_lists/3
%%  I, II - liste
%% lista formata prin concatenare
concat_lists([], X, X) :- !.
concat_lists([H|T], L2, [H|TR]) :-
    concat_lists(T, L2, TR).

%% zip/3 - I, II liste, nu neaparat de lung egale, returneaza o lista de perechi,
%% formate din elem de pe aceeasi pozitie
zip([], _, []) :- !.
zip(_, [], []) :- !.
zip([H1|T1], [H2|T2], [(H1, H2)|TR]):-
    zip(T1,T2,TR).

%% cartesian_product
cartesian_product(_, _, [], []) :- !.
cartesian_product([], L1, [_|T2], Res) :-
    cartesian_product(L1, L1, T2, Res).
cartesian_product([H1|T1], L1, [H2|T2], [(H1,H2)|TR]) :-
    cartesian_product(T1, L1, [H2|T2], TR).

%% ii facem wrapper
cartesian_product(L1, L2, Res) :- cartesian_product(L1, L2, L2, Res).

elements_of(X, [X|_]) :- !.
elements_of(X, [_|T]) :-
    elements_of(X, T).

remove_duplicates([], []).
remove_duplicates([H|T], TR) :-
    elements_of(H, T),
    remove_duplicates(T, TR).
remove_duplicates([H|T], [H|TR]) :-
    not(elements_of(H, T)),
    remove_duplicates(T, TR).

%% bagof/3
%% setof/3 scoate duplicatele

