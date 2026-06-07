;ASCII karakter tablosunun tersten yazılması
program SEGMENT
		ASSUME CS:program,DS:program
		ORG 100h
start:
		MOV CX,100h
		MOV DL,0ffh
dongu:
		MOV AH,02h
		INT 21h
		DEC DL
		LOOP dongu
		INT 20h
program ENDS
		END start