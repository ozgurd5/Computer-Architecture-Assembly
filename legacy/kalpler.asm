video segment at 0B800h

	db 25 * 80 * 2 dup (?)
	
video ends

doldur segment
kalp proc far
assume cs:doldur
assume ds:video   ;video segmentinin data segmenti
	push ds
	mov ax,0
	push ax
	
	mov ax,video
	mov ds,ax
	
	mov ah,03h
	mov al,07Ch   ;özellik byte'i
	mov bx,0
	mov cx,0FA0h   ;80*25*2
dongu:
	mov [bx],ah
	mov [bx+1],al
	add bx,2
	loop dongu

	mov ah,1      ;cursoru yok eder
	mov ch,01h
	mov cl,00h
	int 10h
	
	mov ah,0		;klavyeden tus okur
	int 16h
	
	mov ah,6		;ekrani siler
	mov al,0
	mov ch,0
	mov cl,0
	mov dh,24
	mov dl,79
	mov bh,7
	int 10h
	
	mov ah,2	;cursoru ekranin sol ust kosesine konumlandir
	mov dh,0
	mov dl,0
	mov bh,0
	int 10h
	
	mov ah,1	;cursoru gorunur yap
	mov ch,6
	mov cl,7
	int 10h
	
	ret
	
kalp endp

doldur ends

end

	



