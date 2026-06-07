gurultu segment
assume cs:gurultu
	
basla:
	mov dx,300h			;prng 0: random delay and sound seed
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
	jmp ses

gurultu ends
end
