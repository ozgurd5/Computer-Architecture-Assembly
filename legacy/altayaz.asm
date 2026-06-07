;Alt alta yazdırma
program SEGMENT
		ASSUME CS:program,DS:program
		ORG 100h
start:
		MOV DL,41h
		MOV AH,02h
		INT 21h
		MOV	DL,0Ah
		MOV	AH,02h
		INT	21h
		MOV	DL,42h
		MOV	AH,02h
		INT	21h
		MOV	DL,0Ah
		MOV	AH,02h
		INT	21h
		MOV	DL,43h
		MOV	AH,02h
		INT	21h
		INT 20h
program ENDS
		END start