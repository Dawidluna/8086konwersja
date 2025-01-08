_code segment
assume  cs:_code, ds:_data, ss:_stack

start:	mov	ax,_data
	mov	ds,ax
	mov	ax,_stack
	mov	ss,ax
	mov	sp,offset top

	mov ah, 09h
    lea dx, tekst_wprowadz
    int 21h                 ;wyświetlenie prośby o wprowadzenie liczby

wczytaj_cyfre:
    mov ah,01h
    int 21h                 ;wczytanie cyfry
    cmp al, 0Dh             
    je koniec_wczytywania   ;jeśli wciśnięto sam enter, zakończ wprowadzanie

    cmp bh, 1
    je niepierwszy_znak     ;pominięcie sprawdzenia znaku jeśli wprowadzono już pierwszą cyfrę
    mov bh, 1               ;ustaw bh na 1, jeśli wprowadzono już pierwszy znak
    cmp al, '-'
    je minus
niepierwszy_znak:
    cmp al, '0'
    jb zly_znak
    cmp al, '9'
    ja zly_znak

    sub al, '0'             ;konwersja kodu ASCII na cyfrę
    mov cl, al              ;tymczasowe przechowanie cyfry w cl
    mov ax, liczba             ;przeniesienie liczby do ax
    mul mnoz_10           ;pomnożenie ax przez 10
    add ax, cx              ;dodanie wprowadzonego znaku do liczby
    mov liczba, ax              ;przechowanie liczby w dx
    jmp wczytaj_cyfre

minus:
    mov bl, 1              ;ustaw bl na 1, jeśli liczba jest ujemna
    jmp wczytaj_cyfre

zly_znak:
    mov ah, 09h
    lea dx, tekst_zly_znak
    int 21h                 ;wyświetlenie błędu o nieprawidłowym znaku
    jmp koniec_programu

koniec_wczytywania:
    cmp bl, 1
    jne pomin_negacje
    neg liczba
pomin_negacje:


koniec_programu:
	mov	ah,4ch
	mov	al,0
	int	21h

_code ends

_data segment
	tekst_wprowadz db "Wprowadz liczbe od -32 768 do 32 767: $"
    tekst_zly_znak db "Wprowadzono nieprawidlowy znak!$"
    mnoz_10 dw 10
    liczba dw 0
_data ends

_stack segment stack
	dw	100h dup(0)
top	Label word
_stack ends

end start