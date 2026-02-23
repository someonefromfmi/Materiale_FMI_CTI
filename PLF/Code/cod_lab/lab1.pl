male(sam).
male(oliver).
male(ben).
male(peter).
male(roger).

female(elizabeth).
female(sandra).
female(mary).
female(lisa).
female(olivia).

parent_of(sandra, sam).
parent_of(sandra, elizabeth).
parent_of(ben, sam).
parent_of(ben, elizabeth).
parent_of(peter, oliver).
parent_of(peter, sandra).
parent_of(roger, ben).
parent_of(roger, lisa).
parent_of(olivia, roger).
parent_of(olivia, mary).

happy(roger).
happy(olivia).

happy(ben) :- happy(roger), happy(olivia).
happy(elizabeth) :- happy(sandra), happy(ben).

father_of(X,Y) :-
    parent_of(X,Y),
    male(Y).


%% Ex 1
mother_of(X,Y) :-
    parent_of(X,Y),
    female(Y).

brother_of(X, Y) :- 
    male(Y), 
    parent_of(Y, Z), 
    parent_of(X, Z),
    X \== Y.

sister_of(X, Y) :- 
    female(Y), 
    parent_of(Y, Z), 
    parent_of(X, Z),
    X \== Y.

uncle_of(X, Y) :- 
    parent_of(X, Z),
    brother_of(Z, Y).

aunt_of(X, Y) :- 
    parent_of(X, Z),
    sister_of(Z, Y).

grandfather_of(X, Y) :-
    parent_of(X, Z),
    father_of(Z, Y).

grandmother_of(X, Y) :-
    parent_of(X, Z),
    mother_of(Z, Y).

%% Ex 2
ancestor_of(X,Y) :- parent_of(X,Y).
ancestor_of(X,Y) :- parent_of(X, Z),
    				ancestor_of(Z,Y).

%% Ex 3
%% distance/3 => distance(In1, In2, Out)
%% pt a reprez pc in plan, le scriem sub forma (X, Y)
distance((X1, Y1), (X2, Y2), Result) :-
    Result is sqrt((X1-X2)**2 + (Y1-Y2)**2).

%% Ex 4 
% Primul triunghi
write_line(_, 0) :- !.
write_line(Symbol, Rep) :-
    write(Symbol),
    NewRep is Rep - 1,
    write_line(Symbol, NewRep).

write_n(_, 0) :- !.
write_n(Symbol, Rep) :-
    write_line(Symbol, Rep),
    NewRep is Rep - 1,
    nl,
    write_n(Symbol, NewRep).

% Al doilea triunghi 
write_line(_, 0, RepSpaces) :-
    write_line(' ', RepSpaces), !.
write_line(Symbol, Rep, Dimension) :-
    RepSpaces is Dimension - Rep,
    write_line(' ', RepSpaces),
    write_line(Symbol, Rep).

write_n(_, 0, _) :- !. 
write_n(Sym, Rep, Dimension) :-
    SymbolRep is Dimension - Rep + 1,
	write_line(Sym, SymbolRep, Dimension),
    NewRep is Rep - 1,
    nl,
    write_n(Sym, NewRep, Dimension).

second_triangle(Symbol, Rep) :-
    write_n(Symbol, Rep, Rep).

% Ex 5
min(A, B, A) :- A =< B, !.
min(_, B, B).

% Ex 6
pythagorean_triple((X1, Y1), (X2, Y2), (X3, Y3)) :-
    distance((X1, Y1), (X2, Y2), D1),
    distance((X1, Y1), (X3, Y3), D2),
    distance((X2, Y2), (X3, Y3), D3),
    (
        D1**2 =:= D2**2 + D3**2 ;
        D2**2 =:= D1**2 + D3**2 ;
        D3**2 =:= D1**2 + D2**2 
    ).

 