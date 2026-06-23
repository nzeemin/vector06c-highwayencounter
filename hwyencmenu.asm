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
; nzeemin 2022/2026 порт на Вектор-06Ц
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
GridAdrM	.equ	InnerScr+(11*SVO)
GridHeightM	.equ	147
;InnerScrSizeM	.equ	(GridHeightM+11)*SVO

;------------------------------------------------------------------------------
Menu:		ld hl,4533h; pipni podla HL
		call Beep
MenuW:		call WaitNoKey; pockaj na uvolnenie klavesov

MenuD:		call DrawGridM; vykresli mriezku do vnutornej obr.

		call Cls		; zmaz obrazovku
 		ld l,155		; a vykresli vnutornu obrazovku
		ld de,InnerScr+(3*SVO)
		ld bc,BaseVramAdr+(256-18)
		call DrawInnerScr

		call AnimateLabel	; zobraz animovany nadpis
		ld hl,TMenu		; adresa Menu textu
		call Print85Text	; zobraz text

	if UsePackedGrp
		ld hl,LogoVortex	; rozpakuj logo Vortex
		ld de,0C000h-LogoVortexSize
		call dzx7
		ld hl,BaseVramAdr+1	; vykrelenie loga Vortex
		ld de,0C000h-LogoVortexSize
		ld bc,11*256+56
		call DrawSprite
	else
		ld hl,BaseVramAdr+ (1<<8)|255
		ld de,LogoVortex
		ld bc, (8<<8)|56
		call DrawSprite
	endif

MenuOpt:	call WaitNoKey
MenuOptC:	ld bc,4; test klavesov 1 az 5
MenuOptA:	ld a,c
;		out	SysPA
;		in	SysPB
		and 2
		jp Z,MenuOptB
		dec c
		jp P,MenuOptA
	if ~~Release
;		in	SysPB
;		ani	40h
;		rz
	endif
		jp MenuOptC

MenuOptB:	ld hl,MenuOptRut
		add HL,bc
		add HL,bc
		ld e,(HL)
		inc hl
		ld d,(HL)
		ex DE,HL
		jp (HL)

;------------------------------------------------------------------------------
MenuKbd:	ld A,(CtrlType)
		or a
		jp Z,MenuOpt
		inc a
		ld hl, (12<<8)|10
		ld de,1E78h
MenuKbdJoy:	ld (CtrlType),A
		push de
		ld de, (14<<8)|20
		ld a,h
		call Print85
		inc d
		dec e
		dec e
		dec e
		ld a,l
		call Print85
		pop hl
		call Beep
		jp MenuOpt

;------------------------------------------------------------------------------
MenuJoy:	ld A,(CtrlType)
		or a
		jp NZ,MenuOpt
		dec a
		ld hl, (10<<8)|12
		ld de,2080h
		jp MenuKbdJoy

;------------------------------------------------------------------------------
MenuInfo:	call ShowInfo
		jp Menu

;------------------------------------------------------------------------------
MenuDemo:	ld hl,646Eh; pipni podla HL
		call Beep
		call Demo
		jp MenuW

;------------------------------------------------------------------------------
MenuGame:	ld hl,54A0h
		call Beep		; pipni podla HL
		call StartGame	; spusti samotnu hru
		ld hl,0C801h
		call Beep		; pipni podla HL
		ld A,(Aborted)		; bola hra prerusena?
		and a
		jp NZ,MenuD		; ano, navrat do menu ihned
		ld a,6		; zdrzanie
MenuI:		ld c,0
MenuJ:		ld b,0
MenuK:		dec b
		jp NZ,MenuK
		dec c
		jp NZ,MenuJ
		dec a
		jp NZ,MenuI
		jp MenuW

;------------------------------------------------------------------------------
; animovane vykrelsenie nadpisu zo spritov
; Точные значения из Spectrum (LB33C): на строку — байт VO и фаза сдвига.
; A = фаза строки k=(phaseInit+1)&3; байты/фазы как на Спектруме (8px/байт).
AnimateLabel:
		ld de,LabelHE+4	; data nadpisu (zobrazuje sa zprava)
		ld a,2		; фаза строки 1
		ld bc,InnerScr+(11*SVO)+22 ; adresa VO
		call DrawLabelLine	; zobraz 1. rad
		ld a,3
		ld bc,InnerScr+(14*SVO)+23 ; adresa VO
		call DrawLabelLine	; zobraz 2. rad
		ld a,0
		ld bc,InnerScr+(17*SVO)+24 ; adresa VO
		call DrawLabelLine	; zobraz 3. rad
		ld a,1
		ld bc,InnerScr+(20*SVO)+24 ; adresa VO
		call DrawLabelLine	; zobraz 4. rad
		ld a,2
		ld bc,InnerScr+(23*SVO)+25 ; adresa VO
		call DrawLabelLine	; zobraz 5. rad
		ld a,0
		ld bc,InnerScr+(29*SVO)+27 ; adresa VO
		call DrawLabelLine	; zobraz 6. rad
		ld a,1
		ld bc,InnerScr+(32*SVO)+27 ; adresa VO
		call DrawLabelLine	; zobraz 7. rad
		ld a,2
		ld bc,InnerScr+(35*SVO)+28 ; adresa VO
		call DrawLabelLine	; zobraz 8. rad
		ld a,3
		ld bc,InnerScr+(38*SVO)+29 ; adresa VO
		call DrawLabelLine	; zobraz 9. rad
		ld a,0
		ld bc,InnerScr+(41*SVO)+30 ; adresa VO
					; zobraz 10. rad

;------------------------------------------------------------------------------
; I: A=фаза строки k, DE=adresa dat nadpisu, BC=адрес назначения vo VO
DrawLabelLine:
		ld (LblPhaseD+1),A	; k — для фазы p=(D+k)&3
		inc a
		and 3
		ld (LblPhaseT+1),A	; (k+1)&3 — для типа сдвига (p+1)&3
		ld hl,SprBlast6	; adresa spritu SprBlast6
		call DrawLblSprK	; zobraz riadok spritov
		;lxi	h,SprBrickA3	; adresa spritu SprBrickA3
		;call	DrawLblSprK	; zobraz riadok spritov
		ld hl,SprBrickX2	; adresa spritu SprBrickA2
		call DrawLblSprK	; zobraz riadok spritov
		ld hl,SprBrickM	; adresa spritu SprBrickM
		call DrawLblSpr	; zobraz riadok spritov

		ld hl,5		; posun sa na dalsi riadok
		add HL,de		; v datach nadpisu
		ex DE,HL
		ret

;------------------------------------------------------------------------------
; I: HL=адрес спрайта, DE=адрес надписи, BC=адрес назначения vo VO
DrawLblSprK:
;		in	SysPB		; test na Shift alebo Stop
;		cma
;		ani	60h
;		rnz			; ano, navrat
DrawLblSpr:	ld (SpriteAdr+1),HL; uloz adresu dat spritu
		push de		; odpamataj adresu dat nadpisu
		push bc		; адрес назначения
		ex DE,HL
		ld (LabelAdr+1),HL	; uloz adresu dat nadpisu
		ld de, (35<<8)|1
DrawLblSprA:	push de; запомнить счетчик и тип процедуры
		ld a,(HL)
		and e		; точка должна отображаться?
		jp Z,DrawLblSprD	; нет, переходим
		push bc		; odpamataj cielovu adresu vo VO
		ld l,c		; адрес назначения в HL
		ld h,b
		ld a,d		; тип сдвига = (D+k+1)&3 (фаза p=(D+k)&3)
LblPhaseT:	add a,0		; +(k+1), самомодиф. в DrawLabelLine
		and 3		; теперь в A тип процедуры 0..3
SpriteAdr:	ld de,0; adresa spritu do DE
		call DrawSpriteM	; zobraz sprite
		pop bc		; obnov cielovu adresu
DrawLblSprD:	ld hl,3*SVO; posun cielovu adresu
		add HL,bc		; на 3 микро-строки ниже
		ld c,l		; a uloz do BC
		ld b,h
LabelAdr:	ld hl,0; adresa dat nadpisu
		pop de		; obnov pocitadlo bodov a masku
		ld a,d		; шаг байта влево, когда фаза p=(D+k)&3 != 0
LblPhaseD:	add a,0		; +k, самомодиф. в DrawLabelLine
		and 3
		jp Z,DrawLblSprDA	; p==0 — без сдвига байта (аккумулятор не переполнился)
		dec bc
DrawLblSprDA:	ld a,e
		rlca
		jp NC,DrawLblSprE
		dec hl
		ld (LabelAdr+1),HL
DrawLblSprE:	ld e,a; uloz novu masku
		dec d		; opakuj pre celu sirku nadpisu
		jp NZ,DrawLblSprA

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

 		ld l,VVO-3		; vykresli vnutornu obrazovku
		ld de,InnerScr+(3*SVO)
		ld bc,BaseVramAdr+(256-18)
		call DrawInnerScr

		pop bc		; obnov cielovu adresu
		pop de		; obnov adresu dat nadpisu
		ret

;------------------------------------------------------------------------------
ShowInfo:	ld hl,4533h
		call Beep

		call DrawGridM	; vykresli mriezku do vnutornej obr.

		ld hl,InnerScr+(45*SVO)+5 ; adresa do vnutornej obrazovky
M256S6:		ld de,SprAutoVorton; adresa spritu Auto-Vortona
M256R2C:	call DrawSprite0; vykresli sprite
		ld hl,InnerScr+(49*SVO)+4 ; adresa do vnutornej obrazovky
M256S7:		ld de,SprAutoVorton; adresa spritu Auto-Vortona
M256R4C:	call DrawSprite0; vykresli sprite
		ld hl,InnerScr+(53*SVO)+3 ; adresa do vnutornej obrazovky
M256S8:		ld de,SprAutoVorton; adresa spritu Auto-Vortona
M256R0C:	call DrawSprite0; vykresli sprite
		ld hl,InnerScr+(57*SVO)+2 ; adresa do vnutornej obrazovky
M256S9:		ld de,SprAutoVorton; adresa spritu Auto-Vortona
M256R2D:	call DrawSprite0; vykresli sprite
		ld hl,InnerScr+(63*SVO)+8 ; adresa do vnutornej obrazovky
M256S12:	ld de,SprLasertron1; adresa spritu Lasertronu
M256R0D:	call DrawSprite2; vykresli sprite
		ld hl,InnerScr+(76*SVO)+1 ; adresa do vnutornej obrazovky
M256S13:	ld de,SprVortonSW; adresa spritu Main-Vortona
M256R0E:	call DrawSprite6; vykresli sprite

		call Cls
 		ld l,GridHeightM
		ld de,InnerScr+(11*SVO)
		ld bc,BaseVramAdr+(256-26)
		call DrawInnerScr
		call PrintSmallInfo
		ld hl,TInfo
		call Print85Text

		call WaitNoKey
		jp WaitAnyKey2

;------------------------------------------------------------------------------
; Подготовить сетку на внутреннем экране для Menu и Info.
; Общая высота сетки составляет 147 точек.
DrawGridM:	ld hl,InnerScr; vymaz hornu cast VO
		ld bc,11*SVO
		call Fill16Z
		; vykresli samotnu mriezku
		ld de,GridAdrM	; адрес назначения
		ld c,GridHeightM-9	; vyska mriezky -9
		call DrawGrid
		ld de,GridAdrM+((GridHeightM-1)*SVO)
		ld c,GridHeightM-2	; vyska mriezky -2
		jp DrawBord

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
