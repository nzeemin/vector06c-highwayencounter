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
; Рисование сетки.
; I: DE=adresa vnutornej obrazovky, C=vyska-9
; O: HL=adresa vnutornej obrazovky, BC=0
; M: все
DrawGrid:	push	d		; odpamataj adresu VO
		push	d
		lxi	h,Grid		; adresa vzorky mriezky
		mvi	b,8		; prvych 8 mikroriadkov
DrawGridA:	push	b		; uloz pocitadlo
		push	d		; zaciatok riadku na zasobnik
		mvi	b,8		; skopiruj prvych 8 bytov mriezky
		call	Copy8		; do vnutornej obrazovky
		xthl			; adresa zaciatku riadku do HL
		mvi	c,3		; 4 kopie za sebou
DrawGridB:	mvi	b,8
		push	h
		call	Copy8
		pop	h
		dcr	c
		jnz	DrawGridB	; продолжаем заполнять микро-строку
		pop	h
		pop	b
		dcr	b
		jnz	DrawGridA	; продолжаем цикл по строкам
		pop	h		; rozkopiruj 8 mikroriadkov
DrawGridC:	mvi	b,SVO		; pre vytvorenie celej mriezky
		call	Copy8
		dcr	c
		jnz	DrawGridC
		pop	h
		ret

;------------------------------------------------------------------------------
; Отрисовка границы вокруг сетки
; I: HL=adresa VO, DE=adresa VO na spodku mriezky, C=vyska-2
; O: -
; M: все
DrawBord:	mvi	b,SVO-1		; ширина сетки без правой стороны
		mvi	a,0FFh
DrawBordO:	mov	m,a		; верхняя граница
		inx	h
		stax	d		; нижняя граница
		inx	d
		dcr	b
		jnz	DrawBordO
		mvi	a,0FFh		; prava strana extra
		mov	m,a
		stax	d
		lxi	d,SVO-1
DrawBordL:	inx	h
		mov	a,m		; lave oramovanie
		ori	80h
		mov	m,a
		dad	d
		mov	a,m		; prave oramovanie
		ori	01h
		mov	m,a
		dcr	c
		jnz	DrawBordL
		ret

;------------------------------------------------------------------------------
; Рендеринг внутреннего экрана в VRAM.
; I: L=высота в микро-строках,
;    DE=адрес источника vnutornej obrazovky,
;    BC=адрес назначения VRAM
; O: -
; M: все
DrawInnerScr:
;		mvi	a,64-SVO+1
;		jmp	CpyInnerScr
;------------------------------------------------------------------------------
; Копирование внутреннего экрана на VRAM.
; I: L=высота в микро-строках,
;    DE=адрес источника VO,
;    BC=адрес назначения VRAM
; O: -
; M: все
CpyInnerScr:	
		xchg			; E=высота, HL=адрес источника
CpyInnerScrL:
;
#define		CpyInnerScrMacro	mov	a,m
#defcont			\	stax	b
#defcont			\	inx	h
#defcont			\	inr	b
;
		CpyInnerScrMacro	; 0
		CpyInnerScrMacro	; 1
		CpyInnerScrMacro	; 2
		CpyInnerScrMacro	; 3
		CpyInnerScrMacro	; 4
		CpyInnerScrMacro	; 5
		CpyInnerScrMacro	; 6
		CpyInnerScrMacro	; 7
		CpyInnerScrMacro	; 8
		CpyInnerScrMacro	; 9
		CpyInnerScrMacro	; 10
		CpyInnerScrMacro	; 11
		CpyInnerScrMacro	; 12
		CpyInnerScrMacro	; 13
		CpyInnerScrMacro	; 14
		CpyInnerScrMacro	; 15
		CpyInnerScrMacro	; 16
		CpyInnerScrMacro	; 17
		CpyInnerScrMacro	; 18
		CpyInnerScrMacro	; 19
		CpyInnerScrMacro	; 20
		CpyInnerScrMacro	; 21
		CpyInnerScrMacro	; 22
		CpyInnerScrMacro	; 23
		CpyInnerScrMacro	; 24
		CpyInnerScrMacro	; 25
		CpyInnerScrMacro	; 26
		CpyInnerScrMacro	; 27
		CpyInnerScrMacro	; 28
		CpyInnerScrMacro	; 29
		CpyInnerScrMacro	; 30
	; 31, последний столбец
	 	mov	a,m
	 	stax	b
	 	inx	h
	;
		mov	a,b
		ani	BaseVramAdr/256 ;0E0h
		mov	b,a		; к началу строки
		dcr	c		; перейти к следующей микро-строке
		dcr	e		; уменьшаем счётчик
		jnz	CpyInnerScrL
		ret

;------------------------------------------------------------------------------
; Копирование внутреннего экрана в другое место VO.
; I: L=высота в микро-строках,
;    DE=адрес источника VO,
;    BC=адрес назначения VO
; O: -
; M: все
CopyInnerBuf:	
		mov	h,b
		mov	b,l		; счётчик микро-строк
		mov	l,c
CopyInnerBufA:
		ldax	d		; 0
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 1
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 2
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 3
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 4
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 5
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 6
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 7
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 8
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 9
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 10
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 11
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 12
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 13
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 14
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 15
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 16
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 17
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 18
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 19
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 20
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 21
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 22
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 23
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 24
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 25
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 26
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 17
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 28
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 29
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 30
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 31
		mov	m,a
		inx	d
		inx	h
;
		dcr	b
		jnz	CopyInnerBufA
		ret

;------------------------------------------------------------------------------
; Очищает весь экран.
; I: -
; O: -
; M: все
Cls:
		lxi	h,00000h
		jp	ClearPlane
ClearPlane012:
		lxi	h,00000h
		call	ClearPlane
		lxi	h,0E000h
		call	ClearPlane
		lxi	h,0C000h
		jp	ClearPlane
; Clear plane selected by A = plane address hi byte
ClearPlaneA:
		adi	020h
		mov	h,a
		mvi	l,0
ClearPlane:
		xchg			; now DE = screen address
		lxi	h,0		; odpamataj SP
		dad	sp
		shld	ClsSP+1
		xchg			; HL = screen address
		lxi	b,0
		mov	d,b
		mov	e,b
		sphl
ClsL:
		push	d		; 1
		push	d
		push	d
		push	d		; 4
		push	d
		push	d
		push	d
		push	d		; 8
		push	d		; 9
		push	d
		push	d
		push	d		; 12
		push	d
		push	d
		push	d
		push	d		; 16
;
		dcr	b
		jnz	ClsL
ClsSP:		lxi	sp,0
		ret

;------------------------------------------------------------------------------
; Копирование блока максимум 256 баит.
; I: HL=zdroj, DE=ciel, B=velkost bloku
; O: B=0
; M: AF, B, DE, HL
Copy8:		mov	a,m
		stax	d
		inx	h
		inx	d
		dcr	b
		jnz	Copy8
		ret

;------------------------------------------------------------------------------
; Копирование блока максимум 65536 баит.
; I: HL=zdroj, DE=ciel, BC=velkost bloku
; O: -
; M: все
Copy16:		mov	a,m
		stax	d
		inx	h
		inx	d
		dcx	b
		mov	a,b
		ora	c
		jnz	Copy16
		ret

;------------------------------------------------------------------------------
; Vyplnenie bloku o max. velkosti 65536 bytov.
; I: HL=ciel, E=byte, BC=velkost bloku
; O: -
; M: HL, E, BC, AF
Fill16Z:	mvi	e,0
Fill16:		mov	m,e
		inx	h
		dcx	b
		mov	a,b
		ora	c
		jnz	Fill16
		ret

;------------------------------------------------------------------------------
; BC=BC-HL
; I: HL, BC=hodnoty
; O: BC=vysledok
; M: BC, AF
SubBCHL:	mov	a,c
		sub	l
		mov	c,a
		mov	a,b
		sbb	h
		mov	b,a
		ret

;------------------------------------------------------------------------------
; HL=HL-DE
; I: HL, DE=hodnoty
; O: HL=vysledok
; M: HL, AF
SubHLDE:	mov	a,l
		sub	e
		mov	l,a
		mov	a,h
		sbb	d
		mov	h,a
		ret

;------------------------------------------------------------------------------
; DE=DE-BC
; I: DE, BC=hodnoty
; O: DE=vysledok
; M: HL, AF
SubDEBC:	mov	a,e
		sub	c
		mov	e,a
		mov	a,d
		sbb	b
		mov	d,a
		ret

;------------------------------------------------------------------------------
; Целочисленное деление 8bit/8bit.
; I: H=delenec, D=delitel
; O: L=podiel, A=zbytok, H=B=0
; M: AF, B, HL
	#if	0
Div8x8:		xra	a		; vynuluj zbytok po deleni
		mov	l,a		; vynuluj podiel
		mvi	b,8		; 8 radov
		jmp	Div16x8L
	#endif

;------------------------------------------------------------------------------
; Целочисленное деление 16bit/8bit.
; (V priebehu vypoctu obsahuje HL cast delenca a aj cast podielu.)
; I: HL=delenec, D=delitel
; O: HL=podiel, A=zbytok, B=0
; M: AF, B, HL
Div16x8:	xra	a		; vynuluj zbytok po deleni
		mvi	b,16		; 16 radov
Div16x8L:	dad	h		; zdvojnasob delenec i podiel, najvyssi bit do CY
		ral			; zdvojnasob zbytok po deleni a pripocitaj CY
		cmp	d		; obsahuje tento rad?
		jc	Div16x8N	; nie, skoc dalej
		sub	d		; ano, odpocitaj rad
		inr	l		; a zvys podiel
Div16x8N:	dcr	b		; opakuj pre vsetky rady
		jnz	Div16x8L
		ret

;------------------------------------------------------------------------------
; Псевдослучайное 8-битное число с периодом 256 по отношению: X[1] = X[0] * 5 + 7
; I: -
; O: A=RND
; M: HL, AF
Rand:		lxi	h,RndVal
		mov	a,m
		add	a
		add	a
		add	m
		adi	7
		mov	m,a
		ret

;-----------------------------------------------------------------------------
