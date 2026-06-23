;------------------------------------------------------------------------------
;               H   H  IIIII   GGG   H   H  W   W    A    Y   Y
;               H   H    I    G   G  H   H  W   W   A A   Y   Y
;               H   H    I    G      H   H  W   W  A   A   Y Y
;               HHHHH    I    G  GG  HHHHH  W W W  A   A    Y
;               H   H    I    G   G  H   H  W W W  AAAAA    Y
;               H   H    I    G   G  H   H  W W W  A   A    Y
;               H   H  IIIII   GGG   H   H   W W   A   A    Y

;        EEEEE  N   N   CCC    OOO   U   U  N   N  TTTTT  EEEEE  RRRR
;        E      N   N  C   C  O   O  U   U  N   N    T    E      R   R
;        E      NN  N  C      O   O  U   U  NN  N    T    E      R   R
;        EEEE   N N N  C      O   O  U   U  N N N    T    EEEE   RRRR
;        E      N  NN  C      O   O  U   U  N  NN    T    E      R R
;        E      N   N  C   C  O   O  U   U  N   N    T    E      R  R
;        EEEEE  N   N   CCC    OOO    UUU   N   N    T    EEEEE  R   R

; Costa Panayi, Vortex Software, 1985
; RM-TEAM, 2014, 2015, 2016
; nzeemin 2022 порт на Вектор-06Ц
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Изображение текста.
; I: HL=адрес текста
; O: -
; M: все
Print85Text:	ld e,(HL); столбец
		inc hl
		ld d,(HL)		; ряд
		inc hl
Print85TextN:	ld a,(HL); символ
		inc hl
		cp 0FEh		; koniec vsetkych textov?
		ret Z			; ano, navrat
		jp NC,Print85Text	; skoc, koniec jedneho textu
		call Print85		; zobraz jeden znak
		jp Print85TextN

;------------------------------------------------------------------------------
; Подпрограмма для рисования символа шириной 8 пунктов и высотой 5 пунктов,
; где сверху и снизу символ заполнен. Font je bitovo otoceny.
; (Rutina vychadza z podobnej rutiny od Libora Lasotu z hry JET PAC, rutina vsak
; bola optimalizovana a prisposobena aktualnym potrebam.)
; I: D=riadok, E=stlpec, A=znak
; O: E=E+1
; M: AF, BC, E
Print85:	push hl; odpamataj adresu textu
		push de		; odpamataj suradnice
		sub 030h
		ld l,a		; kod znaku do HL
		ld h,0
		ld c,l		; x1 tiez do BC
		ld b,h
		add HL,hl		; x2
		add HL,hl		; x4
		add HL,bc		; x5
		ld bc,Font85	; pripocitaj adresu fontu
		add HL,bc
		ex DE,HL			; DE=predloha znaku, HL=suradnice
		call Print8PosAdr	; vypocitaj adresu VRAM
		ld (HL),0
		dec l
		ld (HL),07Fh
		dec l
		ld A,(de)		; 1
		ld (HL),a
		inc de
		dec l
		ld A,(de)		; 2
		ld (HL),a
		inc de
		dec l
		ld A,(de)		; 3
		ld (HL),a
		inc de
		dec l
		ld A,(de)		; 4
		ld (HL),a
		inc de
		dec l
		ld A,(de)		; 5
		ld (HL),a
		inc de
		dec l
		ld (HL),07Fh
		dec l
		ld (HL),0
		pop de
		pop hl
		inc e		; следующая позиция
		ret

;------------------------------------------------------------------------------
; Подпрограмма для рисования символа шириной 8 точек и высотой 8 точек.
; Font je bitovo otoceny.
; (Rutina vychadza z podobnej rutiny od Libora Lasotu z hry JET PAC, rutina vsak
; bola optimalizovana a prisposobena aktualnym potrebam.)
; I: D=riadok, E=stlpec, A=znak
; O: E=E+1
; M: AF, BC, E
Print88:	push hl; odpamataj adresu textu
		push de		; odpamataj suradnice
		add A,a		; kod znaku 2x
		add A,a		; 4x
		add A,a		; 8x
		ld l,a		; do HL
		ld h,0
		ld bc,Font88	; pripocitaj adresu fontu
		add HL,bc
		ex DE,HL			; DE=predloha znaku, HL=suradnice
		call Print8PosAdr	; vypocitaj adresu VRAM
		ld bc, (8<<8)|3Fh
		call Print8S0
		pop de
		pop hl
		inc e
		ret

;------------------------------------------------------------------------------
; I: DE=adresa predlohy znaku, HL=адрес VRAM, B=высота символа, C=3Fh
Print8S0:	ld A,(de); zobraz znak
		ld (HL),a
		inc de
Print8SX0:	ld a,3Fh
		dec l		; следующая строка
		dec b
		jp NZ,Print8S0
		ret

;------------------------------------------------------------------------------
; Vypocita adresu VRAM zo znakoveho riadku a stlpca.
; I: H=символьный ряд, L=символьный столбец
; O: HL=адрес VRAM
; M: HL, BC, AF
Print8PosAdr:
		ld c,l		; столбец
		ld a,32
		sub h		; строка
		add A,a		; x2
		add A,a		; x4
		add A,a		; x8
		ld l,a
		ld a,c
		add A,BaseVramAdr/256	; vyssi byte adresy VRAM
		ld h,a		; HL=adresa VRAM
		ret

;------------------------------------------------------------------------------
; Нарисовать номер зоны.
; I: A=номер зоны
; O: -
; M: все
PrintZoneNum:	ld c,a; cislo zony do C
PrintZN:	ld b,10; B=10 pre pocitanie desiatok
		ld a,31		; zobrazuje sa ale "prevratena" hodnota
		sub c		; A=prevratena hodnota - 30 az 0
		cp b		; je cislo vacsie ako 10?
		jp NC,PrintZoneNumA	; ano, skoc dalej
		ld c,b		; prazdne miesto namiesto desiatok do C
		ld b,a		; jednotky do B
		jp PrintZoneNumC

PrintZoneNumA:	ld c,0; pocitadlo desiatok
PrintZoneNumB:	inc c; +1
		sub b		; odpocitaj rad
		cp b		; je zostatok vacsi ako 10?
		jp NC,PrintZoneNumB	; ano, skoc odpocitat dalsi rad
		ld b,a		; jednotky do B
PrintZoneNumC:	push bc; odpamataj jednotky
		ld e,1		; cielovy znakovy stlpec
		call PrintDigit	; zobraz desiatky
		pop bc		; obnov jednotky
		ld c,b
		ld e,3		; cielovy znakovy stlpec
					; zobraz jednotky

;------------------------------------------------------------------------------
; Отображение одной большой цифры.
; I: C=cislica, E=znakovy stlpec
; O: -
; M: все
PrintDigit:	ld a,c; x1
		add A,a		; x2
		add A,c		; x3
		add A,a		; x6
		ld c,a		; BC=offset na spravnu cislicu
		ld b,0
		ld hl,DigitChars	; adresa "predlohy" digitalnych cislic
		add HL,bc		; HL=adresa predlohy digitalnej cislice
		ld d,24		; cielovy znakovy riadok
		ld c,3		; dig. cislica je na vysku 3 znakov
PrintDigitA:	push bc
		ld a,(HL)		; znak do E
		inc hl
		call Print88
		ld a,(HL)
		inc hl
		call Print88
		dec e		; nazad o dva znaky
		dec e
		inc d		; dalsi znakovy riadok
		pop bc
		dec c		; dalsi riadok cislice
		jp NZ,PrintDigitA
		ret

;------------------------------------------------------------------------------
PrtHiScore:	ld de,(26<<8)|24; AT 26,24
		ld hl,HiScore
		jp PrintScore

PrtScore:	ld de,(24<<8)|24; AT 24,24
		ld hl,Score

; I: HL=adresa score cislic, D=строка, E=столбец
PrintScore:	ld a,(HL); возьми номер
		or a		; конец?
		ret M			; ano, navrat
		add A,030h
		call Print85
		inc hl
		jp PrintScore

;------------------------------------------------------------------------------
; Отображение инфо текса мелким шрифтом 4x8.
PrintSmallInfo:	ld hl,TInfoSmall

;------------------------------------------------------------------------------
; Изображение текста шрифтом 4x8.
; I: HL=адрес текста
; O: -
; M: все
Print4Text:	ld e,(HL); столбец
		inc hl
		ld d,(HL)		; ряд
		inc hl
Print4TextN:	ld a,(HL); символ
		inc hl
		cp 0FEh		; koniec vsetkych textov?
		ret Z			; ano, navrat
		jp NC,Print4Text	; skoc, koniec jedneho textu
		call Print4		; zobraz jeden znak
		jp Print4TextN

;------------------------------------------------------------------------------
; Подпрограмма для рисования символа шириной 4 точки.
; I: D=строка, E=колонка, A=символ
; O: E=E+1
; M: AF, BC, E
Print4:		push hl; odpamataj adresu textu
		push de		; сохраняем строку/колонку
		or a		; kod znaku /2
		rra
		push af		; odpamataj flag praveho/laveho znaku
		ld l,a		; kod znaku do HL
		ld h,0
		ld c,l		; x1 tiez do BC
		ld b,h
		add HL,hl		; x2
		add HL,hl		; x4
		add HL,bc		; x5
		ld de,Font4-((3Ch/2)*5) ; pripocitaj adresu fontu
		add HL,de
		ld de,CharBuf	; presun spravny znak do buffra
		ld b,5
		pop af
		jp NC,Print4B
Print4A:	ld a,(HL)
		and 0Fh
		ld (de),A
		inc hl
		inc de
		dec b
		jp NZ,Print4A
		jp Print4C
Print4B:	ld a,(HL)
		rlca
		rlca
		rlca
		rlca
		and 0Fh
		ld (de),A
		inc hl
		inc de
		dec b
		jp NZ,Print4B
; Теперь мы приготовили символ в CharBuf
Print4C:	ld de,CharBuf; DE=predloha znaku
		pop hl		; берём строку/колонку в HL
		push hl		; и возвращаем на стек
		ld a,32
		sub h		; 31 - строка
		rlca
		rlca
		rlca			; x8
		dec a
		ld c,l		; колонка
		ld l,a		; младший байт видео-адреса
		ld a,c		; колонка
		rra			; колонка / 2 = колонка на экране
		push af		; запоминаем флаг C - признак нечётной позиции
		add A,BaseVramAdr/256	; добавляем старший байт видео
		ld h,a		; старший байт видео-адреса
		pop af
		jp C,Print4S0	; к печати символа в нечётной позиции
; Вывод символа в чётной позиции
; I: DE=adresa predlohy znaku, HL=адрес VRAM
Print4S2:	ld a,(HL); 2x medzera nad znakom
		and 0Fh
		ld (HL),a
		dec l		; следующая строка
		ld a,(HL)
		and 0Fh
		ld (HL),a
		dec l		; следующая строка
		ld b,5		; vyska predlohy znaku
Print4S2L:	ld a,(HL); берём байт знака
		and 0Fh
		ld (HL),a
		ld A,(de)
		inc de
		rrca
		rrca
		rrca
		rrca
		or (HL)
		ld (HL),a
		dec l		; следующая строка
		dec b
		jp NZ,Print4S2L
		ld a,(HL)		; medzera pod znakom
		and 0Fh
		ld (HL),a
		pop de
		pop hl
		inc e		; следующая позиция в строке
		ret
; Вывод символа в нечётной позиции
; I: DE=adresa predlohy znaku, HL=adresa VRAM
Print4S0:	ld a,(HL); 2x medzera nad znakom
		and 0F0h
		ld (HL),a
		dec l		; следующая строка
		ld a,(HL)
		and 0F0h
		ld (HL),a
		dec l		; следующая строка
		ld b,5		; vyska predlohy znaku
Print4S0L:	ld a,(HL); берём байт знака
		and 0F0h
		ld (HL),a
		ld A,(de)
		inc de
		or (HL)
		ld (HL),a
		dec l		; следующая строка
		dec b
		jp NZ,Print4S0L
		ld a,(HL)		; место под символом
		and 0F0h
		ld (HL),a
		pop de
		pop hl
		inc e		; следующая позиция в строке
		ret

;------------------------------------------------------------------------------
; порядок «символов» для отображения больших цифр - номер зоны
DigitChars:	.db	1,4,8,15,16,18	; 0
		.db	0,6,0,15,0,19	; 1
		.db	2,4,10,13,16,20	; 2
		.db	2,4,11,12,17,18	; 3
		.db	3,6,9,12,0,19	; 4
		.db	1,5,9,14,17,18	; 5
		.db	1,5,7,14,16,18	; 6
		.db	2,4,0,15,0,19	; 7
		.db	1,4,7,12,16,18	; 8
		.db	1,4,9,12,17,18	; 9
		.db	0,0,0,0,0,0	; пустое место

;------------------------------------------------------------------------------
; тексты - {stlpec, riadok, text, FF} stlpec, riadok, text, FE
TMenu:		.db	15,0
		.db	":VECTOR=06C=PORT:",0FFh
		.db	18,1
		.db	":NZEEMIN=2022:",0FFh
;		.db	23,12
;		.db	":OPTIONS",0FFh
;		.db	19,14
;		.db	"1:KEYBOARD",0FFh
;		.db	17,15
;		.db	"2:JOYSTICK",0FFh
		.db	17,16
		.db	"1:INFORMATION",0FFh
		.db	15,17
		.db	"2:DEMONSTRATION",0FFh
		.db	13,18
		.db	"3:START=GAME",0FFh
		.db	1,21
		.db	":ORIGINAL=PROGRAM=BY=C=PANAYI:",0FFh
		.db	0,23
		.db	":COPYRIGHT=1985=VORTEX=SOFTWARE:",0FEh

TInfo:		.db	8,4
		.db	":AUTO=VORTONS:",0FFh
		.db	12,8
		.db	":LASERTRON:",0FFh
		.db	1,12
		.db	":MAIN=VORTON:",0FFh
		.db	3,16
		.db	":YOUR=MISSION:",0FFh
		.db	21,13
		.db	":CONTROLS:",0FFh
		.db	21,15
		.db	"Q",0FFh
		.db	26,15
		.db	"O",0FFh
		.db	21,16
		.db	"A",0FFh
		.db	26,16
		.db	"P",0FFh
		.db	21,17
		.db	":",0FFh
		.db	26,17
		.db	"H",0FFh
		.db	21,18
		.db	"T",0FFh
		.db	23,18
		.db	"G",0FFh
		.db	6,0
		.db	":HIGHWAY==ENCOUNTER:",0FFh
		.db	4,1
		.db	":CLASSIFIED=INFORMATION:",0FFh
TAnyKey:	.db	3,23
		.db	":PRESS=ANY=KEY=WHEN=READY:",0FEh

TAborted:	.db	7,8
		.db	":MISSION=ABORTED:",0FEh

TTooLate:	.db	10,7
		.db	":=TOO=LATE=:",0FFh
		.db	6,8
		.db	":MISSION=TERMINATED:",0FEh

TGameOver:	.db	10,6
		.db	":GAME=OVER:",0FFh
		.db	9,8
		.db	":ALL=VORTONS:",0FFh
		.db	9,9
		.db	":=DESTROYED=:",0FEh

TPauseMode:	.db	10,8
		.db	":PAUSE=MODE:",0FFh
		.db	7,9
		.db	":PRESS=L=TO=LEAVE:",0FEh

TDemoMode:	.db	1,1
		.db	":DEMO=MODE:",0FEh

TOneWay:	.db	11,5
		.db	":THERE=IS:",0FFh
		.db	9,6
		.db	":ONLY=ONE=WAY:",0FFh
		.db	9,7
		.db	":TO=ENCOUNTER:",0FFh
		.db	7,8
		.db	":WHAT=LIES=BEYOND:",0FFh
		.db	10,9
		.db	":ZONE=ZERO@:",0FFh
		.db	6,11
		.db	":SO=GET=ON=WITH=IT@:",0FEh

TPrepare:	.db	8,7
		.db	"PREPARE=YOURSELF",0FFh
		.db	8,8
		.db	":=FOR=THE=NEXT=:",0FFh
		.db	6,9
		.db	":HIGHWAY=ENCOUNTER!:",0FEh

;------------------------------------------------------------------------------
; zrusenie specialneho charsetu
;		charset

;------------------------------------------------------------------------------
; текст - {stlpec, riadok, text, FF} stlpec, riadok, text, FE
TInfoSmall:	.db	16,5
 		.db	"PROGRAMMED@TO@PUSH@THE@LASERTRON@",0FFh
 		.db	16,6
		.db	"AND@PROVIDE@BACKUP@FOR@THE@MAIN@VORTON@",0FFh
 		.db	24,9
		.db	"YOUR@ULTRA@POWERFUL@WEAPON@",0FFh
 		.db	24,10
		.db	"ACTIVATED@ONLY@IN@ZONE@ZERO@",0FFh
 		.db	2,13
		.db	"UNDER@YOUR@DIRECT@CONTROL@",0FFh
 		.db	2,14
		.db	"USE@HIM@TO@CLEAR@THE@WAY@AHEAD@",0FFh
 		.db	6,17
		.db	"TAKE@THE@LASERTRON@BEYOND@",0FFh
 		.db	6,18
		.db	"ZONE@ZERO@TO@ENCOUNTER@AND@",0FFh
 		.db	6,19
		.db	"DESTROY@THE@ALIEN@STRONGHOLD@",0FFh
 		.db	44,15
		.db	"@FAST@",0FFh
 		.db	54,15
		.db	"@LEFT@",0FFh
 		.db	44,16
		.db	"@SLOW@",0FFh
 		.db	54,16
		.db	"@RIGHT@",0FFh
 		.db	44,17
		.db	"@FIRE@",0FFh
 		.db	54,17
		.db	"@HOLD@",0FFh
 		.db	44,18
		.db	">?@@@ABORT@GAME@",0FEh

;------------------------------------------------------------------------------
