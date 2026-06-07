clock segment
assume cs:clock
org 100h

start:
	jmp begin			;skip over the data block

;---- data (defined before the code that uses it) ----
foff	dw 0			;ROM font offset
fseg	dw 0			;ROM font segment
son_sn	db 0FFh			;last second drawn (FFh forces the first draw)
sutun	db 1,10,30,40,60,70		;screen column of each of the 6 digits
hane	db 6 dup(0)		;the 6 digit chars: H H M M S S
cchar	db 0			;char currently being drawn
gx		db 0			;its start column
crow	db 0			;pixel row 0..15
ccol	db 0			;pixel col 0..7
fbyte	db 0			;current font row byte
cmask	db 0			;current bit mask

begin:
	mov ax,0003h		;80x25 text mode (clears the screen)
	int 10h
	mov ah,01h			;hide the cursor
	mov cx,2000h
	int 10h

	mov ax,1130h		;get font info (AL=30h)
	mov bx,0600h		;BH=06h -> ROM 8x16 font
	int 10h				;returns ES:BP = font table
	mov foff,bp			;save the font pointer
	mov ax,es
	mov fseg,ax

ana:
	mov ah,2Ch			;get system time -> CH=hour CL=min DH=sec
	int 21h
	cmp dh,son_sn		;same second as last time?
	jne yeni			;changed -> redraw
	jmp tus				;unchanged -> just poll the keyboard
yeni:
	mov son_sn,dh		;remember this second

	mov al,ch			;hour -> two ASCII digits
	aam					;AH=tens AL=units
	add ax,3030h		;0..9 -> '0'..'9'
	mov hane[0],ah
	mov hane[1],al
	mov al,cl			;minute
	aam
	add ax,3030h
	mov hane[2],ah
	mov hane[3],al
	mov al,dh			;second
	aam
	add ax,3030h
	mov hane[4],ah
	mov hane[5],al

	xor di,di			;di = digit index 0..5
cizdongu:
	mov al,hane[di]		;the digit char
	mov cchar,al
	mov al,sutun[di]	;its column on screen
	mov gx,al
	call ciz_rakam
	inc di
	cmp di,6
	jb cizdongu

	mov cchar,58		;draw the two ':' separators
	mov gx,20
	call ciz_rakam
	mov cchar,58
	mov gx,50
	call ciz_rakam

tus:
	mov ah,01h			;any key waiting?
	int 16h
	jnz cikis			;yes -> quit
	jmp ana				;no  -> keep the clock running
cikis:
	mov ah,00h			;eat the key
	int 16h
	mov ah,01h			;restore the cursor
	mov cx,0607h
	int 10h
	int 20h

;---- draw the char in 'cchar' at column 'gx', row 5, as 8x16 colored diamonds ----
ciz_rakam proc near
	mov ax,fseg			;ES = font segment (we read the bitmap from here)
	mov es,ax
	mov crow,0			;start at the top pixel row
satir:
	mov al,cchar		;font byte address = foff + cchar*16 + crow
	mov ah,16
	mul ah				;ax = cchar * 16
	add ax,foff
	mov bl,crow
	xor bh,bh
	add ax,bx
	mov si,ax
	mov al,es:[si]		;al = this row's 8 pixels (bit7 = leftmost)
	mov fbyte,al
	mov cmask,80h		;mask starts at the leftmost pixel
	mov ccol,0
kolon:
	mov ah,02h			;move cursor to (5+crow, gx+ccol)
	xor bh,bh
	mov dh,5
	add dh,crow
	mov dl,gx
	add dl,ccol
	int 10h
	mov al,fbyte		;is this pixel on?
	test al,cmask
	jz sonmus
	mov bl,0Bh			;on  = light cyan
	jmp koy
sonmus:
	mov bl,01h			;off = blue
koy:
	mov ah,09h			;write char + attribute at the cursor
	mov al,04h			;diamond character
	xor bh,bh
	mov cx,1
	int 10h
	shr cmask,1			;move mask to the next pixel column
	inc ccol
	cmp ccol,8
	jb kolon
	inc crow			;next pixel row
	cmp crow,16
	jb satir
	ret
ciz_rakam endp

clock ends
end start
