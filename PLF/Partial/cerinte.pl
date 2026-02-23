% NUME: 
% PRENUME: 
% GRUPA: 

% Redenumiti sursa astfel: grupa_nume_prenume1prenume2.pl 
% Exemplu: 365_popescu_lefterandrei_1.pl

% LINK PENTRU SUBMISIE: https://forms.gle/T4dJTH36Wo7d1HVv6

% NU aveti voie sa folositi alt material, in afara celui care v-a fost trimis pentru testare!
% NU aveti voie sa folositi nici Copilot, nici LLM-uri! 
% NU aveti voie sa discutati in timpul testarii.
% Puteti folosi varianta online, iar in acest caz, site-ul https://swish.swi-prolog.org/ este singurul pe care il puteti accesa.
% Daca folositi varianta online, salvati-va regulat solutiile intr-un fisier local! 
% Timpul de lucru este de 1h, care nu include si submiterea. 

% Punctajul maxim pe care il puteti obtine este de 30p.
% Pentru a promova, sunt necesare 10p din cele 30p!

% Asigurati-va ca nu omiteti cerintele! Puteti "bifa" mai jos subiectele pe care le-ati rezolvat
% Subiectul I are subpunctele 
% 	a (2p)
% 	b (2p) 
% 	c (3p) 
% 	d (3p)
% Subiectul al II-lea are subpunctele 
% 	a (2p) 
% 	b (5p) 
% 	c (3p)
% Subiectul al III-lea are subpunctele 
% 	a (3p) 
% 	b (7p)

% SUBIECTE 

% SUBIECTUL I 

% Fie urmatoarea baza de cunostinte, definita prin predicatele 

% books/5: 		books(BookId, Title, AuthorId, PublisherId, FieldId).
% authors/3:		authors(AuthorId, Name, Affiliation).
% publishers/3: 	publishers(PublisherId, PublisherName, Country).
% fields/2: 		fields(FieldId, FieldName).
% editions/4: 		editions(EditionId, BookId, EditionNumber, Year).

fields(1, 'Mathematics').
fields(2, 'Computer Science').
fields(3, 'Philosophy').
fields(4, 'Physics').
fields(5, 'Linguistics').

authors(1, 'Donald Knuth', 'Stanford University').
authors(2, 'Bertrand Russell', 'University of Cambridge').
authors(3, 'Noam Chomsky', 'MIT').
authors(4, 'Roger Penrose', 'University of Oxford').
authors(5, 'Terence Tao', 'University of California, Los Angeles').

publishers(1, 'Springer', 'Germany').
publishers(2, 'MIT Press', 'USA').
publishers(3, 'Cambridge University Press', 'UK').
publishers(4, 'Oxford University Press', 'UK').
publishers(5, 'Addison-Wesley', 'USA').

books(101, 'The Art of Computer Programming', 1, 5, 2).
books(102, 'Principia Mathematica', 2, 3, 1).
books(103, 'Syntactic Structures', 3, 2, 5).
books(104, 'The Road to Reality', 4, 4, 4).
books(105, 'Analysis I', 5, 1, 1).
books(106, 'Modern Quantum Mechanics', 4, 1, 4).
books(107, 'Formal Semantics and Logic', 3, 3, 5).
books(108, 'Linear Algebra Done Right', 5, 5, 1).

editions(201, 101, 1, 1968).
editions(202, 101, 2, 1973).
editions(203, 102, 1, 1910).
editions(204, 102, 2, 1927).
editions(205, 103, 1, 1957).
editions(206, 104, 1, 2004).
editions(207, 105, 1, 2006).
editions(208, 106, 1, 1995).
editions(209, 107, 1, 1971).
editions(210, 108, 3, 2017).


% [2 puncte]
% I a) Determinati toate cartile care au fost scrise de un autor dat. 
% Definiti predicatul wroteBy/2, care primeste numele autorului si intoarce lista tuturor titlurilor de carti pe care le-a scris.
% De exemplu, ?- wroteBy('Noam Chomsky', Result). trebuie sa raspunda cu Result = ['Syntactic Structures', 'Formal Semantics and Logic']

% [2 puncte]
% I b) Determinati lista editurilor (publishers) care au publicat carti de matematica sau de filosofie.
% Definiti predicatul publishedMathPhilosophy/1 care returneaza lista numelor editurilor care satisfac cerinta.
% ?- publishedMathPhilosophy(Result). trebuie sa raspunda cu Result = ['Springer', 'Cambridge University Press', 'Addison-Wesley']

% [3 puncte]
% I c) Determinati lista tuturor cartilor, insotite de numele autorului, care au cel putin o editie dupa un anumit an primit ca argument (inclusiv anul primit).
% Definiti predicatul editionAfterYear/2 care primeste un an si returneaza lista tuturor perechilor (carte, autor) cerute. 
% De exemplu, ?- editionAfterYear(2000, Result). trebuie sa raspunda cu Result = [('The Road to Reality','Roger Penrose'), ('Analysis I','Terence Tao'), ('Linear Algebra Done Right','Terence Tao')]

% [3 puncte]
% I d) Determinati, pentru fiecare tara (obtinuta de la publisher), cate carti au fost publicate.
% Scrieti un predicat countByCountries/1 care returneaza lista de tari, impreuna cu numarul de carti. 
% ?- countByCountries(Result). trebuie sa raspunda cu Result = [('Germany',2), ('USA',3), ('UK',3), ('USA',3)]
% In rezolvare, puteti folosi predicatul count de mai jos.
% Atentie la duplicate! Vrem o singura aparitie pentru fiecare tara! 

count([], 0) :- !.
count([_ | T], Res) :-
    count(T, ResT),
    Res is ResT + 1.

% SUBIECTUL al II-lea

% [2 puncte]
% II a) Scrieti un predicat splitListEvenOdd/3 care primeste ca prim argument o lista
% si returneaza in al doilea argument sublista elementelor pare
% respectiv in al treiela argument sublista elementelor impare
% ?- splitListEvenOdd([4, 2, 10, 2, 5, 7, 13, 8, 19, 27, 32, 40, 16], EvenList, OddList).
% EvenList = [4, 2, 10, 2, 8, 32, 40, 16], OddList = [5, 7, 13, 19, 27]


% [5 puncte] 
% II b) % Scrieti un predicat findSublist/3 care primeste o lista L, o suma S si returneaza o sublista Sublist
% astfel incat Sublist este prima sublista a listei initiale care are suma elementelor egala cu S 
% unde o sublista este definita ca o secventa consecutiva de elemente din lista 
% daca nu exista nicio astfel de sublista, se returneaza false 

% findSublist(L, S, Sublist), exemple de apel
% ?- findSublist([1,2,3,4,5], 9, Sublist).
% Sublist = [2,3,4].
% ?- findSublist([1,2,3,4,5], 15, Sublist).
% Sublist = [1,2,3,4,5]
% ?- findSublist([1,2,3,4,5], 100, Sublist).
% false. 


% [3 puncte]
% II c) Scrieti un predicat solution/3 care primeste o lista de elemente intregi, o suma S
% si returneaza, in al treilea argument o sublista  Sol, astfel incat:
% 1. suma elementelor din sublista Sol sa fie egala cu S  
% 2. Sol este o sublista de numerelor pare consecutive sau o sublista de numare impare consecutive din lista initiala; de exemplu in lista [1,2,3,5,4] elementele 2 si 4 sunt numere pare consecutive, iar 1,3,5 sunt numere impare consecutive
% 3. daca Sol contine numere pare atunci cu siguranta exista si o lista de numere impare cu suma S, de lungime <= cu lungimea lui Sol
% 4. daca Sol contine numere impare atunci cu siguranta exista si o lista de numere pare cu suma S, de lungime < cu lungimea lui Sol  
% 5. predicatul esueaza daca nu exista liste cu numere pare si liste cu numere impare consecutive care au suma S.

% ?- solution([3,2,1,4,5,6], 6, Sol).
% Sol = [2, 4]
% Observatie: se putea obtine si din [1, 5], si din [2, 4], dar s-a preferat lista elementelor pare 

% ?- solution([1, 1,2,1,6,5,6], 8, Sol).
% Sol = [1, 1, 1, 5]
% Observatie: se putea obtine 8 si din [2, 6], dar s-a preferat cea mai lunga dintre subliste 

% ?- solution([1, 1,2,1,6,5,6], 12, Sol).
% false 
% Observatie: se poate obtine 12 din [6, 6], dar pe impare nu se poate obtine, deci false conform conditiei 5

    
% SUBIECTUL al III-lea 

% Pentru acest exercitiu, veti calcula rezolventul a doua clauze. 

% O clauza se numeste triviala atunci cand contine atat o variabila propozitionala p, cat si negarea ei, non(p).
% De exemplu, o clauza [a, non(b), non(c), non(a)] este triviala, intrucat contine atat a, cat si non(a). 
% In acest exercitiu, consideram ca toate clauzele sunt NETRIVIALE. (i.e. nicio clauza nu este triviala)

% [3 puncte]
% III a) Scrieti un predicat literalForResolution/3 care primeste doua clauze C1 si C2, si returneaza primul literal care poate fi utilizat in rezolutie.
% In cazul in care nu exista un astfel de literal, se va intoarce false.
% Un literal se defineste ca literal ::= p | non(p), unde p este un atom propozitional (din Var). 
% Un literal poate fi utilizat in rezolutie daca apare intr-o clauza, iar in cealalta apare negat, sau vice-versa. 
% De exemplu, daca p apare in C1, si non(p) apare in C2, atunci p este un literal care poate fi utilizat in rezolutie.
% La fel, daca non(p) apare in C1, si p apare in C2, atunci p este un literal care poate fi utilizat in rezolutie.

% ?- literalForResolution([a, non(b), non(c)], [b, non(a)], L).
% L = a 
% ?- literalForResolution([d, non(b), non(c)], [b, non(a), c], L).
% L = b 
% ?- literalForResolution([d, non(b), non(c)], [x, non(y), z], L).
% false 


% [7 puncte]
% III b) Scrieti un predicat rezolvent/3 care sa calculeze rezolventul a doua clauze, daca cele doua clauze au un rezolvent, si false in caz contrar.
% Pentru a calcula rezolventul, avem nevoie de o clauza C1 in care avem literalul p, si o clauza C2 in care avem literalul non(p)
% (sau invers, in C1 avem non(p) si in C2 avem p), unde p este orice variabila propozitionala (din Var)
% Rezolventul este C1 reunit C2
% C1 reunit {p}, C2 reunit {non(p)} => Rezolvent = C1 reunit C2
% 
% ?- rezolvent([a, non(b), c], [d, c, b, a], Rezolvent).
% ?- Rezolvent = [d, c, a]
% ?- rezolvent([b], [non(b)], Rezolvent).
% Rezolvent = []
% ?- rezolvent([p, q, r], [p, q, s], Rezolvent).
% false 

% Observatie: Pentru a sterge un element dintr-o lista, puteti folosi predicatul select/3 (vedeti detalii in breviarul teoretic)
% Exemplu de apel:
% ?- select(a, [b, a, c], Result).
% Result = [b, c]
% ?- select(a, [b, c], Result).
% false 