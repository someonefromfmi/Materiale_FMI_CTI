/*Implementrea semanticii propozitionale in prolog
-verif daca o formula fi este tautologie*/
%% fi tautologie ddaca pt orice e:Var-{0,1} avem ca e taut fi
% I. Reprezentare [->, not, si, sau]
% imp/2
% non/1
% and/2
% or/2


% II. Vars(fi), vars:Form->P(Var) 
% P(Var) = 2^Var

% III. e, e+
% eval(imp(p, non(q)), [(p,1), (2,0)])

% IV. e+ pe mai multe linii
% [(p,1), (q,0), [(p,0), (q,1)]]

% V. generare de tabel de adev

% VI. fi taut

%% Ex1: vars/2
% vars(+Form, -Varlist)
% lista intoarce variab propoz din form

% pt a identif variab propoz
% le const pt a fi atomi din prolog
%fi ::= p | non (fi) | (fi -> fi) | (fi ^ fi) | (fi v fi)
%Vars(p) = 

% union/3 +L1, +L2, -LR fara duplicate

% implementam fc vars pt fiecare caz in parte
% (princ rec prin formule)
% (recursie structurala)
vars(X, [X]) :- atom(X).
vars(non(F), Res) :- vars(F, Res).
vars(imp(F1,F2), Res) :-
    vars(F1, Res1),
    vars(F2, Res2),
    union(Res1, Res2, Res).
vars(and(F1,F2), Res) :-
    vars(F1, Res1),
    vars(F2, Res2),
    union(Res1, Res2, Res).
vars(or(F1,F2), Res) :-
    vars(F1, Res1),
    vars(F2, Res2),
    union(Res1, Res2, Res).

%% Ex2:  val/3
%% primeste atomul propoz, prim o eval si intoarce eval atomului resp
% val(b, [(a, 1), (b, 0)], Res).
% Res = 0
val(Atom, [(Atom, EvalAtom)| _], EvalAtom) :- !.
val(Atom, [_ | TailEval], Res) :-
    val(Atom, TailEval, Res).

/*
e : Var ->? {0,1}
e+ : Form -> {0,1}
e+(v)=e(v)
e+(not(fi))=not(e+(fi))
e+(fi -> psi) = e+(fi) -> e+(psi)
e+(fi ^ psi) = e+(fi) ^ e+(psi)
e+(fi v psi) = e+(fi) v e+(psi)

Ex3 - definim tabelele de adev pt op de baza
pt a putea def e+ : Form -> { 0, 1 }
*/

% bnon/2 
% bimp/3 
% bor/3 
% band/3 
bnon(0, 1) :- !.
bnon(1, 0) :- !.
 
bimp(0, _, 1) :- !.
bimp(1, 0, 0) :- !.
bimp(1, 1, 1) :- !. 
 
% p \/ q := (~p) -> q 
bor(P, Q, Res) :-
    bnon(P, NonP),
    bimp(NonP, Q, Res).
 
% p /\ q := ~((~p) \/ (~q))
band(P, Q, Res) :-
    bnon(P, NonP),
    bnon(Q, NonQ),
    bor(NonP, NonQ, NonRes),
    bnon(NonRes, Res).

% Exercitiul 4 - definim e+ : Form -> {0, 1}
% eval/3 
% eval(+Form, +Eval, -Eval+(Form)) 
 
% e+(v) = e(v)
% eval	  val 
eval(X, Eval, Res) :- 
    atom(X),
    val(X, Eval, Res). 
eval(non(F), Eval, Res) :-
    eval(F, Eval, ResF),
    bnon(ResF, Res).
eval(imp(F1, F2), Eval, Res) :-
    eval(F1, Eval, Res1),
    eval(F2, Eval, Res2),
    bimp(Res1, Res2, Res).
eval(and(F1, F2), Eval, Res) :-
    eval(F1, Eval, Res1),
    eval(F2, Eval, Res2),
    band(Res1, Res2, Res).
eval(or(F1, F2), Eval, Res) :-
    eval(F1, Eval, Res1),
    eval(F2, Eval, Res2),
   	bor(Res1, Res2, Res).
 
% Exercitiul 5 - extindem evaluarea pe mai multe linii ale tabelului
% eval(imp(non(p), q), [(p, 0), (q, 0)], Eval).
% eval(imp(non(p), q), [(p, 1), (q, 1)], Eval).
 
% evals(imp(non(p), q), [[(p, 0), (q, 0)], [(p, 1), (q, 1)]], Res).
% Res = [0, 1]
evals(_, [], []) :- !.
evals(Form, [HEval | TEval], [FormEval | TailResult]) :-
    eval(Form, HEval, FormEval),
    evals(Form, TEval, TailResult).

/*
Generarea tabelului de adev

F = imp(p, or(non(q), r)) => [p, q, r] => 2^3 linii in tabel
[(p, 0),(q, 0),(r, 0), [(p,0), (q,0), (r,1)],...,[(p,1),(q,1),(r,1)]]

Recap - prod cart
% cartesian_product/4
*/

% Exercitiul 6
cartesian_product([], _, [_], []) :- !. %% ! ????
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






 



