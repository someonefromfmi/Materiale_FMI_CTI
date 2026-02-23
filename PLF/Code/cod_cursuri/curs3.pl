/*
Termeni compusi f(t1, ..., tn)

3 tipuri de termeni: 
- constante: 23, sansa, 'Jon Snow'
- variabile: X, Stark, _house
- termeni compusi:
    - predicate, exp: father(eddard, jon_snow)
    - termeni prin care reprez datele

Exp: 
*/
born(john, date(20,3,1977)).

/*
- born/2 si date/3 sunt functori
- born/2 este predicat
- date/3 defineste date compuse
*/

% ! operatorii sunt functii: +, *, mod
% ! sintaxa nu face dif intre simb de func si simb de pred

% Termeni compusi in prolog
def(arb, tree(a, tree(b,
                        tree(d,void,void),
                        void),
                 tree(c, void,
                         tree(e,void,void)))).

% Verifica daca un termen este un arbore binar
binary_tree(void).
binary_tree(tree(Element,Left,Right)) :-
    binary_tree(Left),
    binary_tree(Right).
    element_binary_tree(Element).

element_binary_tree(X) :- integer(X).

test :- def(arb, T), binary_tree(T).

% Ex.: Scrieti un pred care verif daca un elem apartine unui arb.
tree_member(X, tree(X, Left, Right)).
tree_member(X, tree(_,Left,Right)) :- tree_member(X, Left).
tree_member(X, tree(_,Left,Right)) :- tree_member(X, Right).

