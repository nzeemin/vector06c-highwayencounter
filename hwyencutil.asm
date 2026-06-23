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
DrawGrid:	push de; odpamataj adresu VO
		push de
		ld hl,Grid		; adresa vzorky mriezky
		ld b,8		; prvych 8 mikroriadkov
DrawGridA:	push bc; uloz pocitadlo
		push de		; zaciatok riadku na zasobnik
		ld b,8		; skopiruj prvych 8 bytov mriezky
		call Copy8		; do vnutornej obrazovky
		ex (SP),HL			; adresa zaciatku riadku do HL
		ld c,3		; 4 kopie za sebou
DrawGridB:	ld b,8
		push hl
		call Copy8
		pop hl
		dec c
		jp NZ,DrawGridB	; продолжаем заполнять микро-строку
		pop hl
		pop bc
		dec b
		jp NZ,DrawGridA	; продолжаем цикл по строкам
		pop hl		; rozkopiruj 8 mikroriadkov
DrawGridC:	ld b,SVO; pre vytvorenie celej mriezky
		call Copy8
		dec c
		jp NZ,DrawGridC
		pop hl
		ret

;------------------------------------------------------------------------------
; Отрисовка границы вокруг сетки
; I: HL=adresa VO, DE=adresa VO na spodku mriezky, C=vyska-2
; O: -
; M: все
DrawBord:	ld b,SVO-1; ширина сетки без правой стороны
		ld a,0FFh
DrawBordO:	ld (HL),a; верхняя граница
		inc hl
		ld (de),A		; нижняя граница
		inc de
		dec b
		jp NZ,DrawBordO
		ld a,0FFh		; prava strana extra
		ld (HL),a
		ld (de),A
		ld de,SVO-1
DrawBordL:	inc hl
		ld a,(HL)		; lave oramovanie
		or 80h
		ld (HL),a
		add HL,de
		ld a,(HL)		; prave oramovanie
		or 01h
		ld (HL),a
		dec c
		jp NZ,DrawBordL
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
		ex DE,HL			; E=высота, HL=адрес источника
CpyInnerScrL:
;
	MACRO CpyInnerScrMacro
		ld a,(HL)
		ld (bc),A
		inc hl
		inc b
	ENDM
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
	 	ld a,(HL)
	 	ld (bc),A
	 	inc hl
	;
		ld a,b
		and BaseVramAdr/256 ;0E0h
		ld b,a		; к началу строки
		dec c		; перейти к следующей микро-строке
		dec e		; уменьшаем счётчик
		jp NZ,CpyInnerScrL
		ret

;------------------------------------------------------------------------------
; Копирование внутреннего экрана в другое место VO.
; I: L=высота в микро-строках,
;    DE=адрес источника VO,
;    BC=адрес назначения VO
; O: -
; M: все
CopyInnerBuf:
		ld h,b
		ld b,l		; счётчик микро-строк
		ld l,c
CopyInnerBufA:
		ld A,(de)		; 0
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 1
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 2
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 3
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 4
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 5
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 6
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 7
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 8
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 9
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 10
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 11
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 12
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 13
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 14
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 15
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 16
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 17
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 18
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 19
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 20
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 21
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 22
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 23
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 24
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 25
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 26
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 17
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 28
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 29
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 30
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 31
		ld (HL),a
		inc de
		inc hl
;
		dec b
		jp NZ,CopyInnerBufA
		ret

;------------------------------------------------------------------------------
; Очищает весь экран.
; I: -
; O: -
; M: все
Cls:
		ld hl,00000h
		jp P,ClearPlane
ClearPlane012:
		ld hl,00000h
		call ClearPlane
		ld hl,0E000h
		call ClearPlane
		ld hl,0C000h
		jp P,ClearPlane
; Clear plane selected by A = plane address hi byte
ClearPlaneA:
		add A,020h
		ld h,a
		ld l,0
ClearPlane:
		ex DE,HL			; now DE = screen address
		ld hl,0		; odpamataj SP
		add HL,sp
		ld (ClsSP+1),HL
		ex DE,HL			; HL = screen address
		ld bc,0
		ld d,b
		ld e,b
		ld SP,HL
ClsL:
		push de		; 1
		push de
		push de
		push de		; 4
		push de
		push de
		push de
		push de		; 8
		push de		; 9
		push de
		push de
		push de		; 12
		push de
		push de
		push de
		push de		; 16
;
		dec b
		jp NZ,ClsL
ClsSP:		ld sp,0
		ret

;------------------------------------------------------------------------------
; Копирование блока максимум 256 баит.
; I: HL=zdroj, DE=ciel, B=velkost bloku
; O: B=0
; M: AF, B, DE, HL
Copy8:		ld a,(HL)
		ld (de),A
		inc hl
		inc de
		dec b
		jp NZ,Copy8
		ret

;------------------------------------------------------------------------------
; Копирование блока максимум 65536 баит.
; I: HL=zdroj, DE=ciel, BC=velkost bloku
; O: -
; M: все
Copy16:		ld a,(HL)
		ld (de),A
		inc hl
		inc de
		dec bc
		ld a,b
		or c
		jp NZ,Copy16
		ret

;------------------------------------------------------------------------------
; Vyplnenie bloku o max. velkosti 65536 bytov.
; I: HL=ciel, E=byte, BC=velkost bloku
; O: -
; M: HL, E, BC, AF
Fill16Z:	ld e,0
Fill16:		ld (HL),e
		inc hl
		dec bc
		ld a,b
		or c
		jp NZ,Fill16
		ret

;------------------------------------------------------------------------------
; BC=BC-HL
; I: HL, BC=hodnoty
; O: BC=vysledok
; M: BC, AF
SubBCHL:	ld a,c
		sub l
		ld c,a
		ld a,b
		sbc A,h
		ld b,a
		ret

;------------------------------------------------------------------------------
; HL=HL-DE
; I: HL, DE=hodnoty
; O: HL=vysledok
; M: HL, AF
SubHLDE:	ld a,l
		sub e
		ld l,a
		ld a,h
		sbc A,d
		ld h,a
		ret

;------------------------------------------------------------------------------
; DE=DE-BC
; I: DE, BC=hodnoty
; O: DE=vysledok
; M: HL, AF
SubDEBC:	ld a,e
		sub c
		ld e,a
		ld a,d
		sbc A,b
		ld d,a
		ret

;------------------------------------------------------------------------------
; Целочисленное деление 8bit/8bit.
; I: H=delenec, D=delitel
; O: L=podiel, A=zbytok, H=B=0
; M: AF, B, HL
	if	0
Div8x8:		xor a; vynuluj zbytok po deleni
		ld l,a		; vynuluj podiel
		ld b,8		; 8 radov
		jp Div16x8L
	endif

;------------------------------------------------------------------------------
; Целочисленное деление 16bit/8bit.
; (V priebehu vypoctu obsahuje HL cast delenca a aj cast podielu.)
; I: HL=delenec, D=delitel
; O: HL=podiel, A=zbytok, B=0
; M: AF, B, HL
Div16x8:	xor a; vynuluj zbytok po deleni
		ld b,16		; 16 radov
Div16x8L:	add HL,hl; zdvojnasob delenec i podiel, najvyssi bit do CY
		rla			; zdvojnasob zbytok po deleni a pripocitaj CY
		cp d		; obsahuje tento rad?
		jp C,Div16x8N	; nie, skoc dalej
		sub d		; ano, odpocitaj rad
		inc l		; a zvys podiel
Div16x8N:	dec b; opakuj pre vsetky rady
		jp NZ,Div16x8L
		ret

;------------------------------------------------------------------------------
; Псевдослучайное 8-битное число с периодом 256 по отношению: X[1] = X[0] * 5 + 7
; I: -
; O: A=RND
; M: HL, AF
Rand:		ld hl,RndVal
		ld a,(HL)
		add A,a
		add A,a
		add A,(HL)
		add A,7
		ld (HL),a
		ret

;-----------------------------------------------------------------------------
