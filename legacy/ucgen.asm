program SEGMENT
ASSUME CS:program,DS:program
 ORG 100h
 start:
	int 10h
	mov ah,00h
	mov al,03h
	mov cl, 1  ; cl = loop counter
	loop_begin:
		; goto xy
		mov dl, 20
		sub dl, cl ; dl = a - i - 1
		dec dl

		mov dh, cl ; dh = i

		mov ah, 02h
		mov bh, 0h
		int 10h

		; calculate cx
		mov ax, cx
		mov bx, 2
		mul bx
		dec ax
		mov cx, ax

		; print char
		mov ah, 0ah
		mov al, 42
		int 10h

		; restore cx
		mov ax, cx
		inc ax
		div bx
		mov cx, ax

		inc cl ; i++

	loop_end:
		cmp cl, 20
		jne loop_begin	
	
	
    INT 20h
 
program ENDS		
 END start

 
 
 
 
 
 
 
 
 
 
 
 
 