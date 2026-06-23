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
; BEEP
; I: H=dlzka,L=vyska
; O: -
; M: AF, BC, DE
Beep:		ld b,0
		ld c,h
		ld d,l
		ld e,l
		dec e
		xor a
BeepA:		out (000h),A
		inc d
		jp NZ,BeepB
		ld d,l
		xor 1
BeepB:		inc e
		jp NZ,BeepC
		ld e,l
		dec e
		xor 1
BeepC:		dec b
		jp NZ,BeepA
		dec c
		jp NZ,BeepA
		out (000h),A
		ret

;------------------------------------------------------------------------------
; Zvuky podla bitov 1, 3, 4, 6 a 7 premennej SndType
Sound:		ld A,(SndType); typ zvuku
		ld c,a
		and 2
		jp Z,SoundA
		ld hl,0FA04h
		ld de,4608h
		jp SoundW

SoundA:		ld hl,SoundI
		ld (HL),0B2h		; instrukcia ORA D
		ld a,c
		and 64
		jp Z,SoundB
		ld c,5
		ld de,0709h
		jp SoundD

SoundB:		ld (HL),0A2h; instrukcia ANA D
		ld a,c
		and 8
		jp Z,SoundC
		ld c,10
		ld de,3F08h
		jp SoundD

SoundC:		ld a,c
		rlca
		jp NC,SoundH
		ld c,2
		ld de,0CC0Ch

SoundD:		ld b,2
		ld l,2
SoundE:		;in	SysPC
SoundF:		xor 4
		push bc
SoundG:		nop;out	SysPC
		dec b
		jp NZ,SoundG
		pop bc
		dec l
		jp NZ,SoundF
		call Rand		; nahodna hodnota do A
		ld h,a
		and c
		inc a
		ld l,a
		ld a,h
SoundI:		and d; ANA D alebo ORA D
		inc a
		ld b,a
		dec e
		jp NZ,SoundE
		jp SoundY

SoundH:		ld a,c
		and 16
		jp Z,SoundY
		ld hl,3205h
		ld de,1E06h

SoundW:		;in	SysPC
		ld c,l
SoundV:		xor 4
		ld b,d
SoundX:		nop;out	SysPC
		dec b
		jp NZ,SoundX
		dec c
		jp NZ,SoundV
		ld a,d
		sub h
		ld d,a
		dec e
		jp NZ,SoundW
SoundY:		;in	SysPC
		and 0F8h
		nop ;out	SysPC
		xor a
		ld (SndType),A
		ret

;------------------------------------------------------------------------------
