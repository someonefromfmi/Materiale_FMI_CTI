% Program in Prolog = baza de cunostinte

father(thomas, emma).
father(thomas, arthur).

mother(jane, emma).
mother(jane, arthur).

watson(thomas).
watson(jane).

watson(X) :- father(Y,X), watson(Y).

% operatorul :- este implicatia logica <-
cti(X) :- seria36(X).

% virgula , este conjunctia
seria36(X) :- coleg(Y,X), seria36(Y).
% warning aici ?

% Mai multe reguli cu acelasi Head definesc
% acelasi predicat, intre ele fiind un sau logic
cti(X) :- fizica(X).
cti(X) :- proiectare_logica(X).
cti(X) :- electrotehnica(X).

% Pentru a gasi un raspuns, Prolog incearca
% regulile in ordinea aparitiei lor
foo(a). foo(b). foo(c).

% Prolog se intoarce la ultima alegere
% daca o subtinta esueaza.
bar(b).
bar(c).
baz(c).

bigger(elephant, horse).
bigger(horse, donkey).
bigger(donkey, dog).
bigger(donkey, monkey).
is_bigger(X, Y) :-
    bigger(X, Y).
is_bigger(X, Y) :-
    bigger(X, Z),
    is_bigger(Z, Y).

% Compararea termenilor: =. \=, ==, \==

% T = U reuseste daca exista o potrivire
% (termenii se unifica)

% T \= U reuseste daca nu exista o potrivire
% T == U reuseste daca termenii sunt identici
% T \== reuseste daca termenii sunt diferiti

% relatia =:= folosita pentru a compara
% rez eval expr aritm

% !!! =:= compara 2 expr
% !!! = cauta un unificator

% Exp de relatii disponibile:
% <, >, =<, >=, =\= (diferit), =:= (aritmetic egal)
% =\= (diferit aritmetic???)

% Operatorul is: 
/*
- 2 arg
- primul: numar sau variabila
- al doilea: expr aritm valida, cu toate var init
- if primul arg numar -> rezultat: true, daca 
  este egal cuu val expr aritm din al doilea arg
- if primul arg var -> rezultat: true, daca var
  poate fi unif cu eval expr aritm din al doilea arg.
*/

% Negarea ca esec: \+ pred(X)

animal(dog). animal(elephant). animal(sheep).