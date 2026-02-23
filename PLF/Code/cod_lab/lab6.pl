/*
numlist(A, B, List).
intoarce toate numerele intregi din [A, B]
> List = [-2, -1, 0, 1, 2, 3, 4, 5]

findall(X, P(X), List).
L = { X | P(X)}

Ex1 - divisorsPair/3
divisorsPair(A, B, List)
intoarcem perechile (X, Y) cu prop ca Y | X, cu X si Y din [A, B]
*/

divisorsPair(A, B, List) :-
    numlist(A, B, Range),
    findall((X, Y), (member(X, Range), member(Y, Range), X mod Y =:= 0), List).

% Res:= {(X,Y) | }

/*Ex1.2 - oddIndexes/2*/
zip([], _, []) :- !.
zip(_, [], []) :- !.
zip([H1|T1], [H2|T2], [(H1, H2) | TR]) :-
    zip(T1, T2, TR).

oddIndexes(List, Result) :-
    length(List, Length),
    numlist(0, Length, Range),
    zip(List, Range, ZippedList),
    findall(X, (member((X,Y), ZippedList), Y mod 2 =:=1), Result).

% Calc suma elem impare de pe poz multiplu de 3
sumImp(List,Sum) :-
    length(List, Length),
    numlist(0, Length, Range),
    zip(List, Range, ZippedList),
    findall(X, (member((X,Y), ZippedList), X mod 2 =:=1, Y mod 3 =:= 0), Result),
    sum_list(Result, Sum).

/*
Pb de cautare cu obiectiv
BFS
1 -> 2
1 -> 3
2 -> 4
2 -> 5
3 -> 4
3 -> 5

succesor/2
objective/1
solve/2 -> toate drumurile de la nodul init la obiectiv
tinem drumurile in ord inversa
solve(1,R).
> R = [[5,2,1],[5,3,1]]
initial:
[[1]] -> [[2,1],[3,1]] pt ca 2 si 3 sunt succ pt 1,
iar 2 si 3 nu au aparut deja in listele de drumuri
La fiecare pas verif daca am gasit obiectivul iar daca nu extindem lista
cu nodurile succ
extend/2 - primeste un drum si ret toate drumurile care se obt in ext
*/

succesor(1, 2).
succesor(1, 3).
succesor(2, 4).
succesor(2, 5).
succesor(3, 5).
succesor(3, 4).
objective(5).

extend([Node | Path], NewPath) :-
    findall([NewNode, Node | Path],
        (succesor(Node, NewNode), not(member(NewNode, [Node | Path]))),
        NewPath).
    
/*
scriem un pred breadthfirst/2
primeste o lista de drumuri si intoarce de fiecare data cand gaseste o sol
*/
breadthfirst([[Node | Path] | _], [Node | Path]) :- objective(Node).
breadthfirst([Path | PathTail], Solution) :-
    extend(Path, ExtendedPath),
    append(ExtendedPath, PathTail, NewPath),
    breadthfirst(NewPath, Solution).

solve(Start, Solution) :-
    findall(S, breadthfirst([[Start]], S), Solution).

% Ex4 - tree/3 si nil/0 pt repr arborelui vid
def(myTree, tree(1, tree(2, tree(4, nil, tree(7, nil, nil)), nil), tree(3, tree(5, nil, nil), tree(6, nil, nil)))).
/*
parcurgerile
inordine preordine postordine
SRD       RSD       SDR
*/
% inordine
srd(nil, []).
srd(tree(Root, Left, Right), Result) :-
    srd(Left, ResultLeft),
    srd(Right, ResultRight),
    append(ResultLeft, [Root | ResultRight], Result).

% preordine
rsd(nil, []).
rsd(tree(Root, Left, Right), Result) :-
    rsd(Left, ResultLeft),
    rsd(Right, ResultRight),
    append([Root | ResultLeft], ResultRight, Result).

% postordine
sdr(nil, []).
sdr(tree(Root, Left, Right), Result) :-
    sdr(Left, ResultLeft),
    sdr(Right, ResultRight),
    append(ResultLeft, ResultRight, ResultWithoutRoot),
    append(ResultWithoutRoot, [Root], Result).

% testati scriind 
% def(myTree, Tree), srd(Tree, Result). 
% si schimbati srd cu rsd si sdr 

% Exercitiul 3 
% Zebra-puzzle
right(X, Y) :- X is Y + 1.
left(X, Y) :- right(Y, X).
near(X, Y) :- left(X, Y) , !.
near(X, Y) :- right(X, Y).

% house(Number,Nationality,Colour,Pet,Drink,Cigarettes)

solution(Street, ZebraOwner) :-
  	Street = [
    	house(1,_,_,_,_,_),
    	house(2,_,_,_,_,_),
    	house(3,_,_,_,_,_),
    	house(4,_,_,_,_,_),
    	house(5,_,_,_,_,_)
  	],
  	member(house(_,english,red,_,_,_), Street),
  	member(house(_,spanish,_,dog,_,_), Street),
  	member(house(X,_,green,_,coffee,_), Street),
  	member(house(_,ukrainian,_,_,tea,_), Street),
  	member(house(Y,_,beige,_,_,_), Street),
    right(X, Y),
    member(house(_,_,_,snails,_,oldGold), Street),
    member(house(U,_,yellow,_,_,kools), Street),
    member(house(3,_,_,_,milk,_), Street),
    member(house(1,norwegian,_,_,_,_), Street),
    member(house(A,_,_,_,_,chesterfields), Street),
    member(house(B,_,_,fox,_,_), Street),
    near(A, B),
    member(house(V,_,_,horse,_,_), Street),
    near(U, V),
    member(house(_,_,_,_,orangeJuice,luckyStrike), Street),
    member(house(_,japanese,_,_,_,parliaments), Street),
    member(house(T,_,blue,_,_,_), Street),
    near(1, T),
  	member(house(_,ZebraOwner,_,zebra,_,_), Street).

