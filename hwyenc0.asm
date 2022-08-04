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

;----------------------------------------------------------------------------

	.EXPORT Start
	.EXPORT KeyLineEx, KeyLine0, KeyLine7
	.EXPORT BorderColor, SetPaletteGame

;----------------------------------------------------------------------------

	.org	100h

	di
	xra	a
	out	10h			; turn off the quasi-disk
	lxi	sp,0100h
	lxi	h,0C3F3h
	shld	0
	mov	a,h
	lxi	h,RestartInt
	shld	2
	sta	38h
	lxi	h,KEYINT		; interrupt handler address
	shld	38h+1

; Move encoded block from Start to 8000h, LZSASIZET+LZSASIZE1 bytes
	lxi	d,Start			; source addr
	lxi	b,08000h		; destination addr
	lxi	h,LZSASIZET+LZSASIZE1	; size
	inr	h
Init_1:
	ldax	d
	inx	d
	stax	b
	inx	b
	dcr	l
	jnz	Init_1
	dcr	h
	jnz	Init_1
; Decompress the code and sprites from 08000h+LZSASIZET to Start
	lxi	d,08000h+LZSASIZET	; source addr
	lxi	b,Start			; destination addr
	call	dzx0
; Decompress 24K of the title screen from 8000h to A000h
	lxi	d,08000h		; source addr
	lxi	b,0A000h		; destination addr
	call	dzx0

RestartInt:
	lxi	sp,100h
	mvi	a, 88h
	out	4			; initialize R-Sound 2

; Set palette for the title screen
	lxi	h, PaletteTitle+15
	call	SetPalette
;	ei
	jp	Start

; Set game palette
SetPaletteGame:
	lxi	h, PaletteGame+15
	
; Programming the Palette
SetPalette:
	ei
	hlt
	lxi	d, 100Fh
PaletLoop:
	mov	a, e
	out	2
	mov	a, m
	out	0Ch
	out	0Ch
	out	0Ch
	out	0Ch
	out	0Ch
	dcx	h
	out	0Ch
	dcr	e
	out	0Ch
	dcr	d
	out	0Ch
	jnz	PaletLoop
	ret

;----------------------------------------------------------------------------

KEYINT:
	push	psw
	mvi	a, 8Ah
	out	0
; Keyboard scan
	in	1
	ori	00011111b
	sta	KeyLineEx
	mvi	a, 0FEh
	out	3
	in	2
	sta	KeyLine0
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
	mvi	a, 07Fh
	out	3
	in	2
	sta	KeyLine7
; Scrolling, screen mode, border
	mvi	a, 88h
	out	0
	mvi	a, 2
	out	1
	mvi	a, 0FFh
	out	3		; scrolling
	lda	BorderColor
	ani	0Fh
	out	2		; screen mode and border
;
	pop	psw
	ei
	ret

KeyLineEx:	.db 11111111b
KeyLine0:	.db 11111111b
;KeyLine1:	.db 11111111b
;KeyLine5:	.db 11111111b
;KeyLine6:	.db 11111111b
KeyLine7:	.db 11111111b

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
; input: 	de=compressed data start
;			bc=uncompressed destination start

#ifdef BACKWARD
#define NEXT_HL dcx h
#define NEXT_DE dcx d
#define NEXT_BC dcx b
#else
#define NEXT_HL inx h
#define NEXT_DE inx d
#define NEXT_BC inx b
#endif

dzx0:
#ifdef BACKWARD
		lxi h,1
		push h
		dcr l
#else
		lxi h,0FFFFh
		push h
		inx h
#endif
		mvi a,080h
dzx0_literals:
		call dzx0_elias
		call dzx0_ldir
		jc dzx0_new_offset
		call dzx0_elias
dzx0_copy:
		xchg
		xthl
		push h
		dad b
		xchg
		call dzx0_ldir
		xchg
		pop h
		xthl
		xchg
		jnc dzx0_literals
dzx0_new_offset:
		call dzx0_elias
#ifdef BACKWARD
		inx sp
		inx sp
		dcr h
		rz
		dcr l
		push psw
		mov a,l
#else
		mov h,a
		pop psw
		xra a
		sub l
		rz
		push h
#endif
		rar\ mov h,a
		ldax d
		rar\ mov l,a
		NEXT_DE
#ifdef BACKWARD
		inx h
#endif
		xthl
		mov a,h
		lxi h,1
#ifdef BACKWARD
		cc dzx0_elias_backtrack
#else
		cnc dzx0_elias_backtrack
#endif
		inx h
		jmp dzx0_copy
dzx0_elias:
		inr l
dzx0_elias_loop:	
		add a
		jnz dzx0_elias_skip
		ldax d
		NEXT_DE
		ral
dzx0_elias_skip:
#ifdef BACKWARD
		rnc
#else
		rc
#endif
dzx0_elias_backtrack:
		dad h
		add a
		jnc dzx0_elias_loop
		jmp dzx0_elias

dzx0_ldir:
		push psw
dzx0_ldir1:
		ldax d
		stax b
		NEXT_DE
		NEXT_BC
		dcx h
		mov a,h
		ora l
		jnz dzx0_ldir1
		pop psw
		add a
		ret 

;----------------------------------------------------------------------------

Start:
	.end

;----------------------------------------------------------------------------
