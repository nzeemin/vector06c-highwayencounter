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
Print85Text:	mov	e,m		; столбец
		inx	h
		mov	d,m		; ряд
		inx	h
Print85TextN:	mov	a,m		; символ
		inx	h
		cpi	0FEh		; koniec vsetkych textov?
		rz			; ano, navrat
		jnc	Print85Text	; skoc, koniec jedneho textu
		call	Print85		; zobraz jeden znak
		jmp	Print85TextN

;------------------------------------------------------------------------------
; Подпрограмма для рисования символа шириной 8 пунктов и высотой 5 пунктов,
; где сверху и снизу символ заполнен. Font je bitovo otoceny.
; (Rutina vychadza z podobnej rutiny od Libora Lasotu z hry JET PAC, rutina vsak
; bola optimalizovana a prisposobena aktualnym potrebam.)
; I: D=riadok, E=stlpec, A=znak
; O: E=E+1
; M: AF, BC, E
Print85:	push	h		; odpamataj adresu textu
		push	d		; odpamataj suradnice
		sui	030h
		mov	l,a		; kod znaku do HL
		mvi	h,0
		mov	c,l		; x1 tiez do BC
		mov	b,h
		dad	h		; x2
		dad	h		; x4
		dad	b		; x5
		lxi	b,Font85	; pripocitaj adresu fontu
		dad	b
		xchg			; DE=predloha znaku, HL=suradnice
		call	Print8PosAdr	; vypocitaj adresu VRAM
		mvi	m,0
		dcr	l
		mvi	m,07Fh
		dcr	l
		ldax	d		; 1
		mov	m,a
		inx	d
		dcr	l
		ldax	d		; 2
		mov	m,a
		inx	d
		dcr	l
		ldax	d		; 3
		mov	m,a
		inx	d
		dcr	l
		ldax	d		; 4
		mov	m,a
		inx	d
		dcr	l
		ldax	d		; 5
		mov	m,a
		inx	d
		dcr	l
		mvi	m,07Fh
		dcr	l
		mvi	m,0
		pop	d
		pop	h
		inr	e		; следующая позиция
		ret

;------------------------------------------------------------------------------
; Подпрограмма для рисования символа шириной 8 точек и высотой 8 точек.
; Font je bitovo otoceny.
; (Rutina vychadza z podobnej rutiny od Libora Lasotu z hry JET PAC, rutina vsak
; bola optimalizovana a prisposobena aktualnym potrebam.)
; I: D=riadok, E=stlpec, A=znak
; O: E=E+1
; M: AF, BC, E
Print88:	push	h		; odpamataj adresu textu
		push	d		; odpamataj suradnice
		add	a		; kod znaku 2x
		add	a		; 4x
		add	a		; 8x
		mov	l,a		; do HL
		mvi	h,0
		lxi	b,Font88	; pripocitaj adresu fontu
		dad	b
		xchg			; DE=predloha znaku, HL=suradnice
		call	Print8PosAdr	; vypocitaj adresu VRAM
		lxi	b,HILO(8,3Fh)	; B=vyska znaku, C=offset na dalsi uR
		call	Print8S0
		pop	d
		pop	h
		inr	e
		ret

;------------------------------------------------------------------------------
; I: DE=adresa predlohy znaku, HL=адрес VRAM, B=высота символа, C=3Fh
Print8S0:	ldax	d		; zobraz znak
		mov	m,a
		inx	d
Print8SX0:	mvi	a,3Fh
		dcr	l		; следующая строка
		dcr	b
		jnz	Print8S0
		ret

;------------------------------------------------------------------------------
; Vypocita adresu VRAM zo znakoveho riadku a stlpca.
; I: H=символьный ряд, L=символьный столбец
; O: HL=адрес VRAM
; M: HL, BC, AF
Print8PosAdr:
		mov	c,l		; столбец
		mvi	a,32
		sub	h		; строка
		add	a		; x2
		add	a		; x4
		add	a		; x8
		mov	l,a
		mov	a,c
		adi	BaseVramAdr/256	; vyssi byte adresy VRAM
		mov	h,a		; HL=adresa VRAM
		ret

;------------------------------------------------------------------------------
; Нарисовать номер зоны.
; I: A=номер зоны
; O: -
; M: все
PrintZoneNum:	mov	c,a		; cislo zony do C
PrintZN:	mvi	b,10		; B=10 pre pocitanie desiatok
		mvi	a,31		; zobrazuje sa ale "prevratena" hodnota
		sub	c		; A=prevratena hodnota - 30 az 0
		cmp	b		; je cislo vacsie ako 10?
		jnc	PrintZoneNumA	; ano, skoc dalej
		mov	c,b		; prazdne miesto namiesto desiatok do C
		mov	b,a		; jednotky do B
		jmp	PrintZoneNumC

PrintZoneNumA:	mvi	c,0		; pocitadlo desiatok
PrintZoneNumB:	inr	c		; +1
		sub	b		; odpocitaj rad
		cmp	b		; je zostatok vacsi ako 10?
		jnc	PrintZoneNumB	; ano, skoc odpocitat dalsi rad
		mov	b,a		; jednotky do B
PrintZoneNumC:	push	b		; odpamataj jednotky
		mvi	e,1		; cielovy znakovy stlpec
		call	PrintDigit	; zobraz desiatky
		pop	b		; obnov jednotky
		mov	c,b
		mvi	e,3		; cielovy znakovy stlpec
					; zobraz jednotky

;------------------------------------------------------------------------------
; Отображение одной большой цифры.
; I: C=cislica, E=znakovy stlpec
; O: -
; M: все
PrintDigit:	mov	a,c		; x1
		add	a		; x2
		add	c		; x3
		add	a		; x6
		mov	c,a		; BC=offset na spravnu cislicu
		mvi	b,0
		lxi	h,DigitChars	; adresa "predlohy" digitalnych cislic
		dad	b		; HL=adresa predlohy digitalnej cislice
		mvi	d,24		; cielovy znakovy riadok
		mvi	c,3		; dig. cislica je na vysku 3 znakov
PrintDigitA:	push	b
		mov	a,m		; znak do E
		inx	h
		call	Print88
		mov	a,m
		inx	h
		call	Print88
		dcr	e		; nazad o dva znaky
		dcr	e
		inr	d		; dalsi znakovy riadok
		pop	b
		dcr	c		; dalsi riadok cislice
		jnz	PrintDigitA
		ret

;------------------------------------------------------------------------------
PrtHiScore:	lxi	d,HILO(26,24)	; AT 26,24
		lxi	h,HiScore
		jmp	PrintScore

PrtScore:	lxi	d,HILO(24,24)	; AT 24,24
		lxi	h,Score

; I: HL=adresa score cislic, D=строка, E=столбец
PrintScore:	mov	a,m		; возьми номер
		ora	a		; конец?
		rm			; ano, navrat
		adi	030h
		call	Print85
		inx	h
		jmp	PrintScore

;------------------------------------------------------------------------------
; Отображение инфо текса мелким шрифтом 4x8.
PrintSmallInfo:	lxi	h,TInfoSmall

;------------------------------------------------------------------------------
; Изображение текста шрифтом 4x8.
; I: HL=адрес текста
; O: -
; M: все
Print4Text:	mov	e,m		; столбец
		inx	h
		mov	d,m		; ряд
		inx	h
Print4TextN:	mov	a,m		; символ
		inx	h
		cpi	0FEh		; koniec vsetkych textov?
		rz			; ano, navrat
		jnc	Print4Text	; skoc, koniec jedneho textu
		call	Print4		; zobraz jeden znak
		jmp	Print4TextN

;------------------------------------------------------------------------------
; Подпрограмма для рисования символа шириной 4 точки.
; I: D=строка, E=колонка, A=символ
; O: E=E+1
; M: AF, BC, E
Print4:		push	h		; odpamataj adresu textu
		push	d		; сохраняем строку/колонку
		ora	a		; kod znaku /2
		rar
		push	psw		; odpamataj flag praveho/laveho znaku
		mov	l,a		; kod znaku do HL
		mvi	h,0
		mov	c,l		; x1 tiez do BC
		mov	b,h
		dad	h		; x2
		dad	h		; x4
		dad	b		; x5
		lxi	d,Font4-((3Ch/2)*5) ; pripocitaj adresu fontu
		dad	d
		lxi	d,CharBuf	; presun spravny znak do buffra
		mvi	b,5
		pop	psw
		jnc	Print4B
Print4A:	mov	a,m
		ani	0Fh
		stax	d
		inx	h
		inx	d
		dcr	b
		jnz	Print4A
		jmp	Print4C
Print4B:	mov	a,m
		rlc
		rlc
		rlc
		rlc
		ani	0Fh
		stax	d
		inx	h
		inx	d
		dcr	b
		jnz	Print4B
; Теперь мы приготовили символ в CharBuf
Print4C:	lxi	d,CharBuf	; DE=predloha znaku
		pop	h		; берём строку/колонку в HL
		push	h		; и возвращаем на стек
		mvi	a,32
		sub	h		; 31 - строка
		rlc
		rlc
		rlc			; x8
		dcr	a
		mov	c,l		; колонка
		mov	l,a		; младший байт видео-адреса
		mov	a,c		; колонка
		rar			; колонка / 2 = колонка на экране
		push	psw		; запоминаем флаг C - признак нечётной позиции
		adi	BaseVramAdr/256	; добавляем старший байт видео
		mov	h,a		; старший байт видео-адреса
		pop	psw
		jc	Print4S0	; к печати символа в нечётной позиции
; Вывод символа в чётной позиции
; I: DE=adresa predlohy znaku, HL=адрес VRAM
Print4S2:	mov	a,m		; 2x medzera nad znakom
		ani	0Fh
		mov	m,a
		dcr	l		; следующая строка
		mov	a,m
		ani	0Fh
		mov	m,a
		dcr	l		; следующая строка
		mvi	b,5		; vyska predlohy znaku
Print4S2L:	mov	a,m		; берём байт знака
		ani	0Fh
		mov	m,a
		ldax	d
		inx	d
		rrc
		rrc
		rrc
		rrc
		ora	m
		mov	m,a
		dcr	l		; следующая строка
		dcr	b
		jnz	Print4S2L
		mov	a,m		; medzera pod znakom
		ani	0Fh
		mov	m,a
		pop	d
		pop	h
		inr	e		; следующая позиция в строке
		ret
; Вывод символа в нечётной позиции
; I: DE=adresa predlohy znaku, HL=adresa VRAM
Print4S0:	mov	a,m		; 2x medzera nad znakom
		ani	0F0h
		mov	m,a
		dcr	l		; следующая строка
		mov	a,m
		ani	0F0h
		mov	m,a
		dcr	l		; следующая строка
		mvi	b,5		; vyska predlohy znaku
Print4S0L:	mov	a,m		; берём байт знака
		ani	0F0h
		mov	m,a
		ldax	d
		inx	d
		ora	m
		mov	m,a
		dcr	l		; следующая строка
		dcr	b
		jnz	Print4S0L
		mov	a,m		; место под символом
		ani	0F0h
		mov	m,a
		pop	d
		pop	h
		inr	e		; следующая позиция в строке
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
		.db	3,23
		.db	":PRESS=ANY=KEY=WHEN=READY:",0FFh
		.db	6,0
		.db	":HIGHWAY==ENCOUNTER:",0FFh
		.db	4,1
		.db	":CLASSIFIED=INFORMATION:",0FEh

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
