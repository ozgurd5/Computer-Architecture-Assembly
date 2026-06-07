desibin segment
assume cs:desibin

	mov bx,0h

giris:
	mov ah,01h
	int 21h

	sub al,30h
	cmp al,0
	jl program_sonu
	cmp al,9
	jg program_sonu
	cbw

	xchg ax,bx
	mov cx,10
	mul cx
	xchg ax,bx
	add bx,ax
	jmp giris
	
program_sonu:
	int 20h

desibin ends
end
