;Ekraný silen program
program SEGMENT
 ASSUME CS:program,DS:program
 ORG 100h
start:
     mov ax,012h         ;VGA mode(boyut sabitleme)
     int 10h             ;640 x 480 16 colors.(fonksiyonlarý çaðýrýr)
 	 mov ax,0A000h
	 mov es,ax           ;ES points to the video memory.
	 mov dx,03C4h        ;dx = indexregister
	 mov ax,0502h        ;INDEX = MASK MAP, (pembe yapan yer)
	 out dx,ax           ;write all the bitplanes.
 	 mov di,0            ;DI pointer in the video memory.
	 mov cx,38400        ;(640 * 480)/8 = 38400
 	 mov ax,0FFh         ;write to every pixel.
	 rep stosb           ;fill the screen
	 mov ah,4ch          ;go back (baþa alma)
	 int 21h             ;to DOS.(dosya gönderiyor-Kesme)
program ENDS
END start
