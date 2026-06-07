binheks segment
assume cs:binheks

	mov bx,43981	;ABCD
	mov ch,4h

dondur:
	mov cl,04h
	rol bx,cl
	mov al,bl
	and al,0Fh
	add al,30h
	cmp al,3Ah	;0..9?
	jl ekrana
	add al,07h	;A..F

ekrana:
	mov dl,al
	mov ah,02h
	int 21h
	dec ch
	jnz dondur

	int 20h

binheks ends
end
