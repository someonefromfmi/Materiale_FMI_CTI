:- include('words.pl').

% Recursie cu acumulator
/*Def un pred rev/2 care verif daca o lista este inversa altei liste.*/
rev([],[]).
rev([X|T],L) :- rev(T,R), append(R,[X],L).

% acc
rev(L, R) :- revac(L, [], R).
%la mom init nu am acc nmc
revac([], R, R).
% cand list init a fost consumata
% am acc rez fin
revac([X|T], Acc, R) :- revac(T,[X | Acc], R).
% Acc cont inversa listei care a fost deja parcursa

biglist(0, []).
biglist(N,[N|T]) :- N >= 1, M is N-1, biglist(M,T), M = M.

biglist_tr(0, []).
biglist_tr(N,[N|T]) :- N >= 1, M is N-1, biglist_tr(M,T).

sum([], 0).
sum([X|T],R) :- sum(T,S), R is S+X.

sumac(L,R) :- sumaux(L,0,R).
sumaux([], S, S).
sumaux([X|T],S,R) :- S1 is S+X, sumaux(T,S1,R).

% Genereaza si testeaza
% Det toate cuv dintro kb data, care sunt anagrame ale unui cuvant.
word(relay). word(early). word(layer).
% name(relay, L) % conv intre atomi si liste

% Abordare 1:
anagram1(A,B) :- name(A,L), permutation(L,W),
                 name(B,W), word(B).

% Abordare 2:
anagram2(A,B) :- name(A,L), word(B),
                 name(B, W), permutation(L,W).

cuvant(L,[H|T]) :- member(H, L), cuvant(T).

% countdown
cover([], _).
cover([Head|Tail], List) :-
    select(Head, List, Result),
    cover(Tail, Result).

word_letters(Word, Letters) :- atom_chars(Word, Letters).

solution(ListLetters, Word, Score) :-
    word(Word),
    word_letters(Word, Letters),
    length(Letters, Score),
    cover(Letters, ListLetters).

topsolution(ListLetters, Word, Score) :-
    length(ListLetters, X),
    search_solution(ListLetters, Word, X),
    atom_length(Word, Score).

search_solution(_, '', 0).
search_solution(ListLetters, Word, X) :-
    solution(ListLetters, Word, X).
search_solution(ListLetters, Word, X) :-
    Y is X - 1,
    search_solution(ListLetters, Word, Y).
% Nu uitati de select
% select(X, L, R) R\X - util cand vrei un elem arbitrar al unei liste

% litera(X) :- member(X, [...]). % tine locul kb

% atom_chars(Atom,CharList) - descomp un atom intr-o lista de chars

% Structura generala a unui joc / Jocul Nim
play(Game) :- initialize(Game, Position, Player),
              display_game(Position),
              play(Position, Player).

% jucatorii sunt computer is oponent
% poz init este [1,3,5,7]

initialize(nim, [1,3,5,7], opponent).
display_game(P) :- write(P), nl.
game_over([], Player, Player).

announce(computer) :- write('You won! Congratulations.'), nl.
announce(opponent) :- write('I won.'), nl.

play(Position, Player) :- game_over(Position, Player, Result),
                          !, announce(Result).
play(Position, Player) :- choose_move(Position, Player, Move),
                          move(Move, Position, Position1),
                          display_game(Position1),
                          next_player(Player, Player1),
                          !, play(Position1, Player1).

% nth1(K,L,X) este true daca X este elem din pozitia K din lista L, unde prima poz e 1

legal((K,N), Position) :- 0 < K, 0 < N,
                          nth1(L, Position, M),
                          N =< M.

choose_move(Position, opponent, Move) :-
    writeln(['Please make a move']),
    read(Move), legal(Move, Position).
choose_move(Position,opponent,Move) :-
    writeln(['Illegal move!']),
    choose_move(Position, opponent, Move).
choose_move(Position, computer, (K,M)) :-
    length(Position, L),
    random_between(1, L, K),
    nth1(K, Position, N),
    random_between(1, N, M).

move((1,N), [N|Ns], Ns).
move((1,M), [N|Ns], [N1,Ns]) :- N > M, N1 is N - M.
move((K,M), [N|Ns], [N1,Ns1]) :- K > 1, K1 is K - 1,
                                 move((K1,M),Ns,Ns1).

% next_player(computer, opponent).
% next_player(opponent, computer).
% word_le

% Am o form in cnf, sa ii fac forma clauzala
% toclausal(X, [[X]]) :- literal(X).
% toclausal(A si B, R) :- toclausal(A, RA), toclausal(B,RB),
%                         union(RA, RB, R).
% toclausal(A sau B, [R]) :- literal(A), toclausal(B, [RB]),
%                            union([A], RB, R).

% trivial(L) :- select(X,L,_), is_var(X), subset([X, nu X], L).
% remove_trivial([], []).
% remove_trivial([C|L], R) :- trivial(C), remove_trivial(L,R).
% remove_trivial([C|L], [C|R]) :- remove_trivial(L,R).

% clausal_form(F, FC) :- cnf(F, CNF), toclausal(CNF,LC).

