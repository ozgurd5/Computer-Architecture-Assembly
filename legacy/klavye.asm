;klavyede basilan bir tusun scan ve ascii kodlarini ekrana basar

display equ 02h
doscagir equ 21h

klavye segment

ana_prog proc far
	assume cs:klavye
basla:
	mov ah,0     ;klavyeden oku
	int 16h
	mov bx,ax   ; scan kod ah,  ascii kod al
	
	call binheks
	
	mov dl,20h	;boşluk
	mov ah,display
	int doscagir
	
	mov dl,bl		;ascii kod
	mov ah,display
	int doscagir
	
	mov dl,0Dh
	mov ah,display
	int doscagir
	mov dl,0Ah
	mov ah,display
	int doscagir

	jmp basla
	
	ret

ana_prog endp


binheks proc near

		mov ch,4
		mov cl,4
dondur:
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
		
		ret
binheks endp

klavye ends

end basla
