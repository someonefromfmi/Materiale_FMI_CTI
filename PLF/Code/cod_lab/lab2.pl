% fib(1, 0) :- !.
% fib(2, 1) :- !.
% fib(N, F) :-
%     % calc fib(N-1) si fib(N-2)
%     N1 is N - 1,
%     N2 is N - 2,
%     fib(N1, F1),
%     fib(N2, F2),
%     F is F1 + F2.

% var 2 - implementare cu memoizare
% Utilizam : while (i < n) : f = f1 + f2; f1 <- f2; f2 <- f
% 

fib(1, 0) :- !.
fib(2, 1) :- !.
fib(N, F) :- 
	N1 is N-1,
    N2 is N-2,
    fib(N1, F1),
    fib(N2, F2),
    F is F1 + F2.

% varianta mai optimizata (cu memoizare):
fib(_, F, F, MaxIndex, MaxIndex) :- !.
fib(F1, F2, Res, Index, MaxIndex) :-
    F is F1 + F2,
    NewIndex is Index + 1,
    fib(F2, F, Res, NewIndex, MaxIndex).
    
efficient_fib(N, F) :- fib(0, 1, F, 0, N).

% pt a calc lung unei liste
% avem pred list_length/2, list_length(+list, -Res).
% pt ca listele sunt un tip de date inductiv ([], |)
% definim predicatul pt cazul de oprire, respectiv pt cazul general

list_length([], 0).
list_length([_|T], Res) :-
    list_length(T, ResT),
    Res is ResT + 1.

% scrieti un pred care sa evalueze suma elem dintr 0 lista
% sum_list/2
% sum_list(+ List, -List)
sum_list([], 0).
sum_list([H|T], Res):-
    sum_list(T, ResT),
    Res is ResT + H.

% elemnts_of(+x, +List).
% verif daca x apart List
elements_of(X, [X|_]) :- !.
elements_of(X, [_|T]) :-
    elements_of(X, T).

% 5. all_a/1.
% all_a(+List).
% Verif daca toate elem din lista sunt egale cu a.
all_a([a]).
all_a([a|T]) :- all_a(T).

% 6. trans_a_b/2
% trans_a_b(+la, -lb).
trans_a_b([a], [b]).
trans_a_b([a|Ta], [b|Tb]):-
    trans_a_b(Ta, Tb).

% de citit suport de lab%% Exemplu: suma intr 