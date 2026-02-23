% Scriet¸i un predicat elements of/2 care verific˘a dac˘a primul argument este element al listei din cel
% de-al doilea argument.
% Exemple de apel ¸si rezultatele a¸steptate:
% ?- elements_of(1, [1,2,3]).
% true
% ?- elements_of(b, [a,b,c]).
% true
% ?- elements_of(d, [a,b,c]).
% false
% ?- elements_of(X, [a,b,c]).
% X = a ;
% X = b ;
% X = c ;
% false

elements_of(H, [H | _ ]) :- !.
elements_of(H, [_ | T]) :-
    elements_of(H, T).

% Ninety-nine prolog problems
% p01 - last elem of a list
% my_last(X, [a,b,c,d]).
my_last(H, [H]) :- !.
my_last(X, [ _ | T]) :-
    my_last(X, T).

% P02 (*) Find the last but one element of a list.
%     (zweitletztes Element, l'avant-dernier élément)
my_second_last(H, [H, _]) :- !.
my_second_last(X, [ _ | T]) :-
    my_second_last(X, T).

     
% P03 (*) Find the K'th element of a list.
%     The first element in the list is number 1.
%     Example:
%     ?- element_at(X,[a,b,c,d,e],3).
%     X = c
element_at(H, [H|_], 1) :- !.
element_at(X, [_|T], K) :-
    NewK is K - 1,
    element_at(X, T, NewK).

% P04 (*) Find the number of elements of a list.
len([], 0) :- !.
len([_ | T], Res) :-
    len(T, NewRes),
    Res is NewRes + 1.

% P05 (*) Reverse a list.
rev([], L, L) :- !.
rev([H|T], L, Acc) :-
    rev(T, L, [H|Acc]).
rev(L, RevL) :- 
    rev(L, RevL, []).

% P06 (*) Find out whether a list is a palindrome.
%     A palindrome can be read forward or backward; e.g. [x,a,m,a,x].

palin(L1) :-
    rev(L1,L1).

% P07 (**) Flatten a nested list structure.
%     Transform a list, possibly holding lists as elements into a `flat' list by replacing each list with its elements (recursively).

%     Example:
%     ?- my_flatten([a, [b, [c, d], e]], X).
%     X = [a, b, c, d, e]

%     Hint: Use the predefined predicates is_list/1 and append/3
my_flatten(X, [X]) :- \+ is_list(X).
my_flatten([], []) :- !.
my_flatten([H|T], Res) :- 
    my_flatten(H, Res1),
    my_flatten(T, Res2),
    append(Res1,Res2, Res).

% Exercitiul 2
% Primind o lista identica celei de la exercitiul 1, dar cu aparitii multiple ale unui angajat, 
% 	(considerand ca fiecare intrare reprezinta salariul intr-o anumita luna)
% 	determinati salariul mediu al fiecarui angajat. 
% de exemplu, daca peter apare (peter, 1000), respectiv (peter, 1200), in lista de rezultat va fi doar (peter, 1100)
% ?- employee_average_salary([(peter, 1000), (oliver, 1200), (sam, 700), (oliver, 800), (sam, 900), (sandra, 4500), (peter, 1200), (oliver, 400)], Result).
% Result = [(peter, 1100), (oliver, 800), (sam, 800), (sandra, 4500)]

get_emp_count_sum(_, [], 0, 0) :- !.
get_emp_count_sum(Name, [(Name, Sal) | Tail], Count, Sum) :-
    get_emp_count_sum(Name, Tail, TailC, TailS),
    Sum is TailS + Sal,
    Count is TailC + 1, !.
get_emp_count_sum(Name, [_|T], Count, Sum) :-
    get_emp_count_sum(Name, T, Count, Sum).

elim_emp(_, [], []).
elim_emp(Name, [(Name,_)|Tail], TR) :-
    elim_emp(Name, Tail, TR), !.
elim_emp(Name, [H|T], [H|TR]) :-
    elim_emp(Name, T, TR).

employee_average_salary([], []) :- !.
employee_average_salary([(Name, Sal) | Tail], [(Name, AVG)|TR]) :-
    get_emp_count_sum(Name, [(Name, Sal) | Tail], Count, Sum),
    AVG is Sum / Count,
    elim_emp(Name, [(Name, Sal) | Tail], Result),
    employee_average_salary(Result, TR).
    

% Exercitiul 3
% Primind o lista identica celei de la exercitiul 2, in lista de rezultat ordonati angajatii dupa salariul mediu castigat, in ordine descrescatoare. 
% ?- sort_employee_average_salary([(peter, 1000), (oliver, 1200), (sam, 700), (oliver, 800), (sam, 900), (sandra, 4500), (peter, 1200), (oliver, 400)], Result).
% Result = [(sandra, 4500), (peter, 1100), (oliver, 800), (sam, 800)]

my_cmp(X, (_, Sal1), (_, Sal2))  :-
    compare(X, Sal2, Sal1).

ex_sort(List, SortedList) :- 
    employee_average_salary(List, Result),
    predsort(my_cmp,Result,SortedList).

% P08 (**) Eliminate consecutive duplicates of list elements.
%     If a list contains repeated elements they should be replaced with a single copy of the element. The order of the elements should not be changed.

%     Example:
%     ?- compress([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
%     X = [a,b,c,a,d,e]

compress([], []).
compress([X], [X]).
compress([H, H|T], TRes) :-
    compress(T, TRes).
compress([X, Y| T], [X | TRes]) :-
    X \= Y, 
    compress([Y|T], TRes).

% P09 (**) Pack consecutive duplicates of list elements into sublists.
%     If a list contains repeated elements they should be placed in separate sublists.

%     Example:
%     ?- pack([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
%     X = [[a,a,a,a],[b],[c,c],[a,a],[d],[e,e,e,e]]

pack([],[]).
pack([X|Xs], [Z|Zs]) :- 
    transfer(X,Xs,Ys,Z), 
    pack(Ys,Zs).
transfer(X, [], [], [X]).
transfer(X, [Y|Ys], [Y|Ys], [X]) :- X \= Y.
transfer(X,[X|Xs],Ys,[X|Zs]) :- transfer(X,Xs,Ys,Zs).

% P10 (*) Run-length encoding of a list.
%     Use the result of problem P09 to implement the so-called run-length encoding data compression method. Consecutive duplicates of elements are encoded as terms [N,E] where N is the number of duplicates of the element E.

%     Example:
%     ?- encode([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
%     X = [[4,a],[1,b],[2,c],[2,a],[1,d][4,e]]

% :- ensure_loaded(p09).

encode(L1,L2) :- 
    pack(L1,L), 
    transform(L,L2).

transform([],[]).
transform([[X|Xs]|Ys],[[N,X]|Zs]) :- 
    length([X|Xs],N), 
    transform(Ys,Zs).

% P11 (*) Modified run-length encoding.
%     Modify the result of problem P10 in such a way that if an element has no duplicates it is simply copied into the result list. Only elements with duplicates are transferred as [N,E] terms.

%     Example:
%     ?- encode_modified([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
%     X = [[4,a],b,[2,c],[2,a],d,[4,e]]

encode_modified(L1,L2) :- encode(L1,L), strip(L,L2).

strip([],[]).
strip([[1,X]|Ys],[X|Zs]) :- strip(Ys,Zs).
strip([[N,X]|Ys],[[N,X]|Zs]) :- N > 1, strip(Ys,Zs).

% P12 (**) Decode a run-length encoded list.
%     Given a run-length code list generated as specified in problem P11. Construct its uncompressed version.
decode([],[]).
decode([X|Ys],[X|Zs]) :- \+ is_list(X), decode(Ys,Zs).
decode([[1,X]|Ys],[X|Zs]) :- decode(Ys,Zs).
decode([[N,X]|Ys],[X|Zs]) :- N > 1, N1 is N - 1, decode([[N1,X]|Ys],Zs).

% P13 (**) Run-length encoding of a list (direct solution).
%     Implement the so-called run-length encoding data compression method directly. I.e. don't explicitly create the sublists containing the duplicates, as in problem P09, but only count them. As in problem P11, simplify the result list by replacing the singleton terms [1,X] by X.

%     Example:
%     ?- encode_direct([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
%     X = [[4,a],b,[2,c],[2,a],d,[4,e]]

encode_direct([],[]).
encode_direct([X|Xs],[Z|Zs]) :- count(X,Xs,Ys,1,Z), encode_direct(Ys,Zs).

count(X,[],[],1,X).
count(X,[],[],N,[N,X]) :- N > 1.
count(X,[Y|Ys],[Y|Ys],1,X) :- X \= Y.
count(X,[Y|Ys],[Y|Ys],N,[N,X]) :- N > 1, X \= Y.
count(X,[X|Xs],Ys,K,T) :- K1 is K + 1, count(X,Xs,Ys,K1,T).

% P14 (*) Duplicate the elements of a list.
%     Example:
%     ?- dupli([a,b,c,c,d],X).
%     X = [a,a,b,b,c,c,c,c,d,d]
dupli([],[]) :- !.
dupli([H|T], [H,H|TR]) :-
    dupli(T,TR).

% P15 (**) Duplicate the elements of a list a given number of times.
%     Example:
%     ?- dupli([a,b,c],3,X).
%     X = [a,a,a,b,b,b,c,c,c]

%     What are the results of the goal:
%     ?- dupli(X,3,Y).
dupli(L1,N,L2) :- dupli(L1,N,L2,N).
dupli([],_,[],_).
dupli([_|Xs],N,Ys,0) :- dupli(Xs,N,Ys,N).
dupli([X|Xs],N,[X|Ys],K) :- K > 0, K1 is K - 1, dupli([X|Xs],N,Ys,K1).

%  (**) Drop every N'th element from a list.
%     Example:
%     ?- drop([a,b,c,d,e,f,g,h,i,k],3,X).
%     X = [a,b,d,e,g,h,k]'
drop(L, N, Res) :- drop(L, N, Res, N).
drop([], _, [], _).
drop([_|T], N, TRes, 1) :- drop(T, N, TRes, N). 
drop([H|T], N, [H|TRes], K) :- K > 1,K1 is K - 1, drop(T, N, TRes, K1).

% P17 (*) Split a list into two parts; the length of the first part is given.
%     Do not use any predefined predicates.

%     Example:
%     ?- split([a,b,c,d,e,f,g,h,i,k],3,L1,L2).
%     L1 = [a,b,c]
%     L2 = [d,e,f,g,h,i,k]
split(L, 0, [], L) :- !.
split([H|T], N, [H|Ys], L2) :-
    N > 0,
    N1 is N - 1,
    split(T, N1, Ys, L2).

% P18 (**) Extract a slice from a list.
%     Given two indices, I and K, the slice is the list containing the elements between the I'th and K'th element of the original list (both limits included). Start counting the elements with 1.

%     Example:
%     ?- slice([a,b,c,d,e,f,g,h,i,k],3,7,L).
%     X = [c,d,e,f,g]
slice([X|_], 1, 1, [X]) :-!.
slice([H|T], 1, K, [H|TR]) :-
    K > 1,
    K1 is K - 1,
    slice(T, 1, K1, TR).
slice([_|T], I, K, TRes) :-
    I > 1,
    I1 is I-1,
    K1 is K-1,
    slice(T,I1,K1,TRes).



