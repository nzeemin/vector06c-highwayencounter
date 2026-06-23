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
DrawZone:	ld de,InnerScr2; нарисовать сетку в VO2
		ld c,VVO-9
		call DrawGrid

		ld de,SVO		; визуализация границ зоны
		ld hl,InnerScr2+SVO8+22
		ld b,40
		call DrawZoneBord
		ld hl,InnerScr2+(96*SVO)
		call DrawZoneBord

		call DrawLand	; нарисовать область вокруг дорожки

		ld A,(ZoneNumberT)	; для зоны 0
		cp 1Eh
		call Z,DrawZone1Ext
		cp 1Fh
		call NC,DrawZoneSpec	; рисовать особенности

		ld hl,InnerScr2
		ld de,InnerScr2+(143*SVO)
		ld c,VVO-2		; высота сетки -2
		call DrawBord	; граница по краям экрана зоны

		; нарисовать Зону на VRAM
 		ld l,VVO
		ld de,InnerScr2
		ld bc,GameVramAdr
		call DrawInnerScr

		; перевести VO2 в VO1
		ld l,VVO
		ld de,InnerScr2	; копирование VO2 в VO1
		ld bc,InnerScr
		call CopyInnerBuf

		jp DrawRough	; нарисовать шероховатые поверхности в Zone

;------------------------------------------------------------------------------
; Нанесение границ Зоны
DrawZoneBord:	ld b,40
DrawZoneBordA:	ld a,(HL)
		or 0C0h
		ld (HL),a
		dec b
		ret Z
		add HL,de		; next line
DrawZoneBordB:	ld a,(HL)
		or 030h
		ld (HL),a
		dec b
		ret Z
		add HL,de		; next line
		ld a,(HL)
		or 00Ch
		ld (HL),a
		dec b
		ret Z
		add HL,de		; next line
		ld a,(HL)
		or 003h
		ld (HL),a
		dec b
		ret Z
		inc hl
		add HL,de		; next line
		jp DrawZoneBordA

;------------------------------------------------------------------------------
; Отрисовка области вокруг трассы.
; Okolie je vyskladane z patternov o velkosti 8x8 bodov a zobrazuje sa
; z hora dolu a zlava do prava.
DrawLand:
		ld a,12		; zaciname vyskou 12 patternov
		ld (PattHeight),A	; nad sebou

		ld A,(ZoneNumber)	; номер зоны
		ld h,0		; в HL
		ld l,a
		add HL,hl		; x2
		add HL,hl		; x4
		add HL,hl		; x8
		add HL,hl		; x16
		ld d,h
		ld e,l
		add HL,hl		; x32
		add HL,de		; x48
		ld de,ZoneData-48	; адрес блока с данными зон
		add HL,de		; HL=адрес данных текущей зоны
		ld de,InnerScr2	; DE=адрес внутреннего экрана
		ld bc,24		; sirka
DrawLandA:	ld (ZoneDataPtr),HL; uloz adresu dat zony
		push bc		; odpamataj sirku
		push de		; odpamataj adresu VO
		push de		; a este raz
		ld l,(HL)		; byte dat zony do HL
		ld h,b
		add HL,hl		; x2
		add HL,hl		; x4
		ld d,h
		ld e,l
		add HL,hl		; x8
		add HL,de		; x12
		ld de,PattSeq+12	; находим последовательность паттернов
		add HL,de
		ld A,(PattHeight)	; высота последовательности
		ld c,a		; в C
		cpl
		ld e,a		; a do DE jej negovanu hodnotu
		ld d,255
		inc de
		add HL,de		; odpocitaj aktualnu vysku
DrawLandB:	ld (PattSeqPtr),HL; uloz ukazatel na patterny
		ld l,(HL)		; kod znaku do HL
		ld h,b
		add HL,hl		; x2
		add HL,hl		; x4
		add HL,hl		; x8
		ld de,Patts		; pripocitaj adresu patternov
		add HL,de
		ex DE,HL			; DE=адрес паттерна
		pop hl		; HL=адрес назначения vo VO2
		call DrawLandZ	; нарисовать паттерн
		push hl
		ld HL,(PattSeqPtr)	; ukazatel na patterny do HL
		inc hl		; posun na dalsi
		dec c		; повторяем по всей высоте
		jp NZ,DrawLandB
		pop de
		pop de
		inc de		; следующий столбец
		pop bc		; obnov pocitadlo sirky
		ld a,c
		rrca
		jp NC,DrawLandD
		ld A,(PattHeight)	; после каждого второго столбца
		dec a		; уменьшаем высоту последовательности
		ld (PattHeight),A
DrawLandD:	ld HL,(ZoneDataPtr); ukazatel na data zony
		inc hl		; posun na dalsi byte
		dec c		; opakuj pre celu sirku
		jp NZ,DrawLandA

		ld a,1		; zaciname vyskou 1 pattern
		ld (PattHeight),A	; na vysku

		ld de,InnerScr2+(136*SVO)+8 ; DE=adresa vn. obr.
		ld c,24		; sirka
DrawLandE:	ld (ZoneDataPtr),HL; uloz adresu dat zony
		push bc		; odpamataj sirku
		push de		; odpamataj adresu VO
		push de		; a este raz
		ld l,(HL)		; byte dat zony do HL
		ld h,b
		add HL,hl		; x2
		add HL,hl		; x4
		ld d,h
		ld e,l
		add HL,hl		; x8
		add HL,de		; x12
		ld de,PattSeq	; najdi sekvenciu patternov
		add HL,de
		ld A,(PattHeight)	; высота последовательности
		ld c,a		; do C
DrawLandF:	ld (PattSeqPtr),HL; uloz ukazatel na patterny
		ld l,(HL)		; kod znaku do HL
		ld h,b
		add HL,hl		; x2
		add HL,hl		; x4
		add HL,hl		; x8
		ld de,Patts		; pripocitaj adresu patternov
		add HL,de
		ex DE,HL			; DE=predloha patternu
		pop hl		; HL=адрес назначения vo VO2
		call DrawLandZ	; нарисовать паттерн
		push hl
		ld HL,(PattSeqPtr)	; ukazatel na patterny do HL
		inc hl		; posun na dalsi
		dec c		; opakuj pre celu vysku
		jp NZ,DrawLandF
		pop de
		pop de
		inc de		; следующий столбец
		pop bc		; obnov pocitadlo sirky
		ld a,c
		rrca
		jp NC,DrawLandH
		ld hl,-SVO8		; po kazdom druhom stlpci
		add HL,de		; sa posun vo VO2 o riadok vyssie
		ex DE,HL
		ld hl,PattHeight
		inc (HL)		; a zvys vysku sekvencie
DrawLandH:	ld HL,(ZoneDataPtr); ukazatel na data zony
		inc hl		; posun na dalsi byte
		dec c		; opakuj pre celu sirku
		jp NZ,DrawLandE

		ret

;------------------------------------------------------------------------------
; Отрисовка одной колонки паттерна
; I: DE=адрес паттерна, HL=адрес во внутреннем экране
DrawLandZ:	push bc
		ld b,8		; высота паттерна
DrawLandZ1:	ld A,(de)
		inc de
		ld (HL),a
		ld a,l
		add A,SVO
		ld l,a
		ld a,0
		adc A,h
		ld h,a
		dec b
		jp NZ,DrawLandZ1
		pop bc
		ret

;------------------------------------------------------------------------------
; Визуализация "существа" в Зоне 1, куда должен прибыть Лазертрон.
DrawZone1Ext:	ld hl,InnerScr2+SVO8+40; adresa vo VO2 kam sa vykresli stvorcek
		ld de,Grid+4	; adresa dat mriezky
		ld c,8		; высота 8
DrawZone1ExtA:	ld A,(de)
		ld (HL),a
		inc de
		inc hl
		ld A,(de)
		ld (HL),a
		inc de
		inc hl
		ld A,(de)
		and 0Fh
		ld b,a
		ld a,(HL)
		and 30h
		or b
		ld (HL),a
		ld a,6
		add A,e
		ld e,a
		ld a,c
		ld bc,SVO-2
		add HL,bc
		ld c,a
		dec c
		jp NZ,DrawZone1ExtA
		ld a,1Eh
		ret

;------------------------------------------------------------------------------
DrawZoneSpec:	ld A,(ZoneNumberT); cislo zony
		sub 1Fh		; odpocitaj zaklad pre Zonu 0
		cp 6		; "sub zona" v rozsahu <0, 5> ?
		jp C,DrawZoneSpecA	; ano, skoc dalej
		ld a,1		; inak nastav "sub zonu" 1
DrawZoneSpecA:	add A,a; *2
		add A,a		; *4
		ld c,a		; uloz do BC
		ld b,0
		ld hl,DrawZoneSpecB	; adresa skokovych vektorov
		add HL,bc		; pripocitaj offset
		jp (HL)			; a nepriamo skoc do rutiny

;------------------------------------------------------------------------------
DrawZoneSpecB:	jp P,DrawSubZone0; SubZona 0
		nop

		jp P,DrawSubZone1	; SubZona 1
		nop

		jp P,DrawSubZone2	; SubZona 2
		nop

		jp P,DrawSubZone3	; SubZona 3
		nop

		jp P,DrawSubZone4	; SubZona 4
		nop

		jp P,DrawSubZone5	; SubZona 5

;------------------------------------------------------------------------------
; Визуализация "квадрата" в Зоне 0, куда должен прибыть Лазертрон.
DrawSubZone0:	ld hl,InnerScr2+(12*SVO8)+10; adresa vo VO2 kam sa vykresli stvorcek
		ld de,Grid+6	; adresa dat mriezky
		ld c,8		; vyska 8
DrawSubZone0A:	ld A,(de)
		and 30h
		ld b,a
		ld a,(HL)
		and 0Fh
		or b
		ld (HL),a
		inc de
		inc hl
		ld A,(de)
		ld (HL),a
		inc hl
		ld a,-7
		add A,e
		ld e,a
		ld A,(de)
		ld (HL),a
		inc de
		inc hl
		ld A,(de)
		and 03h
		ld b,a
		ld a,(HL)
		and 3Ch
		or b
		ld (HL),a
		ld a,13
		add A,e
		ld e,a
		ld a,c
		ld bc,SVO-3
		add HL,bc
		ld c,a
		dec c
		jp NZ,DrawSubZone0A
		ret

;------------------------------------------------------------------------------
; Не рисуем здесь особенностей.
DrawSubZone1:	ret

;------------------------------------------------------------------------------
; Рисунок группы спрайтов Циклопа на левой и правой стороне дорожки.
DrawSubZone2:	ld hl,DrawSZSprS2; adresa instrukcie JZ d pre vykonanie
		ld (HL),0CAh		; kontroly poctu spritov v skupine
		ld bc,InnerScr2+SVO8 ; adresa VO
		ld de,9*256+(1*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		ld hl,4		; offset upravy adresy VO
		ld (SubZoneOffVO),HL
		ld a,4		; inkrement poctu spritov v skupine
		ld (SubZoneIncCnt),A
		call DrawSZSprS	; vykresli sprity
		ld hl,DrawSZSprN2+1 ; nastav hranice pre kontrolu poctu
		ld (HL),10		; spritov v skupine
		ld hl,DrawSZSprN3+1
		ld (HL),20
		ld bc,InnerScr2+(40*SVO)+40 ; adresa VO
		ld de,(10*256)+(14*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		ld hl,12*SVO	; offset upravy adresy VO
		ld (SubZoneOffVO),HL
		ld a,-2		; inkrement poctu spritov v skupine
		ld (SubZoneIncCnt),A
		jp DrawSZSprN	; vykresli sprity

;------------------------------------------------------------------------------
; Рисунок группы спрайтов Циклопа на левой и правой стороне дорожки.
DrawSubZone3:	ld hl,DrawSZSprS2; adresa instrukcie JR d pre vynechanie
		ld (HL),0C3h		; kontroly poctu spritov v skupine
		ld bc,InnerScr2+SVO8 ; adresa VO
		ld de,9*256+(1*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		ld hl,4		; offset upravy adresy VO
		ld (SubZoneOffVO),HL
		ld a,4		; inkrement poctu spritov v skupine
		ld (SubZoneIncCnt),A
		call DrawSZSprS	; vykresli sprity
		ld hl,DrawSZSprN2+1	; nastav hranice pre kontrolu poctu
		ld (HL),-1
		ld hl,DrawSZSprN3+1
		ld (HL),-1
		ld bc,InnerScr2+(40*SVO)+40 ; adresa VO
		ld de,(10*256)+(20*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		ld hl,12*SVO	; offset upravy adresy VO
		ld (SubZoneOffVO),HL
		ld a,-2		; inkrement poctu spritov v skupine
		ld (SubZoneIncCnt),A
		jp DrawSZSprN	; vykresli sprity

;------------------------------------------------------------------------------
; Рисунок группы спрайтов Циклопа на левой и правой стороне дорожки.
DrawSubZone4:	ld bc,InnerScr2+(16*SVO)+5; adresa VO
		ld de,7*256+(4*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		ld hl,12*SVO	; offset upravy adresy VO
		ld (SubZoneOffVO),HL
		xor a		; inkrement poctu spritov v skupine
		ld (SubZoneIncCnt),A
		call DrawSZSprS	; vykresli sprity
		ld bc,InnerScr2+(112*SVO)+16 ; adresa VO
		ld de,7*256+(8*2)	; pociatocny pocet spritov v skupine
					; pocet skupin
		ld hl,4		; offset upravy adresy VO
		ld (SubZoneOffVO),HL
		ld a,2		; inkrement poctu spritov v skupine
		ld (SubZoneIncCnt),A
		jp DrawSZSprN	; vykresli sprity

;------------------------------------------------------------------------------
; Рисуем космический корабль.
DrawSubZone5:	ld hl,SpacecraftAW; adresa ukazatelov do VO1 a sirky
		push hl		; uloz na zasobnik
	if UsePackedGrp
		ld hl,Spacecraft	; rozpakovanie Kozmickej lode
		ld de,InnerScr2-SpacecraftSize
		call dzx7
		ld hl,InnerScr2-SpacecraftSize ; adresa dat Kozmickej lode
	else
		ld hl,Spacecraft	; adresa dat Kozmickej lode
	endif
		ld a,11		; 11 znakovych riadkov
DrawSubZone5A:	ld (DrawSubZone5R+1),A; uloz pocitadlo
		ex (SP),HL			; adresa tabulky do HL
		ld e,(HL)		; адрес назначения VO1 do DE
		inc hl
		ld d,(HL)
		inc hl
		ld a,(HL)		; sirka daneho znakoveho riadku do B
		ld (DrawSubZone5B+1),A
		inc hl
		ex (SP),HL
		ld c,8		; vyska znakoveho riadku do
DrawSubZone5B:	ld b,1; sirka znakoveho riadku
		push de		; odpamataj cielovu adresu
DrawSubZone5C:	ld a,(HL); prekopiruj jeden riadok dat
		ld (de),A
		inc hl
		inc de
		dec b
		jp NZ,DrawSubZone5C
		pop de		; obnov povodnu adresu VO1
		ex DE,HL
		ld a,c		; posun sa nadalsi mikroriadok vo VO1
		ld c,SVO
		add HL,bc
		ld c,a
		ex DE,HL
		dec c
		jp NZ,DrawSubZone5B
DrawSubZone5R:	ld a,1
		dec a		; opakuj pre celu vysku zn. riadku
		jp NZ,DrawSubZone5A
		pop hl
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
M256S10:	ld hl,SprCyclopS; adresa spritu SprCyclopS
		ld (SubZoneSprAdr),HL	; uloz na neskor
DrawSZSprS1:	push bc; odpamataj adresu VO
		push de		; odpamataj pocitadla
		call DrawSZGrpSpr	; vykresli skupinu spritov
		pop de		; obnov pocitadla
		pop bc		; obnov adresu VO
		ld HL,(SubZoneOffVO)	; offset adresy VO
		add HL,bc		; posun adresu VO
		ld b,h		; a uloz opat do VO
		ld c,l
		ld h,a		; nahodna hodnota do H
		ld A,(SubZoneIncCnt)	; inkrement poctu spritov v skupine
		add A,e		; pripocitaj
		ld e,a		; a uloz do E novy pocet
		ld a,e
		and 32		; pocet spritov prekrocil 31?
DrawSZSprS2:	jp Z,DrawSZSprS3; nie, preskoc
		ld e,30		; na stav pocet na 30
DrawSZSprS3:	dec d; zniz pocitadlo skupin
		jp NZ,DrawSZSprS1	; opakuj
		ret

;------------------------------------------------------------------------------
; Отрисовка групп спрайтов SprCyclopN.
; I: BC=adresa VO, D=pocet skupin spritov, E=pocet spritov v skupine
DrawSZSprN:
M256S11:	ld hl,SprCyclopN; adresa spritu SprCyclopN
		ld (SubZoneSprAdr),HL	; uloz na neskor
DrawSZSprN1:	push bc; odpamataj adresu VO
		push de		; odpamataj pocitadla
		call DrawSZGrpSpr	; vykresli skupinu spritov
		pop de		; obnov pocitadla
		pop bc		; obnov adresu VO
		ld HL,(SubZoneOffVO)	; offset adresy VO
		add HL,bc		; posun adresu VO
		ld b,h		; a uloz opat do VO
		ld c,l
		ld h,a		; nahodna hodnota do H
		ld a,d		; aktualna hodnota poctu skupin spritov
DrawSZSprN2:	cp 10; ak je to 10 alebo -1
		jp Z,DrawSZSprN4	; preskoc zmenu poctu pritov v skupine
		ld A,(SubZoneIncCnt)	; inkrement poctu spritov v skupine
		add A,e		; pripocitaj
		ld e,a		; a uloz do E novy pocet
DrawSZSprN3:	cp 6; ak je pocet mensi ako 20 alebo 255
		jp NC,DrawSZSprN4	; preskoc zmenu poctu pritov v skupine
		dec e		; zniz pocet spritov v skupine o 2
		dec e
DrawSZSprN4:	dec d; zniz pocitadlo skupin
		jp NZ,DrawSZSprN1	; opakuj
		ret

;------------------------------------------------------------------------------
; Отрисовка группы спрайтов.
; I: BC=pociatocna адрес назначения VO, E=pocitadlo, H=nahodna hodnota
DrawSZGrpSpr:	ld a,e; ak je pocitadlo neparne
		rrca
		jp C,DrawSZGrpSprB	; preskoc vykreslenie
		ld a,h		; nahodna hodnota do A
		cp 3Ch		; ak je hodnota <3Ch
		jp C,DrawSZGrpSprB	; preskoc vykreslenie
		push de		; odpamataj pocitadlo
		push bc		; odpamataj adresu VO
		ld HL,(SubZoneSprAdr)	; adresa spritu do DE
		ex DE,HL
		ld l,c
		ld h,b
M256R0F:	call DrawSprite0; vykreslenie spritu narotovaneho o 2 body dolava
		pop bc		; obnov cielovu adresu VO
		pop de		; obnov pocitadlo
DrawSZGrpSprB:	ld hl,3*SVO; posun sa vo VO o 3 mikroriadky nizsie
		add HL,bc
		ld c,l		; novu adresu opat do BC
		ld b,h
		dec bc
		call Rand		; nahodna hodnota
		ld h,a		;  do H
		dec e		; zniz pocitadlo
		jp NZ,DrawSZGrpSpr	; a opakuj
		ret

;------------------------------------------------------------------------------
