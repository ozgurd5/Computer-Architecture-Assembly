tufek segment

ana_program	proc far

	assume cs:tufek
	org 100h
	
basla:
	mov cx,40	;ammo count
	
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

ana_program endp


ates proc near
	mov dx,300h 		;prng 0: random delay and sound seed
	mov bx,20h
	in al,61h			;read port 61h for speaker
	and al,11111100b	;reset bit 0 and bit 1 to override speaker control

ses:
	xor al,2			;toggle speaker
	out 61h,al			;send toggle data to port 61h for speaker
	add dx,1649h		;prng 1: increment seed for random
	mov cl,3
	ror dx,cl			;prng 2: rotate seed for random
	mov cx,dx
	and cx,01FFh		;clamp random
	or cx,10			;clamp random
	
bekle:
	loop bekle			;wait for cx amount of cycles
	dec bx
	jnz ses
	and al,11111100b
	out 61h,al

	ret
ates endp
	

sessizlik proc near
	mov cx,4000h

ara_ver:
	loop ara_ver

	ret
sessizlik endp

tufek ends
end basla
	
	