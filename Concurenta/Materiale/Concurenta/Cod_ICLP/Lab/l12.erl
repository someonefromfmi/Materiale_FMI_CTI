-module(l12).
-export([
    main/1
]).

% Problema cu automate 
% Simulam o parcare 
%  Parcarea: avem un numar maxim de locuri 
%  Poarta: avem o poarta care ne permite accesul in parcare 
%  Masina: avem masini care vor sa intre in parcare 
% Daca o masina poate intra in parcare, atunci 
%   (i) se deschide poarta, 
%   (ii) intra, 
%   (iii) sta un anumit timp si 
%   (iv) apoi iese 
% Daca masina nu poate intra in parcare, atunci sta intr-o coada de asteptare (reincearca intrarea)

% Parcarea poate fi open sau full 
% Poarta poate fi open sau closed 
% Masina poate fi waiting sau parking 

% cand simulam automatul, avem doua functii 
% una care porneste automatul 
% respectiv o functie de "loop"

start_parking(TotalSpaces) -> 
  spawn(fun () -> parking_loop(open, TotalSpaces, []) end).

% parametrizata de stare, numarul maxim de locuri, si lista masinilor 
parking_loop(State, SpacesLeft, Cars) -> 
  io:format("Parcare: Stare ~p, Locurile ramase: ~p, Masini: ~p~n", [State, SpacesLeft, Cars]),
  receive 
    {request_entry, CarPid} when State =:= open, SpacesLeft > 0 -> 
      io:format("Permitem accesul masinii ~p~n", [CarPid]),
      CarPid ! {entry_granted, self()}, 
      parking_loop(State, SpacesLeft - 1, [CarPid | Cars]);
    {request_entry, CarPid} when State =:= open, SpacesLeft =:= 0 -> 
      io:format("Parcarea este plina. Refuzam accesul masinii ~p~n", [CarPid]),
      parking_loop(full, SpacesLeft, Cars);
    {car_exit, CarPid} -> 
      io:format("Masina ~p iese din parcare~n", [CarPid]),
      NewCars = lists:delete(CarPid, Cars),
      NewSpaces = SpacesLeft + 1, 
      parking_loop(open, NewSpaces, NewCars); 
    _ -> 
      io:format("Comanda invalida pentru parcare~n"),
      parking_loop(State, SpacesLeft, Cars)
  end. 
  
% Modelam poarta 
start_gate() -> spawn(fun () -> gate_loop(closed) end). 

gate_loop(State) -> 
  io:format("Poarta: Stare ~p~n", [State]),
  receive 
    open_gate when State =:= closed -> 
      io:format("Deschidem poarta~n"),
      gate_loop(open);
    close_gate when State =:= open -> 
      io:format("Inchidem poarta~n"),
      gate_loop(closed);
    open_gate when State =:= open ->
      io:format("Poarta este deja deschisa~n"),
      gate_loop(State);
    close_gate when State =:= closed -> 
      io:format("Poarta este deja inchisa~n"),
      gate_loop(State);
    _ -> 
      io:format("Comanda necunoscuta pentru parcare"),
      gate_loop(State)
  end. 
  
  
% Modelam masina 
start_car(ParkingPid, GatePid) -> spawn(fun () -> car_loop(waiting, ParkingPid, GatePid) end).


car_loop(State, ParkingPid, GatePid) -> 
  io:format("Masina ~p: Stare ~p~n", [self(), State]),
  case State of waiting -> 
    ParkingPid ! {request_entry, self()},
    receive 
      {entry_granted, _Parking} -> 
        io:format("Accesul a fost permis. Cerem de catre ~p deschiderea portii~n", [self()]),
        GatePid ! open_gate, 
        io:format("Intrarea masinii ~p in parcare ~n", [self()]),
        GatePid ! close_gate, 
        car_loop(parking, ParkingPid, GatePid);
      _ -> 
        io:format("Accesul a fost refuzat pentru ~p. Asteptam...~n", [self()]),
        timer:sleep(1000),
        car_loop(waiting, ParkingPid, GatePid)
    end;
  parking -> 
    % simulam ca stam in parcare 
    timer:sleep(3000),
    io:format("Iesim cu masina ~p din parcare~n", [self()]),
    ParkingPid ! {car_exit, self()}, 
    GatePid ! open_gate, 
    io:format("Iesim din parcare cu masina ~p~n", [self()]),
    GatePid ! close_gate, 
    car_loop(waiting, ParkingPid, GatePid)
  end. 
  
main(_) -> 
  ParkingPid = start_parking(2),
  GatePid = start_gate(),
  io:format("======== Simulam masini care cer acces la parcare =========~n"),
  Car1 = start_car(ParkingPid, GatePid),
  Car2 = start_car(ParkingPid, GatePid),
  Car3 = start_car(ParkingPid, GatePid),
  Car1 ! {request_entry, ParkingPid}, 
  timer:sleep(1000),
  Car2 ! {request_entry, ParkingPid}, 
  timer:sleep(1000),
  Car3 ! {request_entry, ParkingPid}, 
  timer:sleep(1000),
  Car1 ! {exit_parking, ParkingPid},
  timer:sleep(1500),
  Car2 ! {request_entry, ParkingPid}, 
  timer:sleep(1000),
  Car2 ! {exit_parking, ParkingPid},
  timer:sleep(1200),
  Car3 ! {exit_parking, ParkingPid},
  timer:sleep(2000). 
  
% Intr-o biblioteca, mai multi studenti solicita acces la un singur terminal 
% de cautare electronica. 
% Acest terminal are doua stari,
% - idle: in care asteapta cereri de acces din partea studentilor 
% - in_use: in care permite unui singur student sa caute informatii timp de 3 secunde 
% Un student poate fi in starea 
% - waiting: daca terminalul este ocupat 
% - searching: cand are acces la terminal. 
% Implementati acest scenariu. 