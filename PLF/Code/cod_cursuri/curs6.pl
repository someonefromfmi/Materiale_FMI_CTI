% Cut
a(1).
b(1). b(2).
c(1). c(2).
d(2). e(2).
f(3).

p(X) :- a(X).
p(X) :- b(X), c(X), !, d(X), e(X).
p(X) :- f(X).

% Green cut - pt a evita backtracking-ul nedorit
range(X, 'A') :- X < 3,!.
range(X, 'B') :- 3 =< X, X < 6,!.
range(X, 'C') :- 6 =< X.

% Red cut - afecteza logica programului, trb evitat
rrange(X, 'A') :- X < 3,!.
rrange(X, 'B') :- X < 6,!.
rrange(X, 'C').

% Probleme cu cut
% add(Element, List, List) :-
%     member(Element, List), !.
% add(Element, List, [Element|List]).

% Solutie alternativa
add(Element, List, Result) :-
    member(Element, List), !,
    Result = List.
add(Element,List, [Element|List]).


% Negarea unui predicat
% ? explicat aici poate
neg(Goal) :- Goal, !, fail.
neg(Goal).

married(peter, lucy).
married(paul, marcy).
married(bob, juliet).
married(harry, geraldine).
% married(john, anne).
% largind baza de cunostinte putem dem mai putin
% acest tip de rationament sn rationament nemonoton
single(Person) :-
    \+ married(Person, _),
    \+ married(_, Person).

% Lista tuturor solutiilor
q(a). q(b). q(c). q(d). q(a).

% Ex.: Fie un pred r/1. Scrieti un pred all_r/1
% a.i. intrebarea ?- all_r(S) sa instantieze S
% cu lista tuturor atomilor pt care r este adev.
r(a). r(b). r(c). r(d). r(a).

find_all(X, L, S) :- r(X), \+ member(X, L),
                    find_all(_, [X|L], S).
find_all(_, L, L).

all_r(S) :- find_all(_, [], S).
% ? ceva ciudat aici

% Predicate ca argumente
find_all(P,X, L, S) :- Pr =..[P,X],Pr, \+ member(X, L),
                    find_all(_, [X|L], S).
find_all(_,_, L, L).

all(P, S) :- find_all(P, _, [], S).

%DCG
% s(L) :- np(X), vp(Y),
%         append(X,Y,L).
% np(L) :- det(X), n(Y),
%          append(X,Y,L).
% vp(L) :- v(L).
% vp(L) :- v(X), np(Y),
%          append(X,Y,L).

% det([the]).
% det([a]).
% n([boy]).
% n([girl]).
% v([loves]).
% v([hates]).

% DCG in Prolog
s --> np, vp.
np --> det, n.
vp --> v.
vp --> v, np.

det --> [the].
det --> [a].
n --> [boy].
n --> [girl].
v --> [loves].
v --> [hates].

% Ex: Definiti numerele naturale folosind DCG

nat --> [o].
nat --> [s], nat.

is_nat(X) :- phrase(nat,Y), atomic_list_concat(Y,'',X).
