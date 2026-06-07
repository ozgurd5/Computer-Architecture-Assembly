kayan segment
assume cs:kayan
org 100h

start:
	jmp begin			;skip over the data block

;---- data ----
foff	dw 0			;ROM font offset
fseg	dw 0			;ROM font segment
ofs		dw 0			;scroll offset (matrix column shown at screen col 0)
matcol	dw 0			;matrix column currently being drawn
colbase	dw 0			;font address base of the current column's char
maske	db 0			;which bit of the font byte this column uses
crow	db 0			;pixel row 0..15
kol		db 0			;screen column 0..79
mesaj	db 'BILGISAYAR ';the scrolling text (with a trailing gap)
uzunluk	equ $ - mesaj	;message length in characters
genis	equ uzunluk * 8	;message width in matrix columns (8 per char)

begin:
	mov ax,0003h		;80x25 text mode (clears the screen)
	int 10h
	mov ah,01h			;hide the cursor
	mov cx,2000h
	int 10h

	mov ax,1130h		;get font info (AL=30h, BH=06h -> ROM 8x16 font)
	mov bx,0600h
	int 10h				;returns ES:BP = font table
	mov foff,bp
	mov ax,es
	mov fseg,ax
	mov es,ax			;ES = font segment (kept for all font reads)

	mov ofs,0			;start the scroll at the beginning

ana:
	mov kol,0			;draw screen columns 0..79
sutun:
	mov al,kol			;matcol = ofs + kol  (wrap if it passes the end)
	xor ah,ah
	add ax,ofs
	cmp ax,genis
	jb w1
	sub ax,genis
w1:
	mov matcol,ax

	mov bx,ax			;char index = matcol / 8
	mov cl,3
	shr bx,cl
	mov al,mesaj[bx]	;the ASCII char this column belongs to
	mov ah,16
	mul ah				;ax = char * 16
	add ax,foff			;ax = font base of that char
	mov colbase,ax

	mov ax,matcol		;mask = 80h >> (matcol AND 7)  -> the bit for this column
	and ax,7
	mov cl,al
	mov al,80h
	shr al,cl
	mov maske,al

	mov crow,0			;draw the 16 pixel rows of this column
satir:
	mov ah,02h			;cursor to (5+crow, kol)
	xor bh,bh
	mov dh,5
	add dh,crow
	mov dl,kol
	int 10h

	mov si,colbase		;font byte = font[colbase + crow]
	mov bl,crow
	xor bh,bh
	add si,bx
	mov al,es:[si]
	test al,maske		;is this pixel on?
	jz s_off
	mov bl,0Bh			;on  = light cyan
	jmp s_koy
s_off:
	mov bl,01h			;off = blue
s_koy:
	mov ah,09h			;write char + attribute at the cursor
	mov al,04h			;diamond character
	xor bh,bh
	mov cx,1
	int 10h

	inc crow
	cmp crow,16
	jb satir

	inc kol
	cmp kol,80
	jae kolbitti		;all 80 columns done
	jmp sutun			;else keep looping (near jmp, long range)
kolbitti:

	call bekle			;slow the scroll down a bit

	mov ax,ofs			;ofs-- with wrap (0 -> genis-1)  => text moves left-to-right
	or ax,ax
	jnz d1
	mov ax,genis
d1:
	dec ax
	mov ofs,ax

	mov ah,01h			;key pressed?
	int 16h
	jnz cikis
	jmp ana
cikis:
	mov ah,00h			;eat the key, restore cursor, quit
	int 16h
	mov ah,01h
	mov cx,0607h
	int 10h
	int 20h

;---- short delay (busy loop) ----
bekle proc near
	mov cx,0			;cx=0 -> the loop runs 65536 times
gecikme:
	loop gecikme
	ret
bekle endp

kayan ends
end start
