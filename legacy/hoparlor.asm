; "Hoparlörden Belli Bir Süre Ses Çýkarma"
program SEGMENT
 ASSUME CS:program,DS:program
 ORG 100h
start:
	mov al, 182			; Hoparlör nota için hazýrlanýyor.
	out 43h, al
	mov ax, 4560 		; Nota frekansý
	out 42h, al			; Düþük oktav çýkýþý
	mov al, ah
	out 42h, al			; Yüksek oktav çýkýþý
	in al, 61h   		; Hoparlör durumu AL registerýna alýndý.
	or al, 00000011b	; AL deðeri OR'lanýyor.
	out 61h, al
	mov bx, 64			; Nota süresi
.pause1:
	mov cx, 65535 		; 
.pause2:
	dec cx				; CX registerýný azalt
	jne .pause2
	dec bx				; BX registerýný azalt
	jne .pause1
	in al, 61h			; Notayý durdurmak için 97. porttan deðeri alýndý.
	and al, 11111100b	; AL deðeri AND'leniyor.
	out 61h, al			; Yeni deðeri gönderildi.
program ENDS
 END start
 
 