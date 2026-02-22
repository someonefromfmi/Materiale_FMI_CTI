	ORG 30h
setup: 	MOV A,#0
		MOV R0,#0
load: 	MOV A,P1
		ANL A,#0x0F
		CALL sqrt
		MOV P2,A
		JMP load
sqrt: 
	INC A
	MOVC A, @A+PC
	RET 
db 0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3

; CALL:
; 1) Modifica PC in stiva
; 2) Modifica val PC cu adr destinatiei
; 3) Cand intalneste RET face POP stivei si intoarce val in SFR PC

; ATENTIE!!!!
; atunci cand lucram cu stiva in interiorul unei proceduri,
; trb sa ne asiguram ca instructiunie sunt pare
; De regula se salveaza val din reg
; importanti: A, B, R [\d]

