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
; BEEP
; I: H=dlzka,L=vyska
; O: -
; M: AF, BC, DE
Beep:		mvi	b,0
		mov	c,h
		mov	d,l
		mov	e,l
		dcr	e
		xra	a
BeepA:		out	000h
		inr	d
		jnz	BeepB
		mov	d,l
		xri	1
BeepB:		inr	e
		jnz	BeepC
		mov	e,l
		dcr	e
		xri	1
BeepC:		dcr	b
		jnz	BeepA
		dcr	c
		jnz	BeepA
		out	000h
		ret

;------------------------------------------------------------------------------
; Zvuky podla bitov 1, 3, 4, 6 a 7 premennej SndType
Sound:		lda	SndType		; typ zvuku
		mov	c,a
		ani	2
		jz	SoundA
		lxi	h,0FA04h
		lxi	d,4608h
		jmp	SoundW

SoundA:		lxi	h,SoundI
		mvi	m,0B2h		; instrukcia ORA D
		mov	a,c
		ani	64
		jz	SoundB
		mvi	c,5
		lxi	d,0709h
		jmp	SoundD

SoundB:		mvi	m,0A2h		; instrukcia ANA D
		mov	a,c
		ani	8
		jz	SoundC
		mvi	c,10
		lxi	d,3F08h
		jmp	SoundD

SoundC:		mov	a,c
		rlc
		jnc	SoundH
		mvi	c,2
		lxi	d,0CC0Ch

SoundD:		mvi	b,2
		mvi	l,2
SoundE:		;in	SysPC
SoundF:		xri	4
		push	b
SoundG:		nop ;out	SysPC
		dcr	b
		jnz	SoundG
		pop	b
		dcr	l
		jnz	SoundF
		call	Rand		; nahodna hodnota do A
		mov	h,a
		ana	c
		inr	a
		mov	l,a
		mov	a,h
SoundI:		ana	d		; ANA D alebo ORA D
		inr	a
		mov	b,a
		dcr	e
		jnz	SoundE
		jmp	SoundY

SoundH:		mov	a,c
		ani	16
		jz	SoundY
		lxi	h,3205h
		lxi	d,1E06h

SoundW:		;in	SysPC
		mov	c,l
SoundV:		xri	4
		mov	b,d
SoundX:		nop ;out	SysPC
		dcr	b
		jnz	SoundX
		dcr	c
		jnz	SoundV
		mov	a,d
		sub	h
		mov	d,a
		dcr	e
		jnz	SoundW
SoundY:		;in	SysPC
		ani	0F8h
		nop ;out	SysPC
		xra	a
		sta	SndType
		ret

;------------------------------------------------------------------------------
