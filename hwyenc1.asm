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

UsePackedGrp	.equ	0
Release		.equ	1
DebugDemoLvl	.equ	-1	; -1 - Demo od zaciatku
				; 30 az 0 - prva Zona po Intre + SubZony v Zone 0
CheatNoTime	.equ	0
CheatLife	.equ	0
CheatZone0	.equ	0

;------------------------------------------------------------------------------
BaseVramAdr	.equ	0E000h		; Базовый адрес для игрового экрана
SVO		.equ	32		; ширина строки теневого экрана, в столбцах/байтах
SVO8		.equ	(SVO*8)
VVO		.equ	144		; vyska VO v mikroriadkoch
VVOZ		.equ	(VVO/8)		; vyska VO v znakovych riadkoch (18)
InnerScr2	.equ	0C000h-(SVO*VVO)-(14*SVO+8) ; VO2 (0A56Eh)
InnerScr	.equ	InnerScr2-(SVO*VVO)-(SVO*8) ; VO1 (08BE6h)
MarkBuff	.equ	InnerScr-(SVO*VVOZ)-(SVO+8) ; (088ADh)
MarkBuffBeg	.equ	MarkBuff-(3*SVO+8) ; (08824h)
Stack		.equ	100h ;MarkBuffBeg	; zasobnik pred vnutorne obrazovky

;------------------------------------------------------------------------------

; Import declarations from hwyenc0.asm
#include "hwyenc0.exp"

;------------------------------------------------------------------------------

		.org Start
;Start:
		di
		lxi	sp,Stack
; Clear the plane 3 ($8000-$BFFF) from any dirt
		;call ClearPlane3
		ei
; Waiting on the title screen
		call	WaitAnyKey2
		di
		call	ClearPlane012
		call	SetPaletteGame

;		call	Menu
;		call	ShowInfo

		call	DrawGridM
		call	Cls		; zmaz obrazovku
		mvi	l,155		; a vykresli vnutornu obrazovku
		lxi	d,InnerScr+(3*SVO)
		lxi	b,BaseVramAdr+(256-18)
		call	DrawInnerScr

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


Infty:		;jmp Infty
		jmp Start

;------------------------------------------------------------------------------

; Returns: A=key code, $00 no key; Z=0 for key, Z=1 for no key
; Key codes: PxxFLRUD Pause=$80, Fire=$10, Left=$08, Right=$04, Up=$02, Down=$01
ReadKeyboard:
		xra	a
		sta	ReadKeyboard_3+1
		lxi	h,ReadKeyboard_map  ; Point HL at the keyboard list
		mvi	b,3		; number of rows to check
ReadKeyboard_0:        
		mov	e,m		; get address low
		inx	h
		mov	d,m		; get address high
		inx	h
		ldax	d		; get bits for keys
		mvi	c,8		; number of keys in a row
ReadKeyboard_1:
		ral			; shift A left; bit 0 sets carry bit
		jc	ReadKeyboard_2	; if the bit is 1, the key's not pressed
		mov	e,a		; save A
		lda	ReadKeyboard_3+1
		ora	m		; set bit for the key pressed
		sta	ReadKeyboard_3+1
		mov	a,e		; restore A
ReadKeyboard_2:
		inx	h		; next table address
		dcr	c
		jnz	ReadKeyboard_1	; continue the loop by bits
		dcr	b
		jnz	ReadKeyboard_0	; continue the loop by lines
ReadKeyboard_3:
		mvi	a,0		; set the result; mutable parameter!
		ora	a		; set/reset Z flag
		ret
; Mapping: Left = Lt [,  Right = Rt ],  Up = Up SS,  Down = Dn R/L
;          Fire = US Tab Spc PS ZB,  Pause = VK
ReadKeyboard_map:					 ; 7   6   5   4   3   2   1   0
		.DW	KeyLineEx
		.DB	$01,$02,$10,$00,$00,$00,$00,$00  ; R/L SS  US
		.DW	KeyLine0
		.DB	$01,$04,$02,$08,$10,$80,$10,$10  ; Dn  Rt  Up  Lt  ZB  VK  PS  Tab
		.DW	KeyLine7
		.DB	$10,$00,$08,$00,$04,$00,$00,$00  ; Spc  ^   ]   \   [   Z   Y   X

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

TestKbdJoy:	call	ReadKeyboard
		sta	KbdState
		ret

WaitAnyKeyT10:	ret

#include "hwyencdata.asm"

;------------------------------------------------------------------------------

.echo "End of code is "
.echo $
.echo ", start of screen structs is "
.echo MarkBuffBeg
.echo "\n"


;------------------------------------------------------------------------------
	.end
