/*
- Alg de unificare

Logica de ord 1
    - mult de Var = { xn | n apart N} (numarabila)
    - Sim := {(,), not, ->, or, ex}
    - este unic det de sign tau
        tau = (F, R, C, ari)
        F functii, R relatii, C const
        ari : F U R - > N*
        tau -> L, limbaj de ord 1
    Var -> Term -> Form atomice L -> FormL
    Var C= TermL
    C C= TermL
    C sunt fc de aritate 0
    daca t1..tn apart TermL atunci f(t1...tn) apart TermL si f aprt Fn
    Exp: dc x apart Var, c aprt C, f apart F3 atunci TermL = {x,c, f(x,x,x),f(x,c,x),
    f(c,c,c),..., f(f(x,c,x), f(x,x,c), c)}

    O subst este o fc teta:Var->TermL
    Un unif este o subst teta care, pt doi term t1 si t2, induce teta(t1) = teta(t2)
    Gasim teta prin alg de unif 
    "=" din Prolog: obliga determinarea unui unif
    exp1 = exp2 => cauta un teta a.i teta(exp1)==teta(exp2)
    Cauta teta a.i. cele 2 exp sa fie identice (modulo teta)

    - Alg de unif: scopul este sa gasim subst. pt care 2 term (sau mai multi)
    sunt identici. = (egal ecuational)
    t1=t2 -> alg
       Multime solutie      Multime de rezolvat              Operatie
init         S               R, t=t                           SCOATE
efect        S               R
init         S               R, f(t1...tn)=f(t1'...tn')       DESCOMPUNE
efect        S               R, t1=t1', t2=t2', ..., tn=tn'               
init         S               R, (x=t sau t=x)                 REZOLVA
efect     x=t, S[x/t]        R[x/t]
final       S                   vid                           STOP    

Cazuri de esec
1) f(...) = g(...) (constantele sunt functii de aritate 0 !!!)
    x = f(y) OK
    b = f(y) ESEC
2) x=t sau t=x, dar x apart Vars(t) 
*/

/* 
Ex1:
x,y,z,u,v apart Var
a,b,c aprt C
h,g apart F1
f, *, + apart F2
p apart F3
1) f(h(a), g(x)) = f(y,y)?

Multime Solutie          Multime de rezolvat      Operatie
vid                   f(h(a), g(x)) = f(y,y)       DESCOMPUNERE
vid                   h(a)=y, g(x)=y               REZOLVA
y = h(a)              g(x) = h(a)                  ESEC
In concluzie, nu ex un unif 

Daca aveam
Multime Solutie          Multime de rezolvat      Operatie
vid                   f(h(a), g(x)) = f(z,y)       DESCOMPUNERE
vid                   h(a)=z, g(x)=y               REZOLVA
z=h(a)                g(x)=y                       REZOLVA
y=g(x), z=h(a)        vid                          STOP

Ex2:
Sa se unif p(a,x,g(x)) = p(a,y,y)
Metoda tabelului

Multime Solutie          Multime de rezolvat      Operatie
vid                      p(a,x,g(x))=p(a,y,y)      DESCOMPUNERE
vid                      a=a,x=y, g(x)=y           SCOATE
vid                      x=y, g(x)=y               REZOLVA
y=g(x)                   x=g(x)                    ESEC
Am obt esec, deoarece avem x=g(x) (x Var, g(x) term si x apart vars(g(x)))

Ex3:
sa se unif p(x,y,z)=p(u,f(v,v),u)

Multime Solutie          Multime de rezolvat       Operatie
vid                       p(x,y,z)=p(u,f(v,v),u)    DESCOMP
vid                       x=u,y=f(v,v),z=u          REZOLVA
u=x                       y=f(v,v), z=x             REZOLVA
x=z, u=x                  y=f(v,v)                  REZOLVA
x=z, u=x, y=f(v,v)        vid                       STOP

niu := { f(v,v)/y, z/x, x/u }

Ex4: 
sa se unif x+(y*y)=(y*y)+z

Multime Solutie          Multime de rezolvat       Operatie
vid                         x+(y*y)=(y*y)+z         DESCOMP
vid                         x=y*y, y*y=z            REZOLVA
x=y*y                       y*y=z                   REZOLVA
z=y*y, x=y*y                vid                     STOP
niu:= {}
Le putem scrie prefixat ca sa ne fie mai usor +(x,*(y,y))=+(*(y,y),z)
*/

eq(X,Y):-unify_with_occurs_check(X,Y).
% in interpretor: eq(f(h(a), g(X)),f(Y,Y)).

/*
    ex2lab4
    Avem 6 cuv, 5 pe oriz, 1 pe vert
    vrem sa asezam cuv corect pe rebusul dat
    in mom in care rez o pb de cautare in 
    prolog el face automat  bkt si tot ce trb
    sa i specificam este cand acceptam o sol
*/
% def un pred de aritate 1 care sa-mi tina 
% cuv
word(flowers).
word(prolog).
word(entirely).
word(school).
word(oregano).
word(sleep).

% pt a completa corect acest rebus 
% ne asig ca sunt respectate intersectiile
% de ex, a 5a lit din primul cuv trb sa 
% coincida cu prima litera din al saselea

% a sasea litera din al doilea cuv
% trb sa coincida cu a2a lit din al saselea

% avem un pred care trb sa extraga litera
% de pe poz I data dintr-un cuvant
getPos([H|_], Index, Index, H) :- !.
getPos([_|T], Index, MaxIndex, Elem) :-
    NewIndex is Index+1,
    getPos(T, NewIndex, MaxIndex, Elem).
getPos(L, Index, Res) :- 
    getPos(L, 0, Index, Res).

elements_of(H, [H|_]) :- !.
elements_of(X, [_|T]) :- elements_of(X,T).

allDiff([]) :- !.
allDiff([H|T]) :-
    not(elements_of(H,T)),
    allDiff(T).

sol(W1, W2, W3, W4, W5, W6, L) :-
    word(W1),
    word(W2),
    word(W3),
    word(W4),
    word(W5),
    word(W6),
    allDiff([W1,W2,W3,W4,W5,W6]),
    string_chars(W1, L1),
    string_chars(W2, L2),
    string_chars(W3, L3),
    string_chars(W4, L4),
    string_chars(W5, L5),
    string_chars(W6, L6),

    getPos(L1, 4, Letter1),
    getPos(L6, 0, Letter1),

    getPos(L2, 5, Letter2),
    getPos(L6, 1, Letter2),

    getPos(L3, 6, Letter3),
    getPos(L6, 2, Letter3),

    getPos(L4, 6, Letter4),
    getPos(L6, 3, Letter4),

    getPos(L5, 4, Letter5),
    getPos(L6, 4, Letter5),

    getPos(L1, 1, Solution1),
    getPos(L2, 2, Solution2),
    getPos(L3, 3, Solution3),
    getPos(L4, 3, Solution4),
    getPos(L5, 1, Solution5),

    L = [Solution1, Solution2, Solution3, 
        Solution4, Solution5].

/* 
    - Pb de cautare
*/