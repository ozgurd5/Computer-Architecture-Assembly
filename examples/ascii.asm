ascii segment
assume cs:ascii

	mov cx,100h	;256 ascii char
	mov dl,0

dondur:
	mov ah,02h
	int 21h
	inc dl
	loop dondur

	int 20h

ascii ends
end
