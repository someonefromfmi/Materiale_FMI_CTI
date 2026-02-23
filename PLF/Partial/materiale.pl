% Predicate predefinite in Prolog si breviar teoretic 
% 
% atom/1 - verifica daca un string este atom in Prolog
% atom = orice sir de caractere care incepe cu litera mica sau care e scris intre simboluri ''
% ?- atom(X). false
% ?- atom(myAtom). true 
% ?- atom('My Atom'). true 
%
% In scrierea regulilor, folosim structura
% Head :- Body. Daca Body e satisfacut, atunci satisfacem si Head. (Head if Body)
% Facts - contin doar Head, sunt cunostintele de baza
% Rules - cele care contin Body. In Body, putem inlantui cunostintele prin , (SI = conjunctie)
% 															respectiv prin ; (SAU = disjunctie)
% Pentru a limita recursia pe cazurile de baza, folosim !/0. (predicatul CUT)
% el este util cand avem clauze scrie una sub alta - atunci se face disjunctie intre clauze.
% Daca se satisface o clauza, Prolog incearca satisfacerea celorlalte clauze, imediat urmatoare.
% Pentru a opri acest mecanism, e util CUT. 
% Exemplu: base_case(params) :- !.  
%
% Operatorii aritmetici
% uzuali: +, -, *, / (floats), // (cat), div (cat), mod (rest), ** (exponentiere)
% egalitati: = (cauta unificator), == (structural), =:= (aritmetic) 
% is/2 - operator de atribuire aritmetica
% ?- X is 1 + 2. atunci X = 3
% is/2 functioneaza cand membrul drept este COMPLET instantiat 
% Y = 2, X is Y + 2. raspunde Y = 2, X = 4
% dar X is Y + 2. e eroare, pentru ca Y nu e instantiat ("Arguments are not sufficiently instantiated")
% 
% Listele in Prolog 
% [se, reprezinta, prin, paranteze, patrate, si, cu, elemente, separate, prin, virgula]
% pot contine elemente de orice tip, amestecate oricum [0, [], [X], f(X), Y] etc 
% notatia utila: [Head | Tail] (sau [H | T] in general, in probleme)
% Head-ul unei liste vide conduce la eroare!!! Tail-ul listei vide este lista vida
% [H | T] = [1] atunci H = 1, T = []
% [H | T] = [] atunci EROARE
% [A, B | T] = [a,b,c,d] atunci A = a, B = b, T = [c, d]
% [A, B | T] = [a, b] atunci A = a, B = b, T = []
% [A, B | T] = [a] atunci EROARE pentru ca B e in Head (inainte de | ) si nu se poate instantia
% length/2 - returneaza lungimea unei liste
% ?- length([1,2,3],L). atunci L = 3
% member/2 - verifica daca un element apare sau nu intr-o lista
% ?- member(b, [a,b,c,d]). atunci true
% ?- member(t, [a,b,c,d]). atunci false 
% union/3 - reuniunea a doua liste, cu rezultatul o lista reprezentand o multime - elementele sunt distincte
% ?- union([1,2,3,2],[1,4,3,2],L). atunci L = [1,4,3,2]
% append/3 - concateneaza doua liste, mai intai prima lista, apoi a doua 
% ?- append([1,2,3,2],[1,4,3,2],L). atunci L = [1, 2, 3, 2, 1, 4, 3, 2]
% string_chars/2 - split-uieste un sir de caractere intr-o lista de caractere corespunzatoare
% ?- string_chars(prolog, Res). atunci Res = [p, r, o, l, o, g]
% ?- numlist/3 - primeste doua capete de interval, si returneaza lista intregilor din intervalul inchis 
% ?- numlist(-2, 3, Res). atunci Res = [-2, -1, 0, 1, 2, 3]
% daca primul argument > al doilea, returneaza false 
% findall/3 - findall(X, P, L). pune in L toti acei X astfel incat sa respecte P 
% divisorsPairs(A, B, List) :- 
% 	numlist(A, B, Range),
% 	findall((X, Y), (member(X, Range), member(Y, Range), X mod Y =:= 0), List).
% i.e. gaseste toate perechile (X, Y)
% cu proprietatea ca X apartine Range, Y apartine Range si restul impartirii lui X la Y este 0
% 															(adica Y este divizor al lui X)
% si pune toate aceste perechi in List 
% 
% reverse/2 - reverse(ListInput, ListOutput). returneaza in ListOutput reverse-ul listei ListInput
% 
% predsort/3 - utilizat pentru sortare cu un compare: predsort(MyCompare, InputList, SortedList).
%
% select/2 - utilizat pentru a elimina un element dintr-o lista 
% ?- select(10,[1,2,3],R).
% false.
%
% ?- select(2,[1,2,3],R).
% R = [1, 3] ;
% false.
% 
% ?- select(2,[1,2,3,2,4],R).
% R = [1, 3, 2, 4] ;
% R = [1, 2, 3, 4] ;
% false.
% 
% ?- select(2,[1,2,3,2,4,2],R).
% R = [1, 3, 2, 4, 2] ;
% R = [1, 2, 3, 4, 2] ;
% R = [1, 2, 3, 2, 4].
% 
% nth0/3 - extrage elementul de pe un index dat dintr-o lista, cu indexare de la 0 
% ?- nth0(1, [a, b, c, d], Elem).
% Elem = b 
% analog nth/1 - indexare de la 1 
% 
% permutation/2 - primeste o lista si returneaza toate permutarile posibile 
% ?- permutation([1,2], [X,Y]).
% X = 1, Y = 2 ;
% X = 2, Y = 1 ;
% false.

% Predicate utile, dar care nu sunt definite in Prolog

% sum/2 - returneaza suma dintr-o lista
sum([], 0) :- !.
sum([H | T], Res) :-
    sum(T, ResT),
    Res is ResT + H.

% zip/3 - face perechi de elemente de pe aceeasi pozitie intre doua liste
% ?- zip([1,2,3],[a,b,c],Res). atunci Res = [(1, a), (2, b), (3, c)]
% zip se opreste la lungimea celei mai scurte dintre cele doua liste! 
% ?- zip([1,2,3,4],[a,b,c],Res). atunci Res = [(1, a), (2, b), (3, c)]
% ?- zip([1,2,3],[a,b,c,d,e],Res). atunci Res = [(1, a), (2, b), (3, c)]
zip([], _, []) :- !.
zip(_, [], []) :- !.
zip([H1 | T1], [H2 | T2], [(H1, H2) | TR]) :-
    zip(T1, T2, TR).

% all_symb/2 - verifica daca toate elementele dintr-o lista sunt egale cu un simbol dat
% ?- all_symb([a,a,a], a). atunci true
% ?- all_symb([a,A,a], a). atunci A = a, true (este satisfacut cand A = a)
all_symb([S], S) :- !.
all_symb([H | T], S) :-
    H = S,
    all_symb(T, S).

% max/2 - returneaza maximul dintr-o lista 
max([], 0) :- !.
max([H | T], MaxTail) :-
    max(T, MaxTail),
    MaxTail >= H, !.
max([H | T], H) :-
    max(T, MaxTail),
    H >= MaxTail.

% remove_duplicates/2 - returneaza lista primita ca prim argument, dar fara elemente duplicate
remove_duplicates([], []) :- !.
remove_duplicates([H | T], [H | TR]) :-
    not(member(H, T)), 
    remove_duplicates(T, TR), !.
remove_duplicates([_ | T], TR) :-
    remove_duplicates(T, TR).

% Exemplu de BFS 
succesor(1, 2).
succesor(1, 3).
succesor(1, 4).
succesor(2, 4).
succesor(2, 5).
succesor(3, 5).
succesor(3, 4).
succesor(4, 3).
objective(5).


extend([Node | Path], NewPath) :-
    findall([NewNode, Node | Path], (succesor(Node, NewNode), not(member(NewNode, [Node | Path]))), NewPath).

breadthfirst([[Node | Path] | _], [Node | Path]) :- objective(Node).
breadthfirst([Path | PathTail], Solution) :-
    extend(Path, ExtendedPath),
    append(ExtendedPath, PathTail, NewPath),
    breadthfirst(NewPath, Solution).

solve(Start, Solution) :-
    findall(S, breadthfirst([[Start]], S), Solution).

% Exemplu de arbori si parcurgere

def(myTree, tree(1, tree(2, tree(4, nil, tree(7, nil, nil)), nil), tree(3, tree(5, nil, nil), tree(6, nil, nil)))).

% inordine
srd(nil, []).
srd(tree(Root, Left, Right), Result) :-
    srd(Left, ResultLeft),
    srd(Right, ResultRight),
    append(ResultLeft, [Root | ResultRight], Result).

% Pentru UNIFICARE
% unify_with_occurs_check/2 verifica daca doi termeni pot unifica sau nu
% atentie la specificatia de limbaj! variabilele din limbaj sunt si cele din Prolog, deci se scriu cu Majuscula
