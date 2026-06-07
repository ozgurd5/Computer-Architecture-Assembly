everydec segment
assume cs:everydec

	mov di,0			;di = o anki ASCII kodu (0..255)

ana_dongu:
	;--- 1) ikilik (binary), 8 bit, soldan (MSB) ---
	mov ax,di
	mov bl,al			;bl = kod
	mov cx,8			;8 bit
bin_dongu:
	rol bl,1			;bir sonraki biti en saga getir (once MSB)
	mov dl,bl
	and dl,01h			;sadece o biti birak
	add dl,30h			;0/1 -> '0'/'1'
	call yaz
	loop bin_dongu

	;--- ayrac " , " ---
	mov dl,' '
	call yaz
	mov dl,','
	call yaz
	mov dl,' '
	call yaz

	;--- 2) onluk (decimal), 0..255 ---
	mov ax,di			;ax = kod (ah=0)
	mov bl,10			;10'a bolerek basamaklari bul
	xor cx,cx			;cx = basamak sayisi
dec_bol:
	xor ah,ah			;her bolmeden once ax = al
	div bl				;al = ax/10, ah = ax mod 10 (kalan = basamak)
	push ax				;basamagi yigina sakla (kalan ah'de)
	inc cx
	cmp al,0			;bolum 0 mi? degilse devam
	jnz dec_bol
dec_yaz:
	pop ax				;basamaklari TERS sirayla geri al (LIFO)
	mov dl,ah
	add dl,30h
	call yaz
	loop dec_yaz

	;--- ayrac " , " ---
	mov dl,' '
	call yaz
	mov dl,','
	call yaz
	mov dl,' '
	call yaz

	;--- 3) onaltilik (hex), 2 basamak ---
	mov ax,di
	mov bl,al			;bl = kod
	mov ch,2			;2 nibble
	mov cl,4			;4 bit dondur
hex_dongu:
	rol bl,cl			;ustteki nibble'i en alta getir (once yuksek)
	mov dl,bl
	and dl,0Fh			;alttaki 4 biti birak
	add dl,30h
	cmp dl,3Ah			;0..9 mu?
	jl hex_yaz
	add dl,07h			;A..F
hex_yaz:
	call yaz
	dec ch
	jnz hex_dongu

	;--- ayrac " : " ---
	mov dl,' '
	call yaz
	mov dl,':'
	call yaz
	mov dl,' '
	call yaz

	;--- 4) karakterin kendisi ---
	mov ax,di
	mov dl,al
	call yaz

	;--- alt satira gec (CR LF) ---
	mov dl,13
	call yaz
	mov dl,10
	call yaz

	;--- sonraki kod ---
	inc di
	cmp di,256
	jb ana_dongu		;di < 256 ise devam et

	int 20h

;==== alt program: DL'deki karakteri ekrana bas ====
yaz proc near
	mov ah,02h
	int 21h
	ret
yaz endp

everydec ends
end
