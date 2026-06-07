binbin segment
assume cs:binbin

	mov bx,43690	;1010101010101010  
	mov ch,16

dondur:
	mov cl,01h
	rol bx,cl
	mov al,bl
	and al,01h
	add al,30h

	mov dl,al
	mov ah,02h
	int 21h
	dec ch
	jnz dondur

	int 20h

binbin ends  
end
