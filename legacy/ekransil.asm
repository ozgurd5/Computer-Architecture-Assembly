;Ekranı Sil
program SEGMENT
ASSUME CS:program,DS:program
 ORG 100h
start:
; mov ax,012h ;VGA mode
 int 10h ;640 x 480 16 colors.
  MOV AH,06h ;INT 10,6
 MOV AL,00h ;number of lines to scroll, previous lines are
 ;blanked, if 0 or AL > screen size, window is blanked
 MOV CH,00h ;row of upper left corner of scroll window
 MOV CL,00h ;column of upper left corner of scroll window
 MOV DH,24h ;row of lower right corner of scroll window
 MOV DL,79h ;column of lower right corner of scroll window
 MOV BH,57h ;attribute to be used on blank line
 
 rep stosb ;fill the screen
 mov ah,4ch ;go back 
 int 21h ; to DOS.
program ENDS
 END start
