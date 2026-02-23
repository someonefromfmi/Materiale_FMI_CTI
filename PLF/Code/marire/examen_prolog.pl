% zip/3 - face perechi de elemente de pe aceeasi pozitie intre doua liste
% ?- zip([1,2,3],[a,b,c],Res). atunci Res = [(1, a), (2, b), (3, c)]
% zip se opreste la lungimea celei mai scurte dintre cele doua liste! 
% ?- zip([1,2,3,4],[a,b,c],Res). atunci Res = [(1, a), (2, b), (3, c)]
% ?- zip([1,2,3],[a,b,c,d,e],Res). atunci Res = [(1, a), (2, b), (3, c)]
zip([], _, []) :- !.
zip(_, [], []) :- !.
zip([H1 | T1], [H2 | T2], [(H1, H2) | TR]) :-
    zip(T1, T2, TR).

% II
rep([], _, []).
rep(L , X, [HR|TR]) :-
    LEN is length(L),
    numlist(1, LEN, Range),
    zip(L, Range, [(Val, Poz)|T]),
    Poz mod 2 =:= 1,
    HR = X,
    rep(T, X, TR).

rep(L , X, [HR|TR]) :-
    LEN is length(L),
    numlist(1, LEN, Range),
    zip(L, Range, [(Val, Poz)|T]),
    Poz mod 2 =:= 0,
    HR = Val,
    rep(T, X, TR).

% I
graph([a,b,c,d,e], [(a,b,3), (b,c,5)]).

% a)
izol(TR) :-
    graph([HR|T], [(HR,_,_)|TM]),
    izol(TR).
izol(TR) :-
    graph([HR|T], [(_,HR,_)|TM]),
    izol(TR).
izol([HR|TR]) :-
    graph([HR|T], [(_,_,_)|TM]),
    izol(TR).
izol([]).

% b
sumVf(Name,0) :-
    izol(Name).
sumVf(Name,Acc,Res) :-
    graph(LVf, [(Name, _, Cost) | T]),
    member(Name, LVf),
    Res is Acc + Cost,
    sumVf(Name, Acc).
sumVf(Name,Acc,Res) :-
    graph(LVf, [(_, Name, Cost) | T]),
    member(Name, LVf),
    Res is Acc + Cost,
    sumVf(Name, Acc).
    




