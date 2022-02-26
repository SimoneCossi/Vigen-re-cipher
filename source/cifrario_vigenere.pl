/* Programma Prolog che implementa il cifrario di Vigenère */

/*	 MAIN 	   */

/* funzione main che chiede all'utente se vuole cifrare o decifrare un testo
   in base alla scelta dell'utente chiama la funzione per cifrare o decifrare un messaggio */

main :- 
	nl,
	write('Questo programma Prolog contiene al suo interno il cifrario di Vigenere'), nl,
	write('Si puo scegliere se cifrare o decifrare un messaggio secondo una chiave:'), nl,
	write('Scrivere 1 per cifrare una parola o un messaggio'), nl,
	write('Scrivere 2 per decifrare una parola o un messaggio'), nl,
	validazione_scelta(Scelta),
	if_scelta(Scelta, cifrare, decifrare).
	

/*	 FUNZIONI DI SUPPORTO	  */

/* funzione che in base al valore di 'C' esegue 'I1' o 'I2' */

if_scelta(C, I1, _) :- C=1, !, I1.
if_scelta(C, _, I2) :- C=2, !, I2.


/* funzione che in base al valore di 'Condizione' esegue 'I1' o 'I2' 
   I numeri utilizzati nelle operazioni corrispondono a dei caratteri in codice ASCII  */

if_Mm(Condizione, I1, _) :-	(Condizione < 91, Condizione > 64), !, I1.
if_Mm(Condizione, _, I2) :-	(Condizione > 96, Condizione < 123), !, I2.


/* funzione che in base al valore di 'Condizione' esegue 'I1' o 'I2' 
   Il numero utilizzato nelle operazioni corrisponde a allo spazio in codice ASCII  */

if_spazio(Condizione, I1, _) :- (Condizione \= 32), !, I1.
if_spazio(Condizione, _, I2) :- (Condizione == 32), !, I2.


/* funzione che in base al valore di 'c' esegue 'I1' o 'I2' */
if_validazione(C, I1, _) :- C=1, !, I1.
if_validazione(C, _, I2) :- C=0, !, I2.


/* funzione che controlla la lunghezza della chiave e del testo
	- chiave > testo -> concateno la chiave a sé stessa in modo da ripeterla
	- chiave < testo -> taglio la chiave in base alla lunghezza del testo
	- chiave = testo -> restituisco la chiave in modo che abbia la stessa lunghezza del testo */

if_lunghezza(Testo, Chiave, R) :- 
	(length(Chiave, C), length(Testo, T), C < T),
	(append(Chiave,Chiave, Risultato),
	if_lunghezza(Testo, Risultato, R)),
	!.

if_lunghezza(Testo, Chiave, R) :- 
	(length(Chiave, C), length(Testo, T), C > T),
	(length(Testo, Lrisultato),
	dividi(Lrisultato, Chiave, X, _),
	if_lunghezza(Testo, X, R)),
	!.

if_lunghezza(Testo, Chiave, R) :- 
	(length(Chiave, C), length(Testo, T), C == T),
	R = Chiave,
	!.


/* funzione che sottrae a 'D' 65 o 97 in modo che quando è utilizzata 
   per la cifratura o decifratura possa scorrere correttamente l'alfabeto 
   I numeri utilizzati nelle operazioni corrispondono a dei caratteri in codice ASCII  */

maiuscola(D, D1) :- D1 is D-65.
minuscola(D, D1) :- D1 is D-97.


/* funzione che divide una stringa in due parti nella posizione passatole tramite 'Indice' */

dividi(Indice, Lista, Sinistra, Destra) :-
   length(Sinistra, Indice),       
   append(Sinistra, Destra, Lista).


/*	 VALIDAZIONE	  */

/* Funzione che acquisisce dei caratteri e controlla se è stato inserito
   solamente '1' o '2' 
   nel caso l'utente abbia inserito altro gli viene comunicato di reinserire '1' o '2'*/
validazione_scelta(Input) :-
	repeat, 
		read(Input), nl,
	(
		Input == 1 , !
	;	Input == 2 , !
	;	write('input non valido, inserire solamente 1 o 2:'), nl, fail
	).


/* funzione che acquisisce una stringa e controlla che sia composta solo da
   lettere non accentate e spazi
   nel caso contenga altro chiede all'utente di inserire una nuova stringa */

validazione_input(Input) :-
	repeat,
		read(Input),
	(   validazione_lista(Input) -> true , !
	;   write('\ninput non valido, inserire solamente lettere maiuscole, minuscole e spazi:'), nl, fail
	).

/* funzione ricorsiva in modo che 'validazione_lettera' possa scorrere tutte la lista */

validazione_lista([]).
validazione_lista([TESTA|CODA]) :-
	validazione_lettera(TESTA),
	validazione_lista(CODA).

/* funzione che controlla ogni singolo carattere, 
   se il carattere non rientra tra quelli ammessi avvisa l'utente di dover inserire un nuovo input 
   I numeri utilizzati nelle operazioni corrispondono a dei caratteri in codice ASCII  */

validazione_lettera(32).
validazione_lettera(Lettera):- between(65, 90, Lettera).
validazione_lettera(Lettera):- between(97, 122, Lettera).
	

/*		CIFRATURA 	  */

/* funzione che chiede all'utente di inserire la chiave di cifratura e il testo da cifrare
   i due input vengono validati e quando entrambi vengono ritenuti accettabili
   si chiama la funzione per cifrare il messaggio */

cifrare :- 
	write('Hai scelto di cifrare un messaggio'), nl,
	write('NB. ricordarsi di scrivere la chiave e il messaggio racchiusi tra ""'), nl,
	write('esempio: "Chiave o Testo"'), nl,
	write('Inserisci la chiave di codifica:'), nl,
	validazione_input(Chiave), nl,
	write('Inserisci il messaggio che vuoi cifrare:'), nl,
	validazione_input(Messaggio),
	if_lunghezza(Messaggio, Chiave, NuovaChiave),
	vigenere(Messaggio, NuovaChiave, Cifrato),
	write('\nIl messaggio cifrato e\':\t'), write(Cifrato).
	

/* funzione che cripta un messaggio tramite una chiave*/

vigenere(Testo, Chiave, Cifrato) :- 
	nonvar(Testo), 
	nonvar(Chiave), 
	vigenere_lista(Testo, Chiave, L1), 
	name(Cifrato, L1).


/* funzione che controlla se la lettera che sta andando a criptare è uno spazio:
	se fosse uno spazio non verrebbe cifrata e si procede con quelle successive
	se fosse una lettera si procede con la cifratura e poi si procede con le lettere successive
  	funziona tramite ricorsione */

vigenere_lista([], [], []).
vigenere_lista([TESTA|CODA], [TESTA1|CODA1], [TESTA2|CODA2]) :-
	if_spazio(TESTA,
	vigenere_lista_lettera([TESTA|CODA], [TESTA1|CODA1], [TESTA2|CODA2]),
	vigenere_lista_spazio([TESTA|CODA], CODA1, [TESTA2|CODA2])).


/* funzione che viene utilizzata quando una lettera risulta essere uno spazio
	(sia del testo che della chiave)
   restituisce la lettera originale o uno spazio in base al suo utilizzo e procede 
   con la cifratura delle lettere successive */

vigenere_lista_spazio([], _, []).
vigenere_lista_spazio([TESTA|CODA], CODA1, [TESTA2|CODA2]) :-
	TESTA2 is TESTA,
	vigenere_lista(CODA,CODA1, CODA2).


/* funzione che viene utilizzata quando la lettera in cifratura non è uno spazio
   si verifica se la lettera della chiave è uno spazio
   - in caso fosse uno spazio si chiama la funzione vigenere_lista_spazio
   - in caso non fosse uno spazio si chiama vigenere_lettera per la cifratura della lettera 
     e vigenere_lista per la cifratura delle lettere successive */

vigenere_lista_lettera([], [], []).
vigenere_lista_lettera([TESTA|CODA], [TESTA1|CODA1], [TESTA2|CODA2]) :-
	if_spazio(TESTA1,
	(if_Mm(TESTA1, maiuscola(TESTA1, TESTA3), minuscola(TESTA1, TESTA3)), 
	vigenere_lettera(TESTA, TESTA3, TESTA2), 
	vigenere_lista(CODA,CODA1, CODA2)),
	vigenere_lista_spazio([TESTA|CODA], CODA1, [TESTA2|CODA2])).


/* funzione che cifra una lettera in base a una chiave
   una lettera maiuscola rimarrà maiuscola mentre una minuscola rimarrà minuscola 
   nonostante la chiave possa essere maiuscola o minuscola 
   sviluppata come un if_the_else in modo da comportarsi in maniera differente 
   in base alla lettera da cifrare passatole 
   I numeri utilizzati nelle operazioni corrispondono a dei caratteri in codice ASCII */

vigenere_lettera(T, C, U) :-
	(U1 is T + C, U1 > 90, T < 91), 
	U is U1 - 26, 
	!.

vigenere_lettera(T, C, U) :-
	(U1 is T + C, U1 >122, T > 96), 
	U is U1 - 26, 
	!.

vigenere_lettera(T, C, U) :- 
	U is T + C.


/*	 DECIFRATURA 	  */

/* funzione che chiede all'utente di inserire la chiave di decifratura e il testo da decifrare
   successivamente chiama la funzione per decifrare il messaggio */

decifrare :-
	write('Hai scelto di decifrare un messaggio'), nl,
	write('NB. ricordarsi di scrivere la chiave e il messaggio racchiusi tra ""'), nl,
	write('Inserisci la chiave di decodifica:'), nl,
	validazione_input(Chiave), nl,
	write('Inserisci il messaggio che vuoi decifrare:'), nl,
	validazione_input(Messaggio),
	if_lunghezza(Messaggio, Chiave, NuovaChiave),
	unvigenere(Messaggio, NuovaChiave, Decifrato),
	write('\nIl messaggio decifrato e\':\t'), 
        write(Decifrato).


/* funzione che decripta un messaggio tramite una chiave */

unvigenere(Testo, Chiave, Cifrato) :- 
	nonvar(Testo), 
	nonvar(Chiave), 
	unvigenere_lista(Testo, Chiave, L1), 
	name(Cifrato, L1).


/* funzione che controlla se la lettera che sta andando a decriptare è uno spazio:
      -	se fosse uno spazio non verrebbe decifrata e si procede con quelle successive
      -	se fosse una lettera si procede con la decifratura e poi si procede con le lettere successive
   funziona tramite ricorsione */

unvigenere_lista([], [], []).
unvigenere_lista([TESTA|CODA], [TESTA1|CODA1], [TESTA2|CODA2]) :-
	if_spazio(TESTA,
	unvigenere_lista_lettera([TESTA|CODA], [TESTA1|CODA1], [TESTA2|CODA2]),
	unvigenere_lista_spazio([TESTA|CODA], CODA1, [TESTA2|CODA2])).


/* funzione che viene utilizzata quando una lettera risulta essere uno spazio
	(sia del testo che della chiave)
   restituisce la lettera originale o uno spazio in base al suo utilizzo 
   e procede con la decifratura delle lettere successive */

unvigenere_lista_spazio([], _, []).
unvigenere_lista_spazio([TESTA|CODA], CODA1, [TESTA2|CODA2]) :-
	TESTA2 is TESTA,
	unvigenere_lista(CODA,CODA1, CODA2).


/* funzione che viene utilizzata quando la lettera in decifratura non è uno spazio
   si verifica se la lettera della chiave è uno spazio
   - in caso fosse uno spazio si chiama la funzione unvigenere_lista_spazio
   - in caso non fosse uno spazio si chiama unvigenere_lettera per la decifratura della lettera 
     e unvigenere_lista per la decifratura delle lettere successive */

unvigenere_lista_lettera([], [], []).
unvigenere_lista_lettera([TESTA|CODA], [TESTA1|CODA1], [TESTA2|CODA2]) :-
	if_spazio(TESTA1,
	(if_Mm(TESTA1, maiuscola(TESTA1, TESTA3), minuscola(TESTA1, TESTA3)), 
	unvigenere_lettera(TESTA, TESTA3, TESTA2), 
	unvigenere_lista(CODA,CODA1, CODA2)),
	unvigenere_lista_spazio([TESTA|CODA], CODA1, [TESTA2|CODA2])).


/* funzione che decifra una lettera in base a una chiave
   una lettera maiuscola rimarrà maiuscola mentre una minuscola rimarrà minuscola nonostante 
   la chiave possa essere maiuscola o minuscola 
   sviluppata come un if_the_else in modo da comportarsi in maniera differente in base alla lettera
   da decifrare passatole 
   I numeri utilizzati nelle operazioni corrispondono a dei caratteri in codice ASCII  */

unvigenere_lettera(T, C, U) :-
	(U1 is T - C, U1 <65, T < 91), 
	U is U1 + 26, 
	!.

unvigenere_lettera(T, C, U) :-
	(U1 is T - C, U1 < 97, T > 96), 
	U is U1 + 26, 
	!.

unvigenere_lettera(T, C, U) :- 
	U is T - C.