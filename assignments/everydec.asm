everydec segment
assume cs:everydec

	mov di,65

ana_dongu:
	call ikili
	mov dl,','
	call ara
	call onluk
	mov dl,','
	call ara
	call onaltili
	mov dl,':'
	call ara
	call karakter
	call satir

	inc di
	cmp di,75
	jb ana_dongu

	int 20h

ara proc near
	mov dh,dl
	mov dl,' '
	call yaz
	mov dl,dh
	call yaz
	mov dl,' '
	call yaz
	ret
ara endp

satir proc near
	mov dl,13	;newline (CR)
	call yaz
	mov dl,10	;newline (LF)
	call yaz
	ret
satir endp

yaz proc near
	mov ah,02h
	int 21h
	ret
yaz endp

ikili proc near
	mov bx,di
	mov ch,08h
	mov cl,01h
i_dongu:
	rol bl,cl
	mov dl,bl
	and dl,01h
	add dl,30h
	call yaz
	dec ch
	jnz i_dongu
	ret
ikili endp

onluk proc near
	mov ax,di
	mov bl,10
	xor cx,cx
o_bol:
	xor ah,ah
	div bl
	push ax
	inc cx
	cmp al,0
	jnz o_bol
o_yaz:
	pop ax
	mov dl,ah
	add dl,30h
	call yaz
	loop o_yaz
	ret
onluk endp

onaltili proc near
	mov bx,di
	mov ch,02h
	mov cl,04h
h_dongu:
	rol bl,cl
	mov dl,bl
	and dl,0Fh
	add dl,30h
	cmp dl,3Ah
	jl h_yaz
	add dl,07h
h_yaz:
	call yaz
	dec ch
	jnz h_dongu
	ret
onaltili endp

karakter proc near
	mov dx,di
	call yaz
	ret
karakter endp

everydec ends
end
