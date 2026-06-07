
dec2hex segment

	assume cs:dec2hex

	mov bx,65432  ; Decimal
	
	mov ch,4
dondur:	
	mov cl,4
	rol bx,cl
	mov al,bl
	and al,0Fh
	add al,30h
	cmp al,3Ah
	jl ekrana
	add al,07h
	
ekrana:				
	mov dl,al
	mov ah,02h
	int 21h
	dec ch
	jnz dondur
	
	int 20h			
; HexaDecimal => FF98	
dec2hex ends

end

