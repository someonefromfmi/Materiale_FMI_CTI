% ex1

% primul subiect - inferente intr-o kb
% + findall, nu doar inferente si atat
% findall/3: findall(X, P, L). - L = { X | P(X) }
employee_salary(peter, 1000).
employee_salary(peter, 1200).
employee_salary(ana, 300).
employee_salary(andrei, 100).
employee_salary(irina, 500).

salmin(List,MinSal,Res) :- findall(Name, (member(employee_salary(Name,Salary),List), MinSal =< Salary), Res).

salmin_rec([], _, []).
salmin_rec([employee_salary(Name, Sal)|T], MinSal, [Name|TR]) :-
    Sal =< MinSal,
    salmin_rec(T, MinSal, TR), !.
salmin_rec([_|T], MinSal, TR) :-
    salmin_rec(T, MinSal, TR).

% sum_and_count_for_name(+Name, +List, -Sum, -Count)
sum_and_count_for_name(_, [], 0, 0).
sum_and_count_for_name(Name, [employee_salary(Name, Salary) | T], Sum, Count) :-
    sum_and_count_for_name(Name, T, PartialSum, PartialCount),
    Sum is PartialSum + Salary,
    Count is PartialCount + 1.
sum_and_count_for_name(Name, [_ | T], Sum, Count) :-
    sum_and_count_for_name(Name, T, Sum, Count).

% eliminam perechea (Name, Salary) dupa ce am calculat ceea ce ne interesa
remove_name_from_list(_, [], []) :- !.
remove_name_from_list(Name, [employee_salary(Name, _) | T], TRes) :-
    remove_name_from_list(Name, T, TRes).
remove_name_from_list(Name, [H | T], [H | TRes]) :-
    remove_name_from_list(Name, T, TRes).

employee_average_salary([], []).
employee_average_salary([employee_salary(Name, Sal)|T], [(Name, Avg)|TR]) :-
    sum_and_count_for_name(Name, [employee_salary(Name, Sal)|T], ESum, ECount),
    Avg is ESum / ECount,
    remove_name_from_list(Name, [employee_salary(Name, Sal)|T], NewList),
    employee_average_salary(NewList, TR).


mother(wilhelmina,juliana).
mother(juliana,beatrix).
mother(juliana,christina).
mother(juliana,irene).
mother(juliana,margriet).
mother(beatrix,friso).
mother(beatrix,alexander).
mother(beatrix,constantijn).
mother(emma,wilhelmina).
father(hendrik,juliana).
father(bernard,beatrix).
father(bernard,christina).
father(bernard,irene).
father(bernard,margriet).
father(claus,friso).
father(claus,alexander).
father(claus,constantijn).
father(willem,wilhelmina).

% citim mother(beatrix, alexander) ca "beatrix este mama lui alexander". aceeasi interpretare la father 
queen(beatrix).
queen(juliana).
queen(wilhelmina).
queen(emma).
king(willem).

% 4a) definiti urmatoarele predicate
% parent/2 - parent(X, Y). sa fie true cand X este parinte al lui Y 
% ruler(X) - sa fie true cand X este conducator 
parent(X, Y) :- mother(X, Y); father(X, Y).
ruler(X) :- queen(X); king(X).

% 4b) definiti un predicat predecessor/2, astfel incat predecessor(X, Y) sa ne spuna ierarhia de predecesori pentru un conducator X
% (vrem sa raspundem, de fapt, la cine precede pe cine)
predecessor(X, Y) :- parent(Y, X), ruler(Y).
predecessor(X, Y) :- 
    parent(Z, Y),
    predecessor(Z, X),
    ruler(Z).

% Exercitiul 8
% Fie urmatoarea baza de cunostinte, definita de predicatele 
% 	employee_info(name, department_number, scale)
%	department(department_number, department_name)
%	salary(scale, amount)

employee_info(mcardon,1,5).
employee_info(treeman,2,3).
employee_info(chapman,1,2).
employee_info(claessen,4,1).
employee_info(petersen,5,8).
employee_info(cohn,1,7).
employee_info(duffy,1,9).
department(1,board).
department(2,human_resources).
department(3,production).
department(4,technical_services).
department(5,administration).
salary(1,1000).
salary(2,1500).
salary(3,2000).
salary(4,2500).
salary(5,3000).
salary(6,3500).
salary(7,4000).
salary(8,4500).
salary(9,5000).

% a) determinati toti angajatii din departamentul 1 si care au scale > 2 
% Exemplu pentru rezolvare
% ?- employee_info(Name, Department_Number, Scale), Department_Number = 1, Scale > 2
exa_res(Res) :- findall(Name, (employee_info(Name, 1, Scale), Scale > 2), Res).

% acum, puneti toate aceste rezultate intr-o singura lista

% b) determinati toti angajatii dintr-un anume departament
exb_res(DepName, Res) :-
    findall(
        Name, 
        (employee_info(Name, DepNum, _), department(DepNum, DepName)),
        Res
        ).

% c) selectati name si scale al angajatilor din departamentul 1, si scale > 3    
exc_res(Res) :-
    findall((Name,Scale), (
        employee_info(Name, 1, Scale),
        Scale > 3
    ), Res).

% Exercitiul 7
% verificati daca un sir de caractere primit ca intrare, si reprezentat ca un atom, este palindrom sa nu
% palindrome(prolog). atunci false
% palindrome(ele). atunci true

%string_chars(prolog,X).
palindrome([]).
palindrome(X) :-
    string_chars(X, XChars),
    reverse(XChars, RevCHars),
    XChars == RevChars.

% Exercitiul 6 
% Fie predicatele succ/2 si obj/1 (pentru succesor si obiectiv din BFS). 
% Adaptati algoritmul BFS astfel incat sa pastram drumurile cele mai scurte care ajung de la un nod de start la un nod obiectiv.

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

min([X], X) :- !.
min([H|T], H) :-
    min(T, MinT),
    H =< MinT.
min([H|T], MinT) :-
    min(T, MinT),
    H > MinT.

shortest_path(List, MinLength) :-
    findall(
        Length,
        (member(L, List), length(L, Len)),
        Res
    ),
    min(Res, MinLength),
    findall(L, (member(L, List), length(L, MinLength)), FinalResult).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
elements_of(H, [H|T]) :- !.
elements_of(H, [_|T]) :-
    elements_of(H, T).

% Exercitiul 3
% Primind o lista identica celei de la exercitiul 2, in lista de rezultat ordonati angajatii dupa salariul mediu castigat, in ordine descrescatoare. 
% ?- sort_employee_average_salary([employee_salary(peter, 1000), employee_salary(oliver, 1200), employee_salary(sam, 700), employee_salary(oliver, 800), employee_salary(sam, 900), employee_salary(sandra, 4500), employee_salary(peter, 1200), employee_salary(oliver, 400)], Result).
% Result = [(sandra, 4500), (peter, 1100), (oliver, 800), (sam, 800)]
my_cmp(X, (_, Sal1), (_, Sal2)) :-
    compare(X, Sal2, Sal1).

sort_employee_average_salary(L, SL) :-
    employee_average_salary(L, AvgL),
    predsort(my_cmp, AvgL, SL).
