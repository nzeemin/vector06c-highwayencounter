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
GridAdrM	.equ	InnerScr+(11*SVO)
GridHeightM	.equ	147
;InnerScrSizeM	.equ	(GridHeightM+11)*SVO

;------------------------------------------------------------------------------
Menu:		lxi	h,4533h		; pipni podla HL
		call	Beep
MenuW:		call	WaitNoKey	; pockaj na uvolnenie klavesov

MenuD:		call	DrawGridM	; vykresli mriezku do vnutornej obr.

		call	Cls		; zmaz obrazovku
 		mvi	l,155		; a vykresli vnutornu obrazovku
		lxi	d,InnerScr+(3*SVO)
		lxi	b,BaseVramAdr+(256-18)
		call	DrawInnerScr

		call	AnimateLabel	; zobraz animovany nadpis
		lxi	h,TMenu		; adresa Menu textu
		call	Print85Text	; zobraz text

	#if UsePackedGrp
		lxi	h,LogoVortex	; rozpakuj logo Vortex
		lxi	d,0C000h-LogoVortexSize
		call	dzx7
		lxi	h,BaseVramAdr+1	; vykrelenie loga Vortex
		lxi	d,0C000h-LogoVortexSize
		lxi	b,11*256+56
		call	DrawSprite
	#else
		lxi	h,BaseVramAdr+HILO(1,255)	; vykrelenie loga Vortex
		lxi	d,LogoVortex
		lxi	b,HILO(8,56)
		call	DrawSprite
	#endif

MenuOpt:	call	WaitNoKey
MenuOptC:	lxi	b,4		; test klavesov 1 az 5
MenuOptA:	mov	a,c
;		out	SysPA
;		in	SysPB
		ani	2
		jz	MenuOptB
		dcr	c
		jp	MenuOptA
	#if ~~Release
;		in	SysPB
;		ani	40h
;		rz
	#endif
		jmp	MenuOptC

MenuOptB:	lxi	h,MenuOptRut
		dad	b
		dad	b
		mov	e,m
		inx	h
		mov	d,m
		xchg
		pchl

;------------------------------------------------------------------------------
MenuKbd:	lda	CtrlType
		ora	a
		jz	MenuOpt
		inr	a
		lxi	h,HILO(12,10)
		lxi	d,1E78h
MenuKbdJoy:	sta	CtrlType
		push	d
		lxi	d,HILO(14,20)
		mov	a,h
		call	Print85
		inr	d
		dcr	e
		dcr	e
		dcr	e
		mov	a,l
		call	Print85
		pop	h
		call	Beep
		jmp	MenuOpt

;------------------------------------------------------------------------------
MenuJoy:	lda	CtrlType
		ora	a
		jnz	MenuOpt
		dcr	a
		lxi	h,HILO(10,12)
		lxi	d,2080h
		jmp	MenuKbdJoy

;------------------------------------------------------------------------------
MenuInfo:	call	ShowInfo
		jmp	Menu

;------------------------------------------------------------------------------
MenuDemo:	lxi	h,646Eh		; pipni podla HL
		call	Beep
		call	Demo
		jmp	MenuW

;------------------------------------------------------------------------------
MenuGame:	lxi	h,54A0h
		call	Beep		; pipni podla HL
		call	StartGame	; spusti samotnu hru
		lxi	h,0C801h
		call	Beep		; pipni podla HL
		lda	Aborted		; bola hra prerusena?
		ana	a
		jnz	MenuD		; ano, navrat do menu ihned
		mvi	a,6		; zdrzanie
MenuI:		mvi	c,0
MenuJ:		mvi	b,0
MenuK:		dcr	b
		jnz	MenuK
		dcr	c
		jnz	MenuJ
		dcr	a
		jnz	MenuI
		jmp	MenuW

;------------------------------------------------------------------------------
; animovane vykrelsenie nadpisu zo spritov
AnimateLabel:
		lxi	d,LabelHE+4	; data nadpisu (zobrazuje sa zprava)
		lxi	b,InnerScr+(11*SVO)+22 ; adresa VO
		call	DrawLabelLine	; zobraz 1. rad
		lxi	b,InnerScr+(14*SVO)+23 ; adresa VO
		call	DrawLabelLine	; zobraz 2. rad
		lxi	b,InnerScr+(17*SVO)+24 ; adresa VO
		call	DrawLabelLine	; zobraz 3. rad
		lxi	b,InnerScr+(20*SVO)+25 ; adresa VO
		call	DrawLabelLine	; zobraz 4. rad
		lxi	b,InnerScr+(23*SVO)+26 ; adresa VO
		call	DrawLabelLine	; zobraz 5. rad
		lxi	b,InnerScr+(29*SVO)+27 ; adresa VO
		call	DrawLabelLine	; zobraz 6. rad
		lxi	b,InnerScr+(32*SVO)+28 ; adresa VO
		call	DrawLabelLine	; zobraz 7. rad
		lxi	b,InnerScr+(35*SVO)+29 ; adresa VO
		call	DrawLabelLine	; zobraz 8. rad
		lxi	b,InnerScr+(38*SVO)+30 ; adresa VO
		call	DrawLabelLine	; zobraz 9. rad
		lxi	b,InnerScr+(41*SVO)+31 ; adresa VO
					; zobraz 10. rad

;------------------------------------------------------------------------------
; I: DE=adresa dat nadpisu, BC=адрес назначения vo VO
DrawLabelLine:
		lxi	h,SprBlast6	; adresa spritu SprBlast6
		call	DrawLblSprK	; zobraz riadok spritov
		;lxi	h,SprBrickA3	; adresa spritu SprBrickA3
		;call	DrawLblSprK	; zobraz riadok spritov
		lxi	h,SprBrickX2	; adresa spritu SprBrickA2
		call	DrawLblSprK	; zobraz riadok spritov
		lxi	h,SprBrickM	; adresa spritu SprBrickM
		call	DrawLblSpr	; zobraz riadok spritov

		lxi	h,5		; posun sa na dalsi riadok
		dad	d		; v datach nadpisu
		xchg
		ret

;------------------------------------------------------------------------------
; I: HL=адрес спрайта, DE=адрес надписи, BC=адрес назначения vo VO
DrawLblSprK:	
;		in	SysPB		; test na Shift alebo Stop
;		cma
;		ani	60h
;		rnz			; ano, navrat
DrawLblSpr:	shld	SpriteAdr+1	; uloz adresu dat spritu
		push	d		; odpamataj adresu dat nadpisu
		push	b		; адрес назначения
		xchg
		shld	LabelAdr+1	; uloz adresu dat nadpisu
		lxi	d,HILO(35,1)	; ширина заголовка 35 пунктов, точечная маска
DrawLblSprA:	push	d		; запомнить счетчик и тип процедуры
		mov	a,m
		ana	e		; точка должна отображаться?
		jz	DrawLblSprD	; нет, переходим
		push	b		; odpamataj cielovu adresu vo VO
		mov	l,c		; адрес назначения в HL
		mov	h,b
		mov	a,d
		ani	3		; теперь в A тип процедуры 0..3
SpriteAdr:	lxi	d,0		; adresa spritu do DE
		call	DrawSpriteM	; zobraz sprite
		pop	b		; obnov cielovu adresu
DrawLblSprD:	lxi	h,(3*SVO)	; posun cielovu adresu
		dad	b		; на 3 микро-строки ниже
		mov	c,l		; a uloz do BC
		mov	b,h
LabelAdr:	lxi	h,0		; adresa dat nadpisu
		pop	d		; obnov pocitadlo bodov a masku
		mov	a,d		; а также на 6 точек влево
;LabelShift:	adi	0		; дополнительный сдвиг на 0..3
		ani	3
		jz	DrawLblSprDA
		dcx	b
DrawLblSprDA:	mov	a,e
		rlc
		jnc	DrawLblSprE
		dcx	h
		shld	LabelAdr+1
DrawLblSprE:	mov	e,a		; uloz novu masku
		dcr	d		; opakuj pre celu sirku nadpisu
		jnz	DrawLblSprA

;		lxi	h,InnerScr+(92*SVO) ; oprav cast okraja mriezky, ktory
;		lxi	d,SVO		; sa prepisal prekreslenim spritov
;		lxi	b,7*256+080h	; vyska 7 uR na lavej strane
;AnimateLabelA:	mov	a,m
;		ora	c
;		mov	m,a
;		dad	d
;		dcr	b
;		jnz	AnimateLabelA
;		lxi	h,InnerScr+(34*SVO)+42
;		lxi	b,(5*256)+1	; vyska 5 uR na pravej strane
;AnimateLabelB:	mov	a,m
;		ora	c
;		mov	m,a
;		dad	d
;		dcr	b
;		jnz	AnimateLabelB

 		mvi	l,VVO-3		; vykresli vnutornu obrazovku
		lxi	d,InnerScr+(3*SVO)
		lxi	b,BaseVramAdr+(256-18)
		call	DrawInnerScr

		pop	b		; obnov cielovu adresu
		pop	d		; obnov adresu dat nadpisu
		ret

;------------------------------------------------------------------------------
ShowInfo:	lxi	h,4533h
		call	Beep

		call	DrawGridM	; vykresli mriezku do vnutornej obr.

		lxi	h,InnerScr+(45*SVO)+5 ; adresa do vnutornej obrazovky
M256S6:		lxi	d,SprAutoVorton	; adresa spritu Auto-Vortona
M256R2C:	call	DrawSprite0	; vykresli sprite
		lxi	h,InnerScr+(49*SVO)+4 ; adresa do vnutornej obrazovky
M256S7:		lxi	d,SprAutoVorton	; adresa spritu Auto-Vortona
M256R4C:	call	DrawSprite0	; vykresli sprite
		lxi	h,InnerScr+(53*SVO)+3 ; adresa do vnutornej obrazovky
M256S8:		lxi	d,SprAutoVorton	; adresa spritu Auto-Vortona
M256R0C:	call	DrawSprite0	; vykresli sprite
		lxi	h,InnerScr+(57*SVO)+2 ; adresa do vnutornej obrazovky
M256S9:		lxi	d,SprAutoVorton	; adresa spritu Auto-Vortona
M256R2D:	call	DrawSprite0	; vykresli sprite
		lxi	h,InnerScr+(63*SVO)+8 ; adresa do vnutornej obrazovky
M256S12:	lxi	d,SprLasertron1	; adresa spritu Lasertronu
M256R0D:	call	DrawSprite2	; vykresli sprite
		lxi	h,InnerScr+(76*SVO)+1 ; adresa do vnutornej obrazovky
M256S13:	lxi	d,SprVortonSW	; adresa spritu Main-Vortona
M256R0E:	call	DrawSprite6	; vykresli sprite

		call	Cls
 		mvi	l,GridHeightM
		lxi	d,InnerScr+(11*SVO)
		lxi	b,BaseVramAdr+(256-26)
		call	DrawInnerScr
		call	PrintSmallInfo
		lxi	h,TInfo
		call	Print85Text

		call	WaitNoKey
		jmp	WaitAnyKey2

;------------------------------------------------------------------------------
; Подготовить сетку на внутреннем экране для Menu и Info.
; Общая высота сетки составляет 147 точек.
DrawGridM:	lxi	h,InnerScr	; vymaz hornu cast VO
		lxi	b,11*SVO
		call	Fill16Z
		; vykresli samotnu mriezku
		lxi	d,GridAdrM	; адрес назначения
		mvi	c,GridHeightM-9	; vyska mriezky -9
		call	DrawGrid
		lxi	d,GridAdrM+((GridHeightM-1)*SVO)
		mvi	c,GridHeightM-2	; vyska mriezky -2
		jmp	DrawBord

;------------------------------------------------------------------------------
; data nadpisu HIGHWAY ENCOUNTER
LabelHE:	.db	00h,57h,75h,57h,50h
		.db	00h,52h,45h,55h,50h
		.db	00h,72h,57h,77h,70h
		.db	00h,52h,55h,75h,20h
		.db	00h,57h,75h,55h,20h
		.db	07h,77h,75h,77h,77h
		.db	04h,54h,55h,52h,45h
		.db	07h,54h,55h,52h,77h
		.db	04h,54h,55h,52h,46h
		.db	07h,57h,77h,52h,75h

;------------------------------------------------------------------------------
MenuOptRut:	.dw	MenuKbd,MenuJoy,MenuInfo,MenuDemo,MenuGame

;------------------------------------------------------------------------------
