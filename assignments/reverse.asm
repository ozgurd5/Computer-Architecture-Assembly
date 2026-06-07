reverse segment
assume cs:reverse

mov cx,0

oku:
	mov ah,01h
	int 21h
	cmp al,13		;Enter pressed?
	je yazdir
	push ax
	inc cx
	jmp oku

yazdir:
	mov dl,13		;newline (CR)
	mov ah,02h
	int 21h
	mov dl,10		;newline (LF)
	mov ah,02h
	int 21h

	jcxz son

ters:
	pop ax
	mov dl,al
	mov ah,02h
	int 21h
	loop ters

son:
	int 20h

reverse ends
end
