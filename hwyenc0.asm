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

	.EXPORT Start
	.EXPORT KeyLineEx
	.EXPORT KeyLine0
	.EXPORT KeyLine7
	.EXPORT JoystickP
	.EXPORT BorderColor
	.EXPORT SetPaletteGame

;----------------------------------------------------------------------------

	.org	100h

	di
	xor a
	out (10h),A			; turn off the quasi-disk
	ld sp,0100h
	ld hl,0C3F3h
	ld (0),HL
	ld a,h
	ld hl,RestartInt
	ld (2),HL
	ld (38h),A
	ld hl,KEYINT		; interrupt handler address
	ld (38h+1),HL

; Move encoded block from Start to 8000h, LZSASIZET+LZSASIZE1 bytes
	ld de,Start			; source addr
	ld bc,08000h		; destination addr
	ld hl,LZSASIZET+LZSASIZE1	; size
	inc h
Init_1:
	ld A,(de)
	inc de
	ld (bc),A
	inc bc
	dec l
	jp NZ,Init_1
	dec h
	jp NZ,Init_1
; Decompress the code and sprites from 08000h+LZSASIZET to Start
	ld de,08000h+LZSASIZET	; source addr
	ld bc,Start			; destination addr
	call dzx0
; Decompress 24K of the title screen from 8000h to A000h
	ld de,08000h		; source addr
	ld bc,0A000h		; destination addr
	call dzx0

RestartInt:
	ld sp,100h
	ld a,88h
	out (4),A			; initialize R-Sound 2
; Joystick init
	ld a,83h		; control byte
	out (4),A		; initialize the I/O controller
	ld a,9Fh		; bits to check Joystick-P, both P1 and P2
	out (5),A		; set Joystick-P query bits
	in A,(6)		; read Joystick-P initial value
	ld (KEYINT_J+1),A	; store as xra instruction parameter

; Set palette for the title screen
	ld hl,PaletteTitle+15
	call SetPalette
;	ei
	jp P,Start

; Set game palette
SetPaletteGame:
	ld hl,PaletteGame+15

; Programming the Palette
SetPalette:
	ei
	halt
	ld de,100Fh
PaletLoop:
	ld a,e
	out (2),A
	ld a,(HL)
	out (0Ch),A
	out (0Ch),A
	out (0Ch),A
	out (0Ch),A
	out (0Ch),A
	dec hl
	out (0Ch),A
	dec e
	out (0Ch),A
	dec d
	out (0Ch),A
	jp NZ,PaletLoop
	ret

;----------------------------------------------------------------------------

KEYINT:
	push af
	ld a,8Ah
	out (0),A
; Keyboard scan
	in A,(1)
	or 00011111b
	ld (KeyLineEx),A
	ld a,0FEh
	out (3),A
	in A,(2)
	ld (KeyLine0),A
;	mvi	a, 0FDh
;	out	3
;	in	2
;	sta	KeyLine1
;	mvi	a, 0DFh
;	out	3
;	in	2
;	sta	KeyLine5
;	mvi	a, 0BFh
;	out	3
;	in	2
;	sta	KeyLine6
	ld a,07Fh
	out (3),A
	in A,(2)
	ld (KeyLine7),A
; Joystick scan
	in A,(6)		; read Joystick-P
KEYINT_J:
	xor 0		; XOR with initial value - mutable param!
	cpl
	ld (JoystickP),A	; save to analyze later

; Scrolling, screen mode, border
	ld a,88h
	out (0),A
	ld a,2
	out (1),A
	ld a,0FFh
	out (3),A		; scrolling
	ld A,(BorderColor)
	and 0Fh
	out (2),A		; screen mode and border
;
	pop af
	ei
	ret

KeyLineEx:	.db 11111111b
KeyLine0:	.db 11111111b
;KeyLine1:	.db 11111111b
;KeyLine5:	.db 11111111b
;KeyLine6:	.db 11111111b
KeyLine7:	.db 11111111b
JoystickP:	.db 11111111b

BorderColor:	.db 0		; border color number 0..15

;----------------------------------------------------------------------------

ColorNone .equ 00000000b
ColorGame .equ 11111110b    ; Color for game
ColorText .equ 10111111b    ; Color for text
ColorBoth .equ 11111111b    ; Color for game and text
; Palette colors, game
PaletteGame:		; Palette
	.db	ColorNone, ColorGame, ColorText, ColorBoth	; 0..3
	.db	ColorNone, ColorGame, ColorText, ColorBoth	; 4..7
	.db	ColorNone, ColorGame, ColorText, ColorBoth	; 8..11
	.db	ColorNone, ColorGame, ColorText, ColorBoth	; 12..15
; Palette colors, title screen
PaletteTitle:
	.db	$00,$30,$5B,$A4,$AD,$36,$F6,$FF
	.db	$00,$30,$5B,$A4,$AD,$36,$F6,$FF

;----------------------------------------------------------------------------

; ZX0 decompressor code by Ivan Gorodetsky
; https://github.com/ivagorRetrocomp/DeZX/blob/main/ZX0/8080/OLD_V1/dzx0_CLASSIC.asm
; input:	de=compressed data start
;		bc=uncompressed destination start
;NOTE: FORWARD decompression only
dzx0:
		ld hl,0FFFFh
		push HL
		inc HL
		ld A,080h
dzx0_literals:
		call dzx0_elias
		call dzx0_ldir
		jp c,dzx0_new_offset
		call dzx0_elias
dzx0_copy:
		ex DE,HL
		ex (SP),HL
		push HL
		add HL,BC
		ex DE,HL
		call dzx0_ldir
		ex DE,HL
		pop HL
		ex (SP),HL
		ex DE,HL
		jp NC,dzx0_literals
dzx0_new_offset:
		call dzx0_elias
		ld H,A
		pop AF
		xor A
		sub L
		ret z
		push HL
		rra
		ld H,A
		ld A,(DE)
		rra
		ld L,A
		inc de
		ex (SP),HL
		ld A,H
		ld HL,1
		call nc,dzx0_elias_backtrack
		inc HL
		jp dzx0_copy
dzx0_elias:
		inc L
dzx0_elias_loop:
		add A,A
		jp NZ,dzx0_elias_skip
		ld A,(de)
		inc DE
		rla
dzx0_elias_skip:
		ret C
dzx0_elias_backtrack:
		add HL,HL
		add A,A
		jp NC,dzx0_elias_loop
		jp dzx0_elias

dzx0_ldir:
		push AF
dzx0_ldir1:
		ld A,(DE)
		ld (BC),A
		inc DE
		inc BC
		dec HL
		ld A,H
		or L
		jp nz,dzx0_ldir1
		pop AF
		add A,A
		ret

;----------------------------------------------------------------------------

Start:
	.end

;----------------------------------------------------------------------------
