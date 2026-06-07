ascii segment

	assume cs:ascii

	mov cx,100h
	mov dl,0
dongu:
	mov ah,2
	int 21h
	inc dl
	loop dongu
	int 20h
	
ascii ends

	end
