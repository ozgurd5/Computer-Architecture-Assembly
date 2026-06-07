binquad segment
assume cs:binquad
	
	mov bx,228	;3210 
	mov ch,8h

dondur:
	mov cl,2h
	rol bx,cl
	mov al,bl
	and al,03h
	add al,30h

	mov dl,al
	mov ah,02h
	int 21h
	dec ch
	jnz dondur

	int 20h
  
binquad ends  
end
