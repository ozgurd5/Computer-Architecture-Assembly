bindec segment
assume cs:bindec

	mov ax,12345
	mov bx,10
	xor cx,cx

bol:
	xor dx,dx
	div bx
	push dx
	inc cx
	cmp ax,0
	jnz bol

yaz:
	pop dx
	add dl,30h
	mov ah,02h
	int 21h
	loop yaz

	int 20h

bindec ends
end
