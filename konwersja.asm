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
    cmp dx, 0               ;sprawdź czy nie wykorroczono poza zakres po mnożeniu
    jne poza_zakres
    add ax, cx              ;dodanie wprowadzonego znaku do liczby
    jo poza_zakres          ;sprawdź czy nie wykorroczono poza zakres po dodawaniu
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

poza_zakres:
    mov ah, 09h
    lea dx, tekst_poza_zakres
    int 21h                 ;wyświetlenie błędu o wykroczeniu poza zakres
    jmp koniec_programu

koniec_wczytywania:
    cmp bl, 1
    jne pomin_negacje
    neg liczba
pomin_negacje:
    mov ah, 09h          ; wyświetlenie tekstu "Podana liczba wynosi:"
    lea dx, tekst_wynik
    int 21h

    mov cx, 16           ; liczba bitów do wyświetlenia (16-bit)
    mov bx, 8000h        ; maska dla najbardziej znaczonego bitu (bit 15)

wyswietl_bit:
    mov ax, liczba       ; załaduj wartość liczby
    test ax, bx          ; sprawdzenie bitu z maską
    jz zero_bit          ; jeśli 0, przejdź do zero_bit
    mov dl, '1'          ; jeśli 1, ustaw DL na '1'
    jmp pokaz_znak

zero_bit:
    mov dl, '0'          ; ustaw DL na '0'

pokaz_znak:
    mov ah, 02h          
    int 21h              ; wyświetlenie znaku

    shr bx, 1            ; przesunięcie maski w prawo
    loop wyswietl_bit    ; powtarzaj dla kolejnych bitów

    mov ah, 09h          ; Wyświetlenie tekstu "Podana liczba w kodzie szesnastkowym wynosi:"
    lea dx, tekst_wynik_hex
    int 21h

    mov cx, 4            ; liczba cyfr (16 bitów = 4 cyfry szesnastkowe)

wyswietl_cyfre:
    mov dx, liczba       ; kopiowanie AX do DX
    shr dx, 12           ; przesunięcie w prawo o 12 bitów
    and dx, 0Fh          ; wyizolowanie 4 najmłodszych bitów
    cmp dl, 9            ; czy cyfra < 10?
    jle CYFRA_JEST
    add dl, 7           ; dla liter A-F
cyfra_jest:
    add dl, '0'         ; dodanie przesunięcia ASCII
    mov ah, 02h
    int 21h             ; wyświetlenie znaku

    shl liczba, 4        ; przesunięcie liczby w lewo o 4 bity
    loop WYSWIETL_CYFRE  ; zmniejszenie licznika

koniec_programu:
	mov	ah,4ch
	mov	al,0
	int	21h

_code ends

_data segment
	tekst_wprowadz db "Wprowadz liczbe od -32 768 do 32 767: $"
    tekst_zly_znak db 13, 10, "Wprowadzono nieprawidlowy znak!$"
    tekst_poza_zakres db 13, 10, "Wykroczona poza zakres!$"
    tekst_wynik db 13, 10, "Podana liczba w kodzie dwojkowym wynosi: $"
    tekst_wynik_hex db 13, 10, "Podana liczba w kodzie szesnastkowym wynosi: $"
    mnoz_10 dw 10
    liczba dw 0
_data ends

_stack segment stack
	dw	100h dup(0)
top	Label word
_stack ends

end start