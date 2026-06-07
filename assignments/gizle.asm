gizle segment
assume cs:gizle

oku:
	mov ah,01h
	int 21h
	cmp al,13		;Enter?
	je son
	call bekle
	mov ah,02h
	mov dl,08h		;backspace: cursor back onto the char
	int 21h
	mov dl,'*'		;overwrite the char with *
	int 21h
	jmp oku

son:
	int 20h

;--- wait ~1 second using the BIOS timer (it ticks ~18.2 times per second) ---
bekle proc near
	mov ah,00h
	int 1Ah			;BIOS get-time: DX = low word of the tick count since midnight
	mov bx,dx		;remember the tick we started at
b_dongu:
	mov ah,00h
	int 1Ah			;read the tick count again
	sub dx,bx		;DX = ticks elapsed since start (now - start)
	cmp dx,18		;18 ticks ~= 1 second (18 / 18.2)
	jb b_dongu		;fewer than 18 -> keep polling
	ret				;~1 second passed -> return
bekle endp

gizle ends
end
