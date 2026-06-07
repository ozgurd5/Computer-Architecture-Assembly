ascii_ks2 segment

	assume cs:ascii_ks2

	mov cx,100h
	mov bl,0
dongu:
	mov dl,bl
	mov ah,2
	int 21h
	
	mov dl,10
	mov ah,2
	int 21h
	
	inc bl
	loop dongu
	
	int 20h
	
ascii_ks2 ends

	end
