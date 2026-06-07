kalp segment
assume cs:kalp

	mov dl,03h
	mov ah,02h
	int 21h
	int 20h

kalp ends
end
