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
DrawZone:	lxi	d,InnerScr2	; нарисовать сетку в VO2
		mvi	c,VVO-9
		call	DrawGrid

		lxi	d,SVO		; визуализация границ зоны
		lxi	h,InnerScr2+SVO8+22
		mvi	b,40
		call	DrawZoneBord
		lxi	h,InnerScr2+(96*SVO)
		call	DrawZoneBord

		call	DrawLand	; нарисовать область вокруг дорожки

		lda	ZoneNumberT	; для зоны 0
		cpi	1Eh
		cz	DrawZone1Ext
		cpi	1Fh
		cnc	DrawZoneSpec	; рисовать особенности

		lxi	h,InnerScr2
		lxi	d,InnerScr2+(143*SVO)
		mvi	c,VVO-2		; высота сетки -2
		call	DrawBord	; граница по краям экрана зоны

		; нарисовать Зону на VRAM
 		mvi	l,VVO
		lxi	d,InnerScr2
		lxi	b,BaseVramAdr+(256-24)
		call	DrawInnerScr

		; перевести VO2 в VO1
		mvi	l,VVO
		lxi	d,InnerScr2	; копирование VO2 в VO1
		lxi	b,InnerScr
		call	CopyInnerBuf

		jmp	DrawRough	; нарисовать шероховатые поверхности в Zone

;------------------------------------------------------------------------------
; Нанесение границ Зоны
DrawZoneBord:	mvi	b,40
DrawZoneBordA:	mov	a,m
		ori	0C0h
		mov	m,a
		dcr	b
		rz
		dad	d		; next line
DrawZoneBordB:	mov	a,m
		ori	030h
		mov	m,a
		dcr	b
		rz
		dad	d		; next line
		mov	a,m
		ori	00Ch
		mov	m,a
		dcr	b
		rz
		dad	d		; next line
		mov	a,m
		ori	003h
		mov	m,a
		dcr	b
		rz
		inx	h
		dad	d		; next line
		jmp	DrawZoneBordA

;------------------------------------------------------------------------------
; Отрисовка области вокруг трассы.
; Okolie je vyskladane z patternov o velkosti 8x8 bodov a zobrazuje sa
; z hora dolu a zlava do prava.
DrawLand:
		mvi	a,12		; zaciname vyskou 12 patternov
		sta	PattHeight	; nad sebou

		lda	ZoneNumber	; номер зоны
		mvi	h,0		; в HL
		mov	l,a
		dad	h		; x2
		dad	h		; x4
		dad	h		; x8
		dad	h		; x16
		mov	d,h
		mov	e,l
		dad	h		; x32
		dad	d		; x48
		lxi	d,ZoneData-48	; адрес блока с данными зон
		dad	d		; HL=адрес данных текущей зоны
		lxi	d,InnerScr2	; DE=адрес внутреннего экрана
		lxi	b,24		; sirka
DrawLandA:	shld	ZoneDataPtr	; uloz adresu dat zony
		push	b		; odpamataj sirku
		push	d		; odpamataj adresu VO
		push	d		; a este raz
		mov	l,m		; byte dat zony do HL
		mov	h,b
		dad	h		; x2
		dad	h		; x4
		mov	d,h
		mov	e,l
		dad	h		; x8
		dad	d		; x12
		lxi	d,PattSeq+12	; находим последовательность паттернов
		dad	d
		lda	PattHeight	; высота последовательности
		mov	c,a		; в C
		cma
		mov	e,a		; a do DE jej negovanu hodnotu
		mvi	d,255
		inx	d
		dad	d		; odpocitaj aktualnu vysku
DrawLandB:	shld	PattSeqPtr	; uloz ukazatel na patterny
		mov	l,m		; kod znaku do HL
		mov	h,b
		dad	h		; x2
		dad	h		; x4
		dad	h		; x8
		lxi	d,Patts		; pripocitaj adresu patternov
		dad	d
		xchg			; DE=адрес паттерна
		pop	h		; HL=адрес назначения vo VO2
		call	DrawLandZ	; нарисовать паттерн
		push	h
		lhld	PattSeqPtr	; ukazatel na patterny do HL
		inx	h		; posun na dalsi
		dcr	c		; повторяем по всей высоте
		jnz	DrawLandB
		pop	d
		pop	d
		inx	d		; следующий столбец
		pop	b		; obnov pocitadlo sirky
		mov	a,c
		rrc
		jnc	DrawLandD
		lda	PattHeight	; после каждого второго столбца
		dcr	a		; уменьшаем высоту последовательности
		sta	PattHeight
DrawLandD:	lhld	ZoneDataPtr	; ukazatel na data zony
		inx	h		; posun na dalsi byte
		dcr	c		; opakuj pre celu sirku
		jnz	DrawLandA

		mvi	a,1		; zaciname vyskou 1 pattern
		sta	PattHeight	; na vysku

		lxi	d,InnerScr2+(136*SVO)+8 ; DE=adresa vn. obr.
		mvi	c,24		; sirka
DrawLandE:	shld	ZoneDataPtr	; uloz adresu dat zony
		push	b		; odpamataj sirku
		push	d		; odpamataj adresu VO
		push	d		; a este raz
		mov	l,m		; byte dat zony do HL
		mov	h,b
		dad	h		; x2
		dad	h		; x4
		mov	d,h
		mov	e,l
		dad	h		; x8
		dad	d		; x12
		lxi	d,PattSeq	; najdi sekvenciu patternov
		dad	d
		lda	PattHeight	; высота последовательности
		mov	c,a		; do C
DrawLandF:	shld	PattSeqPtr	; uloz ukazatel na patterny
		mov	l,m		; kod znaku do HL
		mov	h,b
		dad	h		; x2
		dad	h		; x4
		dad	h		; x8
		lxi	d,Patts		; pripocitaj adresu patternov
		dad	d
		xchg			; DE=predloha patternu
		pop	h		; HL=адрес назначения vo VO2
		call	DrawLandZ	; нарисовать паттерн
		push	h
		lhld	PattSeqPtr	; ukazatel na patterny do HL
		inx	h		; posun na dalsi
		dcr	c		; opakuj pre celu vysku
		jnz	DrawLandF
		pop	d
		pop	d
		inx	d		; следующий столбец
		pop	b		; obnov pocitadlo sirky
		mov	a,c
		rrc
		jnc	DrawLandH
		lxi	h,-SVO8		; po kazdom druhom stlpci
		dad	d		; sa posun vo VO2 o riadok vyssie
		xchg
		lxi	h,PattHeight
		inr	m		; a zvys vysku sekvencie
DrawLandH:	lhld	ZoneDataPtr	; ukazatel na data zony
		inx	h		; posun na dalsi byte
		dcr	c		; opakuj pre celu sirku
		jnz	DrawLandE

		ret

;------------------------------------------------------------------------------
; Отрисовка одной колонки паттерна
; I: DE=адрес паттерна, HL=адрес во внутреннем экране
DrawLandZ:	push	b
		mvi	b,8		; высота паттерна
DrawLandZ1:	ldax	d
		inx	d
		mov	m,a
		mov	a,l
		adi	SVO
		mov	l,a
		mvi	a,0
		adc	h
		mov	h,a
		dcr	b
		jnz	DrawLandZ1
		pop	b
		ret

;------------------------------------------------------------------------------
; Визуализация "существа" в Зоне 1, куда должен прибыть Лазертрон.
DrawZone1Ext:	lxi	h,InnerScr2+SVO8+40 ; adresa vo VO2 kam sa vykresli stvorcek
		lxi	d,Grid+4	; adresa dat mriezky
		mvi	c,8		; высота 8
DrawZone1ExtA:	ldax	d
		mov	m,a
		inx	d
		inx	h
		ldax	d
		mov	m,a
		inx	d
		inx	h
		ldax	d
		ani	0Fh
		mov	b,a
		mov	a,m
		ani	30h
		ora	b
		mov	m,a
		mvi	a,6
		add	e
		mov	e,a
		mov	a,c
		lxi	b,SVO-2
		dad	b
		mov	c,a
		dcr	c
		jnz	DrawZone1ExtA
		mvi	a,1Eh
		ret

;------------------------------------------------------------------------------
DrawZoneSpec:	lda	ZoneNumberT	; cislo zony
		sui	1Fh		; odpocitaj zaklad pre Zonu 0
		cpi	6		; "sub zona" v rozsahu <0, 5> ?
		jc	DrawZoneSpecA	; ano, skoc dalej
		mvi	a,1		; inak nastav "sub zonu" 1
DrawZoneSpecA:	add	a		; *2
		add	a		; *4
		mov	c,a		; uloz do BC
		mvi	b,0
		lxi	h,DrawZoneSpecB	; adresa skokovych vektorov
		dad	b		; pripocitaj offset
		pchl			; a nepriamo skoc do rutiny

;------------------------------------------------------------------------------
DrawZoneSpecB:	jp	DrawSubZone0	; SubZona 0
		nop

		jp	DrawSubZone1	; SubZona 1
		nop

		jp	DrawSubZone2	; SubZona 2
		nop

		jp	DrawSubZone3	; SubZona 3
		nop

		jp	DrawSubZone4	; SubZona 4
		nop

		jp	DrawSubZone5	; SubZona 5

;------------------------------------------------------------------------------
; Визуализация "квадрата" в Зоне 0, куда должен прибыть Лазертрон.
DrawSubZone0:	lxi	h,InnerScr2+(12*SVO8)+10 ; adresa vo VO2 kam sa vykresli stvorcek
		lxi	d,Grid+6	; adresa dat mriezky
		mvi	c,8		; vyska 8
DrawSubZone0A:	ldax	d
		ani	30h
		mov	b,a
		mov	a,m
		ani	0Fh
		ora	b
		mov	m,a
		inx	d
		inx	h
		ldax	d
		mov	m,a
		inx	h
		mvi	a,-7
		add	e
		mov	e,a
		ldax	d
		mov	m,a
		inx	d
		inx	h
		ldax	d
		ani	03h
		mov	b,a
		mov	a,m
		ani	3Ch
		ora	b
		mov	m,a
		mvi	a,13
		add	e
		mov	e,a
		mov	a,c
		lxi	b,SVO-3
		dad	b
		mov	c,a
		dcr	c
		jnz	DrawSubZone0A
		ret

;------------------------------------------------------------------------------
; Не рисуем здесь особенностей.
DrawSubZone1:	ret

;------------------------------------------------------------------------------
; Рисунок группы спрайтов Циклопа на левой и правой стороне дорожки.
DrawSubZone2:	lxi	h,DrawSZSprS2	; adresa instrukcie JZ d pre vykonanie
		mvi	m,0CAh		; kontroly poctu spritov v skupine
		lxi	b,InnerScr2+SVO8 ; adresa VO
		lxi	d,9*256+(1*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		lxi	h,4		; offset upravy adresy VO
		shld	SubZoneOffVO
		mvi	a,4		; inkrement poctu spritov v skupine
		sta	SubZoneIncCnt
		call	DrawSZSprS	; vykresli sprity
		lxi	h,DrawSZSprN2+1 ; nastav hranice pre kontrolu poctu
		mvi	m,10		; spritov v skupine
		lxi	h,DrawSZSprN3+1
		mvi	m,20
		lxi	b,InnerScr2+(40*SVO)+40 ; adresa VO
		lxi	d,(10*256)+(14*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		lxi	h,12*SVO	; offset upravy adresy VO
		shld	SubZoneOffVO
		mvi	a,-2		; inkrement poctu spritov v skupine
		sta	SubZoneIncCnt
		jmp	DrawSZSprN	; vykresli sprity

;------------------------------------------------------------------------------
; Рисунок группы спрайтов Циклопа на левой и правой стороне дорожки.
DrawSubZone3:	lxi	h,DrawSZSprS2	; adresa instrukcie JR d pre vynechanie
		mvi	m,0C3h		; kontroly poctu spritov v skupine
		lxi	b,InnerScr2+SVO8 ; adresa VO
		lxi	d,9*256+(1*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		lxi	h,4		; offset upravy adresy VO
		shld	SubZoneOffVO
		mvi	a,4		; inkrement poctu spritov v skupine
		sta	SubZoneIncCnt
		call	DrawSZSprS	; vykresli sprity
		lxi	h,DrawSZSprN2+1	; nastav hranice pre kontrolu poctu
		mvi	m,-1
		lxi	h,DrawSZSprN3+1
		mvi	m,-1
		lxi	b,InnerScr2+(40*SVO)+40 ; adresa VO
		lxi	d,(10*256)+(20*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		lxi	h,(12*SVO)	; offset upravy adresy VO
		shld	SubZoneOffVO
		mvi	a,-2		; inkrement poctu spritov v skupine
		sta	SubZoneIncCnt
		jmp	DrawSZSprN	; vykresli sprity

;------------------------------------------------------------------------------
; Рисунок группы спрайтов Циклопа на левой и правой стороне дорожки.
DrawSubZone4:	lxi	b,InnerScr2+(16*SVO)+5 ; adresa VO
		lxi	d,7*256+(4*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		lxi	h,12*SVO	; offset upravy adresy VO
		shld	SubZoneOffVO
		xra	a		; inkrement poctu spritov v skupine
		sta	SubZoneIncCnt
		call	DrawSZSprS	; vykresli sprity
		lxi	b,InnerScr2+(112*SVO)+16 ; adresa VO
		lxi	d,7*256+(8*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		lxi	h,4		; offset upravy adresy VO
		shld	SubZoneOffVO
		mvi	a,2		; inkrement poctu spritov v skupine
		sta	SubZoneIncCnt
		jmp	DrawSZSprN	; vykresli sprity

;------------------------------------------------------------------------------
; Рисуем космический корабль.
DrawSubZone5:	lxi	h,SpacecraftAW	; adresa ukazatelov do VO1 a sirky
		push	h		; uloz na zasobnik
	#if UsePackedGrp
		lxi	h,Spacecraft	; rozpakovanie Kozmickej lode
		lxi	d,InnerScr2-SpacecraftSize
		call	dzx7
		lxi	h,InnerScr2-SpacecraftSize ; adresa dat Kozmickej lode
	#else
		lxi	h,Spacecraft	; adresa dat Kozmickej lode
	#endif
		mvi	a,11		; 11 znakovych riadkov
DrawSubZone5A:	sta	DrawSubZone5R+1	; uloz pocitadlo
		xthl			; adresa tabulky do HL
		mov	e,m		; адрес назначения VO1 do DE
		inx	h
		mov	d,m
		inx	h
		mov	a,m		; sirka daneho znakoveho riadku do B
		sta	DrawSubZone5B+1
		inx	h
		xthl
		mvi	c,8		; vyska znakoveho riadku do
DrawSubZone5B:	mvi	b,1		; sirka znakoveho riadku
		push	d		; odpamataj cielovu adresu
DrawSubZone5C:	mov	a,m		; prekopiruj jeden riadok dat
		stax	d
		inx	h
		inx	d
		dcr	b
		jnz	DrawSubZone5C
		pop	d		; obnov povodnu adresu VO1
		xchg
		mov	a,c		; posun sa nadalsi mikroriadok vo VO1
		mvi	c,SVO
		dad	b
		mov	c,a
		xchg
		dcr	c
		jnz	DrawSubZone5B
DrawSubZone5R:	mvi	a,1
		dcr	a		; opakuj pre celu vysku zn. riadku
		jnz	DrawSubZone5A
		pop	h
		ret

;------------------------------------------------------------------------------
; Адреса в VO2 и совпадения "блоков" графики, из которых состоит космический корабль.
SpacecraftAW:	.dw	InnerScr2+(0*SVO8)+20	; row	0  col	26  wdt	17	43
		.db	12
		.dw	InnerScr2+(1*SVO8)+19	; 	1	26	17	43
		.db	13
		.dw	InnerScr2+(2*SVO8)+15	;	2	19	24	43
		.db	17
		.dw	InnerScr2+(3*SVO8)+14	;	3	19	24	43
		.db	18
		.dw	InnerScr2+(4*SVO8)+11	;	4	15	28	43
		.db	21
		.dw	InnerScr2+(5*SVO8)+11	;	5	15	28	43
		.db	21
		.dw	InnerScr2+(6*SVO8)+11	;	6	15	28	43
		.db	21
		.dw	InnerScr2+(7*SVO8)+11	;	7	14	29	43
		.db	21
		.dw	InnerScr2+(8*SVO8)+11	;	8	14	26	40
		.db	19
		.dw	InnerScr2+(9*SVO8)+11	;	9	14	23	38
		.db	17
		.dw	InnerScr2+(10*SVO8)+12	;	10	16	11	27
		.db	8

;------------------------------------------------------------------------------
; Отрисовка групп спрайтов SprCyclopS.
; I: BC=adresa VO, D=pocet skupin spritov, E=pocet spritov v skupine
DrawSZSprS:
M256S10:	lxi	h,SprCyclopS	; adresa spritu SprCyclopS
		shld	SubZoneSprAdr	; uloz na neskor
DrawSZSprS1:	push	b		; odpamataj adresu VO
		push	d		; odpamataj pocitadla
		call	DrawSZGrpSpr	; vykresli skupinu spritov
		pop	d		; obnov pocitadla
		pop	b		; obnov adresu VO
		lhld	SubZoneOffVO	; offset adresy VO
		dad	b		; posun adresu VO
		mov	b,h		; a uloz opat do VO
		mov	c,l
		mov	h,a		; nahodna hodnota do H
		lda	SubZoneIncCnt	; inkrement poctu spritov v skupine
		add	e		; pripocitaj
		mov	e,a		; a uloz do E novy pocet
		mov	a,e
		ani	32		; pocet spritov prekrocil 31?
DrawSZSprS2:	jz	DrawSZSprS3	; nie, preskoc
		mvi	e,30		; na stav pocet na 30
DrawSZSprS3:	dcr	d		; zniz pocitadlo skupin
		jnz	DrawSZSprS1	; opakuj
		ret

;------------------------------------------------------------------------------
; Отрисовка групп спрайтов SprCyclopN.
; I: BC=adresa VO, D=pocet skupin spritov, E=pocet spritov v skupine
DrawSZSprN:
M256S11:	lxi	h,SprCyclopN	; adresa spritu SprCyclopN
		shld	SubZoneSprAdr	; uloz na neskor
DrawSZSprN1:	push	b		; odpamataj adresu VO
		push	d		; odpamataj pocitadla
		call	DrawSZGrpSpr	; vykresli skupinu spritov
		pop	d		; obnov pocitadla
		pop	b		; obnov adresu VO
		lhld	SubZoneOffVO	; offset adresy VO
		dad	b		; posun adresu VO
		mov	b,h		; a uloz opat do VO
		mov	c,l
		mov	h,a		; nahodna hodnota do H
		mov	a,d		; aktualna hodnota poctu skupin spritov
DrawSZSprN2:	cpi	10		; ak je to 10 alebo -1
		jz	DrawSZSprN4	; preskoc zmenu poctu pritov v skupine
		lda	SubZoneIncCnt	; inkrement poctu spritov v skupine
		add	e		; pripocitaj
		mov	e,a		; a uloz do E novy pocet
DrawSZSprN3:	cpi	6		; ak je pocet mensi ako 20 alebo 255
		jnc	DrawSZSprN4	; preskoc zmenu poctu pritov v skupine
		dcr	e		; zniz pocet spritov v skupine o 2
		dcr	e
DrawSZSprN4:	dcr	d		; zniz pocitadlo skupin
		jnz	DrawSZSprN1	; opakuj
		ret

;------------------------------------------------------------------------------
; Отрисовка группы спрайтов.
; I: BC=pociatocna адрес назначения VO, E=pocitadlo, H=nahodna hodnota
DrawSZGrpSpr:	mov	a,e		; ak je pocitadlo neparne
		rrc
		jc	DrawSZGrpSprB	; preskoc vykreslenie
		mov	a,h		; nahodna hodnota do A
		cpi	3Ch		; ak je hodnota <3Ch
		jc	DrawSZGrpSprB	; preskoc vykreslenie
		push	d		; odpamataj pocitadlo
		push	b		; odpamataj adresu VO
		lhld	SubZoneSprAdr	; adresa spritu do DE
		xchg
		mov	l,c
		mov	h,b
M256R0F:	call	DrawSprite0	; vykreslenie spritu narotovaneho o 2 body dolava
		pop	b		; obnov cielovu adresu VO
		pop	d		; obnov pocitadlo
DrawSZGrpSprB:	lxi	h,3*SVO		; posun sa vo VO o 3 mikroriadky nizsie
		dad	b
		mov	c,l		; novu adresu opat do BC
		mov	b,h
		dcx	b
		call	Rand		; nahodna hodnota
		mov	h,a		;  do H
		dcr	e		; zniz pocitadlo
		jnz	DrawSZGrpSpr	; a opakuj
		ret

;------------------------------------------------------------------------------
