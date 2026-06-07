gurultu segment

ana_program proc far

	assume cs:gurultu
	
	org 100h
	
basla:
	mov dx,300h
	in al,61h
	and al,11111100b
ses:
	xor al,2
	out 61h,al
	add dx,1649h
	mov cl,3
	ror dx,cl
	mov cx,dx
	and cx,01FFh
	or cx,10
bekle:
	loop bekle
	jmp ses

ana_program endp
	
gurultu ends

	end basla
