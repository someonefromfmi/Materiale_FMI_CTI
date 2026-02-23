% definim operatorii {} si ;
:- op(100, xf, {}).
:- op(1100, yfx, ;). % asoc la stg

% expresii aritmetice
aexp(I) :- integer(I).
aexp(X) :- atom(X).
aexp(A1 + A2) :- aexp(A1), aexp(A2).
aexp(A1 - A2) :- aexp(A1), aexp(A2).
aexp(A1 * A2) :- aexp(A1), aexp(A2).

% expresii booleene
bexp(true). bexp(false).
bexp(and(BE1, BE2)) :- bexp(BE1), bexp(BE2).
bexp(or(BE1, BE2)) :- bexp(BE1), bexp(BE2).
bexp(A1 =< A2) :- aexp(A1), aexp(A2).
bexp(not(X)) :- bexp(X).

% instructiunile
stmt(while(BE, St)) :- bexp(BE), stmt(St).
stmt(skip).
stmt(X = AE) :- atom(X), aexp(AE).
stmt(St1;St2) :- stmt(St1), stmt(St2).
stmt(if(BE, St1, St2)) :- bexp(BE), stmt(St1), stmt(St2).
stmt({St}) :- stmt(St).

% programe
program(St, AE) :- stmt(St), aexp(AE).

test0 :- program( {x = 10 ; sum = 0;
                    while(0 =< x,
                        {sum = sum + x; x = x - 1}
                        )}
                    , sum).

% Reprezentarea starilor in prolog
get(S, X, I) :- member(vi(X, I),S).
get(_, _, 0).

set(S,X,I, [vi(X,I)|S1]) :- del(S, X, S1).

del([vi(X,_)|S],X,S).
del([H|S],X,[H|S1]) :- del(S,X,S1).
del([], _, []).

% semantica expresiilor aritmetice
% semantica undei variabile
smallstepA(X,S,I,S) :-
    atom(X),
    get(S,X,I).

% semantica adunarii a doua expresii aritmetice
smallstepA(I1 + I2, S, I, S) :- 
    integer(I1), integer(I2),
    I is I1 + I2.

smallstepA(I + AE1, S, I + AE2, S) :-
    integer(I),
    smallstepA(AE1, S, AE2, S).

% semantica scaderii a doua expresii aritmetice
smallstepA(I1 - I2, S, I, S) :- 
    integer(I1), integer(I2),
    I is I1 - I2.

smallstepA(I - AE1, S, I - AE2, S) :-
    integer(I),
    smallstepA(AE1, S, AE2, S).

% semantica * si - se definesc similar

%% e bn?
smallstepA(AE1 + AE, S, AE2 + AE, S) :- 
    smallstepA(AE1, S, AE2, S).

smallstepA(AE1 - AE, S, AE2 - AE, S) :- 
    smallstepA(AE1, S, AE2, S).

% semantica expresiilor booleene
smallstepB(I1 =< I2, S, true, S) :-
    integer(I1), integer(I2),
    (I1 =< I2).
smallstepB(I1 =< I2, S, false, S):-
    integer(I1), integer(I2),
    (I1 > I2).

% smallstepB(I =< AE1, S, I =< AE2, S) :- ...
% smallstepB(AE1 =< AE2, S, AE2 =< AE, S) :- ...

% semantica negatiei
smallstepB(not(true), S, false, S).
smallstepB(not(false), S, false, S).

% smallstepB(not(BE1), S, not(BE2), S) :- ...

% semantica compunerii si a blocurilor
smallstepS({E}, S, E, S).
smallstepS((skip;St2), S, St2, S).
% smallstepS((St1;St), S, (St2;St), S) :- ...

% semantica atribuirii
smallstepS(X = AE, S, skip, S1) :-
    integer(AE),
    set(S,X,AE,S1).

% smallstepS(X = AE1, S, X = AE2, S) :- ...

% semantica lui if
smallstepS(if(true, St1, _), S, St1, S).
smallstepS(if(false, _, St2), S, St2, S).

% smallstepS(if(BE1, ST1, St2), S, if(BE2, St1, St2), S) :- ...

% semantica lui while
smallstepS(while(BE, St), S, if(BE, (St;while(BE,St)), skip), S).

% semantica programelor
smallstepP(skip, AE1, S1, skip, AE2, S2) :-
    smallstepA(AE1, S1, AE2, S2).
smallstepP(St1, AE, S1, St2, AE, S2) :-
    smallstepA(St1, S1, St2, S2).

% executia programelor
run(skip, I, _, I) :- integer(I).
run(St1, AE1, S1, I) :- smallstepP(St1, AE1, S1, St2, AE2, S2),
                        run(St2, AE2, S2, I).

run_program(Name) :- defpg(Name, {P}, E), run(P, E, [], I),
                     write(I).

defpg(pg2, {x = 10; sum = 0; while(0 =< x, {
    sum = sum + x;
    x = x - 1})}, sum).

% executia programelor: trace
mytrace(skip, I, _) :- integer(I).
mytrace(St1, AE1, S1) :- 
    smallstepP(St1, AE1, S1, St2, AE2, S2),
    write(St2), nl,
    write(AE2), nl,
    write(S2), nl,
    mytrace(St2,AE2,S2).
trace_program(Name) :- 
    defpg(Name, {P}, E),
    mytrace(P, E, []).



