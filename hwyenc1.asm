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

; Макрос для создания слова из старшего/младшего байт
#define		HILO(hi,lo) ((256*(hi))+(lo))

;------------------------------------------------------------------------------

Mem256		.equ	1
UsePackedGrp	.equ	0
Release		.equ	1
DebugDemoLvl	.equ	-1	; -1 - Demo od zaciatku
				; 30 az 0 - prva Zona po Intre + SubZony v Zone 0
CheatNoTime	.equ	1
CheatLife	.equ	1
CheatZone0	.equ	0

;------------------------------------------------------------------------------
BaseVramAdr	.equ	0E000h		; Базовый адрес для игрового экрана
BaseVramAdr2	.equ	0C000h		; Базовый адрес для второго экрана
SVO		.equ	32		; ширина строки теневого экрана, в столбцах/байтах
SVO8		.equ	(SVO*8)
VVO		.equ	144		; vyska VO v mikroriadkoch
VVOZ		.equ	(VVO/8)		; vyska VO v znakovych riadkoch (18)
InnerScr2	.equ	0C000h-(SVO*VVO)-(14*SVO+8) ; VO2 (0A56Eh)
InnerScr	.equ	InnerScr2-(SVO*VVO)-(SVO*8) ; VO1 (08BE6h)
MarkBuff	.equ	InnerScr-(SVO*VVOZ)-(SVO+8) ; (088ADh)
MarkBuffBeg	.equ	MarkBuff-(3*SVO+8) ; (08824h)
Stack		.equ	2E0h ;MarkBuffBeg	; zasobnik pred vnutorne obrazovky

;------------------------------------------------------------------------------

; Import declarations from hwyenc0.exp
#include "hwyenc0.exp"

;------------------------------------------------------------------------------

		.org 2E0h
Start:
		di
		lxi sp,Stack
; Clear the plane 3 ($8000-$BFFF) from any dirt
		;call ClearPlane3
		ei
;TODO: Pause, then show sign "Press Any Key When Ready"
; Waiting on the title screen
;		call	WaitAnyKey2
		di
		call	ClearPlane012
		call	SetPaletteGame

;		call	Menu
;		call	ShowInfo

;		lxi	h,4533h
;		lxi	h,54A0h
;		lxi	h,646Eh
;		lxi	h,0C801h
;		lxi	h,1E78h
;		call	Beep

		call	DrawGridM
		call	Cls		; zmaz obrazovku
		mvi	l,155		; a vykresli vnutornu obrazovku
		lxi	d,InnerScr+(3*SVO)
		lxi	b,BaseVramAdr+(256-18)
		call	DrawInnerScr

;		lxi	d,LabelHE+4	; data nadpisu (zobrazuje sa zprava)
;		lxi	b,InnerScr+(11*SVO)+30	 ; adresa VO
;		lxi	h,SprBrickX4	; adresa spritu SprBrickM
;		call	DrawLblSpr	; zobraz riadok spritov

		call	AnimateLabel	; zobraz animovany nadpis

;		lxi	d,LabelHE+4	; data nadpisu (zobrazuje sa zprava)
;		lxi	b,InnerScr+(11*SVO)+29 ; adresa VO
;		lxi	h,SprBrickX4	; adresa spritu SprBrickM
;		call	DrawLblSpr	; zobraz riadok spritov
;		call	DrawLabelLine	; zobraz 1. rad

;		lxi	h,BackupVars	; inicializuj pociatocne hodnoty
;		lxi	d,Vars		; premennych
;		mvi	b,VarsLen
;		call	Copy8
;		call	ShowPanel	; zmaz obr. a zobraz dolny panel
;		call	InitSpr		; inicializuj sprity
;		call	PrepSpr		; priprav sprity
;		call	DrawZone	; vykresli Zonu 30

;		lxi	d,InnerScr2	; vykreslenie mriezky do VO2
;		mvi	c,VVO-9
;		call	DrawGrid

;		call	DrawLand

;		mvi	l,VVO
;		lxi	d,InnerScr2	; prekopirovanie VO2 do VO1
;		lxi	b,InnerScr
;		call	CopyInnerBuf

;		mvi	l,GridHeightM
;		lxi	d,InnerScr+(11*SVO)
;		lxi	b,BaseVramAdr+(256-26)
;		call	DrawInnerScr

;		lxi	h,BaseVramAdr+(255-184)-$2000	; vykreslenie panelu
;		lxi	d,GamePanel
;		lxi	b,(32*256)+34
;		call	DrawSprite

		lxi	h,TMenu
		call	Print85Text
		lxi	h,BaseVramAdr+HILO(1,255)	; vykrelenie loga Vortex
		lxi	d,LogoVortex
		lxi	b,HILO(8,56)
		call	DrawSprite

;		call	ShowPanel
;		call	Intro
;		call	StartGame

;		mvi	a,11
;		sta	ZoneNumber
;		call	PrepSpr
;		call	DrawZone

;		call	RedrawChanges

;		call	DrawSubZone5

;		mvi	l,VVO+16
;		lxi	d,InnerScr2-(SVO*8)
;		lxi	b,BaseVramAdr+(256-16)
;		call	DrawInnerScr

;		call	Demo

;		mvi	a,16
;		call	PrintZoneNum
;		call	PrtScore

Infty:	jmp Infty
	jmp Start

;------------------------------------------------------------------------------

; Returns: A=key code, $00 no key; Z=0 for key, Z=1 for no key
; Key codes: Down=$01, Left=$02, Right=$03, Up=$04, Look/shoot=$05
;            Inventory=$06, Escape=$07, Switch look/shoot=$08, Enter=$09, Menu=$0F
ReadKeyboard:
		lxi	h,ReadKeyboard_map	; Point HL at the keyboard list
		mvi	b,6		; number of rows to check
ReadKeyboard_0:        
		mov	e,m		; get address low
		inx	h
		mov	d,m		; get address high
		inx	h
		ldax	d		; get bits for keys
		mvi	c,8		; number of keys in a row
ReadKeyboard_1:
		ral			; shift A left; bit 0 sets carry bit
		jnc	ReadKeyboard_2	; if the bit is 0, we've found our key
		inx	h		; next table address
		dcr	c
		jnz	ReadKeyboard_1	; continue the loop by bits
		dcr	b
		jz	ReadKeyboard_0	; continue the loop by lines
		xra	a		; clear A, no key found
		ret
ReadKeyboard_2:
		mov	a,m		; We've found a key, fetch the character code
		ora	a
		ret
; Mapping: Arrows; US/Space - look/shoot, Tab/RusLat - switch look/shoot,
;          AR2/ZB/PS - escape, I/M - inventory; P/R - menu, Enter=Enter
ReadKeyboard_map:
		.DW	KeyLineEx
		.DB	$08,$00,$05,$00,$00,$00,$00,$00  ; R/L SS  US
		.DW	KeyLine0
		.DB	$01,$03,$04,$02,$07,$09,$07,$08  ; Dn  Rt  Up  Lt  ZB  VK  PS  Tab
		.DW	KeyLine1
		.DB	$00,$00,$00,$00,$00,$07,$00,$00  ; F5  F4  F3  F2  F1  AR2 Str  ^\
		.DW	KeyLine5
		.DB	$00,$00,$06,$00,$00,$00,$06,$00  ;  O   N   M   L   K   J   I   H
		.DW	KeyLine6
		.DB	$00,$00,$00,$00,$00,$0F,$00,$0F  ;  W   V   U   T   S   R   Q   P
		.DW	KeyLine7
		.DB	$05,$00,$00,$00,$00,$00,$00,$00  ; Spc  ^   ]   \   [   Z   Y   X

;------------------------------------------------------------------------------

WaitAnyKey2:
		call	ReadKeyboard
		ora	a
		jz	WaitAnyKey2	; Wait for press
WaitNoKey:
		call	ReadKeyboard
		ora	a
		jnz	WaitNoKey	; Wait for unpress
		ret

;------------------------------------------------------------------------------

#include "hwyencmenu.asm"
#include "hwyencprint.asm"
#include "hwyencsound.asm"
#include "hwyencsprite.asm"
#include "hwyenczone.asm"
#include "hwyencgame.asm"
#include "hwyencutil.asm"

TestKbdJoy:	ret
WaitAnyKeyT10:	ret

#include "hwyencdata.asm"


;------------------------------------------------------------------------------
	.end
