tufek segment

ana_program proc far

	assume cs:tufek
	
	org 100h
	
basla:
	mov dx,20
	
ates_et:
	push cx
	call ates
	mov si,4
	
iki_atis_arasi:
	cmp si,0
	je iki_atis_arasi_sonu
	call sessizlik
	dec si
	jmp iki_atis_arasi
	
iki_atis_arasi_sonu:
	pop cx
	loop ates_et
	int 20h

ana_program	endp
	
ates proc near
	mov dx,300h
	mov bx,20h
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
	dec bx
	jnz ses
	
	and al,11111100b
	out 61h,al
	
	ret
	
ates endp

sessizlik proc near
	mov cx,4000h
ara_ver:loop ara_ver
	ret
sessizlik endp

	
tufek ends

end basla
