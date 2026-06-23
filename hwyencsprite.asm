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
; Отображение спрайта без маски.
; I: DE=данные спрайта, HL=адрес VRAM, B=ширина, C=высота
; O: -
; M: все
DrawSprite:	push bc
		push hl
DrawSpriteL:	ld A,(de); vezmi byte spritu
		inc de		; posun v datach
		ld (HL),a		; uloz do VRAM
		inc h		; posun adresu VRAM
		dec b		; opakuj pre celu sirku
		jp NZ,DrawSpriteL
		pop hl
		dec l
DrawSpriteW:	pop bc
		dec c		; opakuj pre celu vysku spritu
		jp NZ,DrawSprite
		ret

;------------------------------------------------------------------------------
; Отображение спрайта с маской 3x24 для титульной надписи в меню.
; Sprite sa kresli do vnutornej obrazovky po riadkoch od spodu hore.
; I: DE=adresa dat spritu, HL=adresa VO; A=тип процедуры 0..3
; O: -
; M: все
DrawSpriteM:
		push hl
		add A,a		; *2
		add A,a		; *4
		add A,a		; *8
		ld c,a
		ld b,0
		ld hl,DrawSpriteM0
		add HL,bc
		pop bc
		jp (HL)
;
DrawSpriteM0:	; тип процедуры 0
		ld l,c
		ld h,b
		ld c,24
		jp DrawSprite4	; рисование спрайта +2
		nop
		; тип процедуры 1
		ld l,c
		ld h,b
		ld c,24
		jp DrawSprite6	; рисование спрайта -4
		nop
		; тип процедуры 2
		ld l,c
		ld h,b
		ld c,24
		jp DrawSprite2	; рисование спрайта -2
		nop
		; тип процедуры 3
		ld l,c
		ld h,b
		ld c,24
		jp DrawSpriteML	; рисование спрайта 0

DrawSpriteML:	ld A,(de); maska
		and (HL)		; aplikuj masku na obsah VO
		ld (HL),a		; uloz zmenu
		inc de		; posun v datach
		inc hl		; posun adresy VO
		ld A,(de)		; opakuj este 2x
		and (HL)
		ld (HL),a
		inc de
		inc hl
		ld A,(de)
		and (HL)
		ld (HL),a
		inc de
		dec hl		; adresa VO nazad
		dec hl
		ld A,(de)		; data spritu
		or (HL)		; pridaj data spritu
		ld (HL),a		; uloz zmenu do VO
		inc de		; posun v datach
		inc hl		; posun adresy VO
		ld A,(de)		; opakuj este 2x
		or (HL)
		ld (HL),a
		inc de
		inc hl
		ld A,(de)
		or (HL)
		ld (HL),a
		inc de
		ld a,c
		ld bc,-(2+SVO)	; posun adresu VO na predosly
		add HL,bc		; mikroriadok
		ld c,a
		dec c		; opakuj pre celu vysku
		jp NZ,DrawSpriteML
		ret

;------------------------------------------------------------------------------
; Отображение замаскированного спрайта 4x24 в базовой позиции (без сдвига).
; Sprite sa kresli do vnutornej obrazovky po riadkoch od spodu hore.
; I: DE=adresa dat spritu, HL=adresa VO
; O: -
; M: все
DrawSprite0:	ld c,24; vyska spritu 24 bodov
DrawSprite0L:	ld A,(de); maska
		and (HL)		; aplikuj masku na obsah VO
		ld (HL),a		; uloz zmenu
		inc de		; posun v datach
		inc hl		; posun adresy VO
		ld A,(de)		; 2
		and (HL)
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 3
		and (HL)
		ld (HL),a
		inc de
		dec hl		; adresa VO nazad
		dec hl
		ld A,(de)		; data spritu
		or (HL)		; pridaj data spritu
		ld (HL),a		; uloz zmenu do VO
		inc de		; posun v datach
		inc hl		; posun adresy VO
		ld A,(de)		; 2
		or (HL)
		ld (HL),a
		inc de
		inc hl
		ld A,(de)		; 3
		or (HL)
		ld (HL),a
		inc de
		ld a,c
		ld bc,-(2+SVO)	; posun adresu VO na predosly
		add HL,bc		; mikroriadok
		ld c,a
		dec c		; opakuj pre celu vysku
		jp NZ,DrawSprite0L
		ret

;------------------------------------------------------------------------------
; Отображение замаскированного спрайта 4х24 со сдвигом на 2 точки влево.
; Sprite sa kresli do vnutornej obrazovky po riadkoch od spodu hore.
; I: DE=adresa dat spritu, HL=adresa VO
; O: -
; M: A, C, DE, HL
DrawSpriteX:
DrawSprite2:	ld c,24; vyska spritu 24 bodov
DrawSprite2L:	push bc
		push hl		; odpamataj adresu VO
		ex DE,HL			; predloha do HL
		ld a,(HL)		; jeden riadok masky do DBC
		inc hl
		ld b,(HL)
		inc hl
		ld c,(HL)
		inc hl
		ex (SP),HL			; odpamataj adresu predlohy
		push hl		; aj adresu VO
;		ori	0C0h		; zlava vstupia do masky jednotky
		rra			; odrotuj masku dolava
		ld d,a
		ld a,b
		rra
		ld b,a
		ld a,c
		rra
		ld b,a
		ld a,c
		rra
		ld c,a
		ld a,d
		rra
		ld d,a
		rra
		ld d,a
		ld a,b
		rra
		ld b,a
		ld a,c
		rra
		ld b,a
		ld a,c
		rra
		ld c,a
		pop hl		; adresa VO do HL
		ld a,d		; get 1st mask byte
		and (HL)		; aplikuj narotovanu masku
		ld (HL),a
		inc hl
		ld a,b
		and (HL)
		ld (HL),a
		inc hl
		ld a,c
		and (HL)
		ld (HL),a
		dec hl
		dec hl
		ex (SP),HL			; adresa predlohy do HL
		ld a,(HL)		; jeden riadok predlohy do DBC
		inc hl
		ld b,(HL)
		inc hl
		ld c,(HL)
		inc hl
		ex (SP),HL			; odpamataj adresu predlohy
		push hl		; aj adresu VO
;		ora	a		; zlava vstupi do predlohy nula
		rra			; odrotuj predlohu dolava
		ld d,a
		ld a,b
		rra
		ld b,a
		ld a,c
		rra
		ld c,a
		ld a,d
		rra
		ld d,a
		ld a,b
		rra
		ld b,a
		ld a,c
		rra
		ld c,a
		pop hl		; obnov adresu VO
		ld a,d		; odrotuj predlohu dolava este raz
		or (HL)		; zapis narotovanu predlohu
		ld (HL),a
		inc hl
		ld a,b
		or (HL)
		ld (HL),a
		inc hl
		ld a,c
		or (HL)
		ld (HL),a
		pop de		; obnov adresu predlohy
		ld bc,-(2+SVO)	; posun adresu VO na predchadzajuci
		add HL,bc		; mikroriadok
		pop bc		; obnov pocitadlo vysky
		dec c		; opakuj pre celu vysku
		jp NZ,DrawSprite2L
		ret

;------------------------------------------------------------------------------
; Отображение замаскированного спрайта 4х24 со сдвигом на 2 точки вправо.
; Sprite sa kresli do vnutornej obrazovky po riadkoch od spodu hore.
; I: DE=adresa dat spritu, HL=adresa VO
; O: -
; M: AF, C, DE, HL
DrawSprite4:	ld c,24; vyska spritu 24 bodov
DrawSprite4L:	push bc
		push hl		; odpamataj adresu VO
		ex DE,HL			; predloha do HL
		ld b,(HL)		; jeden riadok masky do BCD
		inc hl
		ld c,(HL)
		inc hl
		ld a,(HL)
		inc hl
		ex (SP),HL			; odpamataj adresu predlohy
		push hl		; aj adresu VO
;		stc			; zprava vstupi do masky jednotka
		rla			; odrotuj masku doprava
		ld d,a
		ld a,c
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		ld a,c
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
		pop hl		; obnov adresu VO
		ld a,b
		and (HL)
		ld (HL),a
		inc hl
		ld a,c
		and (HL)
		ld (HL),a
		inc hl
		ld a,d
		and (HL)
		ld (HL),a
		dec hl
		dec hl
		ex (SP),HL			; adresa predlohy do HL
		ld b,(HL)		; jeden riadok predlohy do BCD
		inc hl
		ld c,(HL)
		inc hl
		ld a,(HL)
		inc hl
		ex (SP),HL			; odpamataj adresu predlohy
		push hl		; aj adresu VO
;		ora	a		; zprava vstupi do predlohy nula
		rla			; odrotuj predlohu doprava
		ld d,a
		ld a,c
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
;		ora	a		; zprava vstupi do predlohy nula
		ld a,d		; odrotuj masku doprava este raz
		rla
		ld d,a
		ld a,c
		rla
		ld c,a
		ld a,b
		rla
;		mov	b,a
		pop hl		; obnov adresu HL
;		mov	a,c		; uloz narotovanu predlohu
		or (HL)
		ld (HL),a
		inc hl
		ld a,c
		or (HL)
		ld (HL),a
		inc hl
		ld a,d
		or (HL)
		ld (HL),a
		pop de		; obnov adresu predlohy
		ld bc,-(2+SVO)	; posun adresu VO na predchadzajuci
		add HL,bc		; mikroriadok
		pop bc		; obnov pocitadlo vysky
		dec c		; opakuj pre celu vysku
		jp NZ,DrawSprite4L
		ret

;------------------------------------------------------------------------------
; Отображение замаскированного спрайта 4х24 со сдвигом на 4 точки влево.
; I: DE=adresa dat spritu, HL=adresa VO
; O: -
; M: A, C, DE, HL
DrawSprite6:	ld c,24; vyska spritu 24 bodov
DrawSprite6L:	push bc
		push hl		; odpamataj adresu VO
		ex DE,HL			; predloha do HL
		ld a,(HL)		; jeden riadok masky do DBC
		inc hl
		ld b,(HL)
		inc hl
		ld d,(HL)
		inc hl
		ex (SP),HL			; odpamataj adresu predlohy
		push hl		; aj adresu VO
;		ori	0C0h		; zlava vstupia do masky jednotky
		rla			; 1 - odrotuj masku dolava
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		ld a,c		; 2
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		ld a,c		; 3
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		ld a,c		; 4
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		pop hl		; adresa VO do HL
		ld a,d		; get 1st mask byte
		and (HL)		; aplikuj narotovanu masku
		ld (HL),a
		inc hl
		ld a,b
		and (HL)
		ld (HL),a
		inc hl
		ld a,c
		and (HL)
		ld (HL),a
		dec hl
		dec hl
		ex (SP),HL			; adresa predlohy do HL
		ld a,(HL)		; jeden riadok predlohy do DBC
		inc hl
		ld b,(HL)
		inc hl
		ld c,(HL)
		inc hl
		ex (SP),HL			; odpamataj adresu predlohy
		push hl		; aj adresu VO
;		ora	a		; zlava vstupi do predlohy nula
		rla			; 1 - odrotuj predlohu dolava
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		ld a,c		; 2
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		ld a,c		; 3
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		ld a,c		; 4
		rla
		ld c,a
		ld a,b
		rla
		ld b,a
		ld a,d
		rla
		ld d,a
		pop hl		; obnov adresu VO
		ld a,d		; odrotuj predlohu dolava este raz
		or (HL)		; zapis narotovanu predlohu
		ld (HL),a
		inc hl
		ld a,b
		or (HL)
		ld (HL),a
		inc hl
		ld a,c
		or (HL)
		ld (HL),a
		pop de		; obnov adresu predlohy
		ld bc,-(2+SVO)	; posun adresu VO na predchadzajuci
		add HL,bc		; mikroriadok
		pop bc		; obnov pocitadlo vysky
		dec c		; opakuj pre celu vysku
		jp NZ,DrawSprite2L
		ret

;------------------------------------------------------------------------------
; Vykreslenie pripravenych spritov v zozanme do VO2.
DrawSpr:	ld hl,SprListOrd; адрес списка отсортированных спрайтов
DrawSprA:	ld a,(HL); znacka v zozname
		and a		; конец списка?
		jp Z,DrawSprE	; да, назад
		inc hl		; пропустить отметку
		ld e,(HL)		; адрес структуры объекта в DE
		inc hl
		ld d,(HL)
		inc hl
		push hl		; odpamataj adresu zoznamu
		ex DE,HL			; адрес структуры в HL
		inc hl		; (1)
		inc hl		; (2)
		inc hl		; (3)
		ld c,(HL)
		inc hl		; (4)
		ld b,(HL)		; смещение спрайта в зоне в BC
		inc hl		; (5)
		ld e,(HL)		; aktualny offset na zoznam adries spritov do E
		ld a,4
		add A,l
		ld l,a		; {9}
;		lda	SprOffStep	; дополнительный сдвиг
;		add	m		; pripocitaj typ rutiny { 0, 1, 2 }
		ld a,(HL)
;		cpi	4		; ak je to viac ako 2
		and 3
;		jc	DrawSprB
;		sui	4		; uprav na spravnu hodnotu
;		inx	b		; a inkrementuj posun spritu v Zone
DrawSprB:	ld d,a; тип процедуры временно в D
		inc hl		; {10}
		ld l,(HL)		; offset pre urcenie sekvencie spritu
		ld h,Vars/256	; vyssi byte adresy bloku premennych
		ld a,(HL)		; sekvencia do A
		add A,e		; pripocitaj aktualny offset na zoznam
		ld l,a		;   adries spritov a uloz do L
		ld h,SprAddrs/256	; vyssi byte zoznamu adries spritov do H
		ld a,d		; тип процедуры обратно в A
		ld e,(HL)		; адрес искомого спрайта в DE
		inc hl
		ld d,(HL)
		ld HL,(SprOffZone)	; смещение положения спрайта в соответствии с зоной
		add HL,bc		; HL=адрес назначения vo VO2
		ld c,a		; запомнить тип процедуры
		ld a,h		; спрайт находится в области VO2?
		cp InnerScr2/256
		jp C,DrawSprD	; нет, пропустить рисование
		push hl		; адрес назначения vo VO2 na zasobnik
		push hl		; a este raz
		ld a,c
		add A,a		; тип процедуры *2
		add A,a		; *4
		add A,a		; *8
		ld c,a
		ld b,0
		ld hl,DrawSprR	; находим правильный адрес процедуры
		add HL,bc		; в HL
		pop bc		; адрес назначения VO2 в BC
		jp (HL)			; косвенный переход на процедуру рисования спрайта
;
; Отображение спрайта 4x24 с правильным смещением; здесь четыре блока кода по 8 байт
; I: DE=адрес данных спрайта, BC=адрес назначения
DrawSprR:	; тип процедуры 0
		ld l,c
		ld h,b
		call DrawSprite4	; рисование спрайта
		jp DrawSprC	; идём дальше
		; тип процедуры 1
		ld l,c
		ld h,b
		call DrawSprite0	; рисование спрайта
		jp DrawSprC	; идём дальше
		; тип процедуры 2
		ld l,c
		ld h,b
		call DrawSprite2	; рисование спрайта
		jp DrawSprC	; идём дальше
		; тип процедуры 3
		ld l,c
		ld h,b
		call DrawSprite6
;
DrawSprC:	pop hl; obnov cielovu adresu vo VO2
		ld a,2		; znacka
		ld c,4		; 4 bloky na vysku
		call MarkBlocks	; oznac bloky, ktore obsadil sprite
DrawSprD:	pop hl; obnov adresu zoznamu
		jp DrawSprA	; dalsi sprite

; po vykresleni spritov este male upravy

; Prejdi lave tri znakove stlpce zaciatku drahy a hladaj znacku nakresleneho
; spritu v dalsom riadku bloku.
; Tieto znacky su pridane pri kresleni spritu na pravom kraji drahy.
DrawSprE:	ld de,MarkBuff+(9*SVO)
		ld hl,MarkBuff+(10*SVO)
		ld bc,7
DrawSprF:	ld a,2
		cp (HL)		; je tu znacka?
		jp NZ,DrawSprG	; nie, skoc dalej
		ld (de),A		; o riadok vyssie daj znacku tiez
DrawSprG:	inc hl
		inc de
		cp (HL)		; je tu znacka?
		jp NZ,DrawSprH	; nie, skoc dalej
		ld (de),A		; o riadok vyssie daj znacku tiez
DrawSprH:	inc hl
		inc de
		cp (HL)		; je tu znacka?
		jp NZ,DrawSprI	; nie, skoc dalej
		ld (de),A		; o riadok vyssie daj znacku tiez
DrawSprI:	ld a,c
		ld c,SVO-2
		add HL,bc
		ex DE,HL
		add HL,bc
		ex DE,HL
		ld c,a
		dec c
		jp NZ,DrawSprF

		ld hl,InnerScr2+SVO-1 ; vymaz 2 pixely v poslednom stlpci VO
		ld de,SVO
		ld bc, (50<<8)|0Fh
DrawSprJ:	ld a,(HL)
		and c
		ld (HL),a
		add HL,de
		dec b
		jp NZ,DrawSprJ
		ret

;------------------------------------------------------------------------------
DrawRough:	ld hl,RoughAdrs; inicializuj adresu zoznamu cielovych
		ld (DrawRoughE+1),HL	; adries VO2 kam budu vykreslene sprity
		ld (HL),0
		ld hl,SprPrepList	; zoznam pripravenych spritov
DrawRoughA:	ld a,(HL); (0) vezmi Y poziciu spritu
		cp 0FEh		; это неактивный объект?
		jp Z,DrawRoughD	; да, идём дальше
		jp NC,DrawRoughF	; koniec zoznamu, skoc dalej
		push hl		; odpamataj adresu struktury
		ld a,6		; posun ukazatela na typ spritu
		add A,l
		ld l,a
		ld a,(HL)		; (6) тип спрайта
		cp 16h		; je to drsny povrch?
		jp NZ,DrawRoughC	; nie, prejdi na dalsi sprite
		ld a,-5		; posun ukazatela na X poziciu spritu
		add A,l
		ld l,a
		ld c,(HL)		; (1)
		inc hl
		ld b,(HL)		; (2) pozicia spritu do BC
		ex DE,HL
		ld HL,(ZonePosQ)	; pozicia zony do HL
		call SubBCHL		; porovnaj, ci je sprite v aktualnej zone
		jp NZ,DrawRoughC	; nie je, prejdi na dalsi sprite
		ex DE,HL
		inc hl
		ld c,(HL)		; (3)
		inc hl
		ld b,(HL)		; (4) posun spritu v Zone do BC
		ex DE,HL
		ld HL,(SprOffZone)	; offset pozicie spritov podla zony
		add HL,bc		; HL=адрес назначения vo VO2
		ld a,h		; ak je cely sprite mimo VO2 (pred VO2)
		cp InnerScr2/256
		jp C,DrawRoughC	; vynechaj ho
		ld c,l		; адрес назначения в BC
		ld b,h
		ex DE,HL
		ld a,5		; posun ukazatela na typ rutiny
		add A,l
		ld l,a		; (9) тип процедуры
		ld a,(HL)
		and 3
DrawRoughE:	ld hl,0; adresa zoznamu adries VO2
		ld d,0		; D=0; koncova znacka
		ld (HL),b		; uloz adresu cielovu adresu CO2
		inc hl		; do zoznamu - zamerne najprv vyssi byte!
		ld (HL),c
		inc hl
		ld (HL),d		; koncova znacka
		ld (DrawRoughE+1),HL	; uloz novy ukazatel
		add A,a		; тип процедуры *2
		ld e,a
		add A,a		; *4
		add A,a		; *8
		add A,e		; *10
		ld e,a
		ld hl,DrawRoughB	; najdi spravnu adresu rutiny
		add HL,de		; do HL
M256S5:		ld de,SprRough; adresa spritu - drsny povrch
		jp (HL)			; skoc nepriamo vykreslit sprite
;
; Отображение спрайта с правильным смещением; здесь четыре блока кода по 10 байт
; I: DE=адрес данных спрайта, BC=адрес назначения
DrawRoughB:	; typ rutiny 0
		ld l,c
		ld h,b
		ld c,7		; vyska 7 bodov
M256R2B:	call DrawSprite6L; vykreslenie spritu narotovaneho o 2 body dolava
		jp DrawRoughC	; skoc dalej
		; typ rutiny 1
		ld l,c
		ld h,b
		ld c,7		; vyska 7 bodov
M256R0B:	call DrawSprite4L; vykreslenie spritu bez posunutia
		jp DrawRoughC	; skoc dalej
		; typ rutiny 2
		ld l,c
		ld h,b
		ld c,7		; vyska 7 bodov
M256R4B:	call DrawSprite0L; vykreslenie spritu narotovaneho o 2 body doprava
		jp DrawRoughC	; skoc dalej
		; typ rutiny 3
		ld l,c
		ld h,b
		ld c,7		; vyska 7 bodov
		call DrawSprite2L

DrawRoughC:	pop hl; adresu struktury spritu
DrawRoughD:	ld de,16
		add HL,de
		jp DrawRoughA

DrawRoughF:	ld A,(RoughAdrs); ak neboli vykrelsene ziadne sprity,
		or a
		ret Z			; hned sa vrat

		; prekopiruj VO2 do VO
		ld l,VVO
		ld de,InnerScr2
		ld bc,InnerScr
		call CopyInnerBuf

		; vytvor znacky blokov kam sa vykreslili sprity
		ld hl,RoughAdrs	; zoznam adries
DrawRoughM:	ld a,(HL); vezmi vyssi byte
		or a		; koniec zoznamu?
		ret Z			; ano, konecne navrat
		ld d,a
		inc hl
		ld e,(HL)		; adresa VO2 do DE
		inc hl
		push hl		; adresa zoznamu na zasobnik
		ex DE,HL			; adresa VO2 do HL
		ld a,1		; znacka
		ld c,3		; 3 bloky na vysku
		call MarkBlocks	; oznac bloky, ktore obsadil sprite
		pop hl
		jp DrawRoughM

;------------------------------------------------------------------------------
; Oznaci "Bloky", pod ktorymi sa nachadza vykresleny sprite.
; Blokom sa mysli 8 sestic nad sebou. Znacky sa zapisuju do MarkBuff.
; I: HL=adresa vo VO2, A=znacka, C=pocet blokov na vysku
; O: -
; M: все
MarkBlocks:	ld (MarkBlocksM+1),A; uloz znacku
		ld de,InnerScr2	; odpocitaj bazovu adresu VO2
		call SubHLDE		; HL=offset od zaciatku VO2
		ret C
MarkBlocksX:	ld d,SVO; vydel sirkou mikroriadku VO
		call Div16x8		; HL=mikroriadok <0,143>, A=stlpec <0,31>
		ld b,a		; stlpec do B
		ld a,l
		and 0F8h
		ld l,a		; HL=INT(HL/8)*8 - vyska bloku 8 mikroriadkov
		rrca
		rrca
		rrca
		ld d,h		; DE=HL/8
		ld e,a
		ld e,l		; *8 do DE
		add HL,hl		; *16
		add HL,hl		; *32
		ld e,b		; DE=stlpec
		add HL,de		; +stlpec
		ld de,MarkBuff
		add HL,de		; HL=адрес назначения pre znacky
MarkBlocksY:	ld de,-(3+SVO); offset na predchadzajuci riadok
MarkBlocksM:	ld b,0; znacka
MarkBlocksL:	ld (HL),b; uloz 4 znacky v jednom riadku blokov
		inc hl
		ld (HL),b
		inc hl
		ld (HL),b
		inc hl
		ld (HL),b
		add HL,de		; prejdi na predchadzajuci riadok
		dec c
		jp NZ,MarkBlocksL	; opakuj
		ret

;------------------------------------------------------------------------------
; (9822h)
; Zmazanie spritov z VO2.
; Prakticky sa do VO2 nakopiruje obsah z VO1 v miestach, kde boli sprity
; vykreslene.
UndrawSpr:	ld hl,SprListOrd; zoznam zoradenych spritov
UndrawSprA:	ld a,(HL)
		and a		; koniec zoznamu?
		ret Z			; ano, navrat
		inc hl		; preskoc znacku
		ld e,(HL)		; adresa struktury spritu do DE
		inc hl
		ld d,(HL)
		inc hl
		push hl		; adresa zoznamu na zasobnik
		ex DE,HL			; adresa struktury spritu do HL
		inc hl		; (1)
		inc hl		; (2)
		inc hl		; (3)
		ld c,(HL)
		inc hl		; (4)
		ld b,(HL)		; pozicia spritu vo VO2 do BC
		ex DE,HL
		ld HL,(SprOffZone)	; offset pozicie spritov podla zony
		add HL,bc		; pripocitaj
		ld a,h		; ak je cely sprite mimo VO2 (pred VO2)
		cp InnerScr2/256
		jp C,UndrawSprD	; vynechaj ho
		ld c,l		; адрес назначения do BC
		ld b,h
		ex DE,HL
		ld a,5		; posun ukazatela na typ rutiny
		add A,l
		ld l,a		; (9) typ rutiny
;		lda	SprOffStep	; kroky naviac
;		add	m		; pripocitaj typ rutiny { 0, 1, 2 }
;		cpi	3		; ak je to viac ako 2
;		jc	UndrawSprB
;		sui	3		; uprav na spravnu hodnotu
;		inx	b		; a posun cielovu adresu
UndrawSprB:	ld e,c; a uloz do DE
		ld d,b
		ld hl,InnerScr-InnerScr2 ; offset pre navrat na VO1
		add HL,bc		; HL=pozicia spritu vo VO1

		ld bc, (255<<8)|24
UndrawSprC:	ld a,(HL); prekopiruj jeden riadok
		ld (de),A		; pod spritom z VO1 do VO2
		inc hl
		inc de
		ld a,(HL)
		ld (de),A
		inc hl
		inc de
		ld a,(HL)
		ld (de),A
		inc hl
		inc de
		ld a,(HL)
		ld (de),A
		ld a,c
		ld c,-(3+SVO)	; presun na predosly mikroriadok
		add HL,bc		; vo VO1
		ex DE,HL
		add HL,bc		; vo VO2
		ex DE,HL
		ld c,a
		dec c
		jp NZ,UndrawSprC
UndrawSprD:	pop hl; obnov adresu zoznamu
		jp UndrawSprA	; pokracuj dalsim spritom

;------------------------------------------------------------------------------
; Перерисовать изменения без прерываний
RedrawChangesDI:
		di
		call RedrawChanges
		ei
		ret

; Перерисовать изменения
RedrawChanges:
		ld hl,RedrawList	; zoznam adries pre aplikovanie zmien
RedrawChangesA:	ld a,(HL); ширина в A
		or a
		ret Z
		inc hl
		ld e,(HL)		; адрес VO2 в DE
		inc hl
		ld d,(HL)
		inc hl
		push de		; a na zasobnik
		ld e,(HL)		; адрес VRAM в DE
		inc hl
		ld d,(HL)
		inc hl
		ld c,(HL)		; adresa flagov zmien (vo VO1) do BC
		inc hl
		ld b,(HL)
		inc hl
		ex (SP),HL			; HL=VO2, DE=VRAM, BC=флаги
RedrawChangesB:	push af; sirka na zasobnik
		ld A,(bc)		; берём флаг
		dec a		; нужна перерисовка?
		jp M,RedrawChangesC	; нет, переходим
		ld (bc),A		; a uloz novu hodnotu
		push bc		; сохраняем адрес флагов
		ld bc,SVO		; смещение к следующей микро-строке в VO2
;
		ld a,(HL)		; байт из VO2
		ld (de),A		; пишем в VRAM
		add HL,bc		; сдвигаем на микро-строку в VO2
		dec e		; сдвигаем на микро-строку в VRAM
		ld a,(HL)
		ld (de),A		; 2
		add HL,bc
		dec e
		ld a,(HL)
		ld (de),A		; 3
		add HL,bc
		dec e
		ld a,(HL)
		ld (de),A		; 4
		add HL,bc
		dec e
		ld a,(HL)
		ld (de),A		; 5
		add HL,bc
		dec e
		ld a,(HL)
		ld (de),A		; 6
		add HL,bc
		dec e
		ld a,(HL)
		ld (de),A		; 7
		add HL,bc
		dec e
		ld a,(HL)
		ld (de),A		; 8
;
		ld bc,-(7*SVO)	; adresa VO2 na povodnu hodnotu
		add HL,bc
		ld a,e
		add A,7
		ld e,a		; vyssi byte VRAM na povodnu hodnotu
		pop bc		; obnov adresu flagov
RedrawChangesC:	dec hl; posun na znakovu poziciu do prava
;		dcr	d		; следующий столбец в VRAM
		ld a,d
		dec a
		and 01Fh
		or BaseVramAdr/256
		ld d,a
		dec bc		; следующий байт флагов
		pop af
		dec a		; opakuj pre celu sirku
		jp NZ,RedrawChangesB
		pop hl		; obnov adresu zoznamu
		jp RedrawChangesA	; navrat do slucky

;------------------------------------------------------------------------------
; Список адресов, которые перерисовываются справа налево в рамках трека.
; Формат:
;   DB ширина в sesticiach,
;   DW адрес VO2, адрес VRAM, адрес флагов (MarkBuff)
RedrawList:	.db	10
		.dw	InnerScr2+(17*SVO8)+9,BaseVramAdr+(2<<8)|(255-19*8), MarkBuff+(17*SVO)+9
		.db	12
		.dw	InnerScr2+(16*SVO8)+11,BaseVramAdr+(4<<8)|(255-18*8), MarkBuff+(16*SVO)+11
		.db	14
		.dw	InnerScr2+(15*SVO8)+13,BaseVramAdr+(6<<8)|(255-17*8), MarkBuff+(15*SVO)+13
		.db	16
		.dw	InnerScr2+(14*SVO8)+15,BaseVramAdr+(8<<8)|(255-16*8), MarkBuff+(14*SVO)+15
		.db	18
		.dw	InnerScr2+(13*SVO8)+17,BaseVramAdr+(10<<8)|(255-15*8), MarkBuff+(13*SVO)+17
		.db	20
		.dw	InnerScr2+(12*SVO8)+19,BaseVramAdr+(12<<8)|(255-14*8), MarkBuff+(12*SVO)+19
		.db	22
		.dw	InnerScr2+(11*SVO8)+21,BaseVramAdr+(14<<8)|(255-13*8), MarkBuff+(11*SVO)+21
		.db	24
		.dw	InnerScr2+(10*SVO8)+23,BaseVramAdr+(16<<8)|(255-12*8), MarkBuff+(10*SVO)+23
		.db	26
		.dw	InnerScr2+(9*SVO8)+25,BaseVramAdr+(18<<8)|(255-11*8), MarkBuff+(9*SVO)+25
		.db	27
		.dw	InnerScr2+(8*SVO8)+26,BaseVramAdr+(19<<8)|(255-10*8), MarkBuff+(8*SVO)+26
		.db	27
		.dw	InnerScr2+(7*SVO8)+28,BaseVramAdr+(21<<8)|(255-9*8), MarkBuff+(7*SVO)+28
		.db	27
		.dw	InnerScr2+(6*SVO8)+31,BaseVramAdr+(24<<8)|(255-8*8), MarkBuff+(6*SVO)+31
		.db	25
		.dw	InnerScr2+(5*SVO8)+31,BaseVramAdr+(24<<8)|(255-7*8), MarkBuff+(5*SVO)+31
		.db	23
		.dw	InnerScr2+(4*SVO8)+31,BaseVramAdr+(24<<8)|(255-6*8), MarkBuff+(4*SVO)+31
		.db	21
		.dw	InnerScr2+(3*SVO8)+31,BaseVramAdr+(24<<8)|(255-5*8), MarkBuff+(3*SVO)+31
		.db	19
		.dw	InnerScr2+(2*SVO8)+31,BaseVramAdr+(24<<8)|(255-4*8), MarkBuff+(2*SVO)+31
		.db	17
		.dw	InnerScr2+(1*SVO8)+31,BaseVramAdr+(24<<8)|(255-3*8), MarkBuff+(1*SVO)+31
		.db	15
		.dw	InnerScr2+(0*SVO8)+31,BaseVramAdr+(24<<8)|(255-2*8), MarkBuff+(0*SVO)+31
		.db	0

;------------------------------------------------------------------------------
;******************************************************************************
;------------------------------------------------------------------------------
; Описание структуры объекта
;--------|---------|-----------------------------------------------------------
; Offset |  Размер | Значение
;--------|---------|-----------------------------------------------------------
;      0 |       1 | <00h, 48h> - Y suradnica polohy spritu
;        |         | 0FEh - неактивный объект
;        |         | 0FFh - koniec zoznamu
;      1 |       2 | X suradnica polohy spritu v ramci celej drahy; na jednu zonu
;        |         | pripada 0B0h jednotiek; Z30 zacina na 0B0h, Z29 na 160h atd.
;      3 |       2 | "relativna" adresa umiestnenia spritu vo VO2
;      5 |       1 | offset do zoznamu adries predloh spritov; urcuje konkretny
;        |         | sprite v ramci jeho "sekvencie"
;      6 |       1 | "kod" spritu
;      7 |       1 | sekvencia spritu (otocenie)
;      8 |       1 | rychlost pohybu spritu
;      9 |       1 | typ vykreslovacej rutiny
;     10 |       1 | offset do zozamu pre urcenie sekvencie spritu
;     11 |       1 | offset do zoznamu "obsluznych" rutin spritov
;     12 |       1 | inicializacna hodnota pre (7)
;     13 |       1 | inicializacna hodnota pre (0)
;     14 |       2 | inicializacna hodnota pre (1)
;--------|---------|-----------------------------------------------------------
InitSpr:	ld hl,SprListVL+6
		ld de,14		; Главный Vorton
		ld b,5
InitSprA:	ld (HL),d; (6) тип спрайта
		ld a,4
		add A,l
		ld l,a
		ld (HL),e		; (10) offset pre urcenie sekvencie spritu
		ld a,12
		add A,l
		ld l,a		; (6) dalsia struktura spritu
		ld de, (10h<<8)|13
		dec b
		jp NZ,InitSprA
		ld a,0FFh
		ld (SprPrepList),A	; vyprazdni zoznam pripravenych spritov
		ld hl,SprList	; zoznam vsetkych spritov
		ld b,249		; 249 структур спрайтов
InitSprB:	push bc; odpamataj pocitadlo
		push hl		; odpamataj adresu struktury (zoznamu)
		push hl		; odpamataj adresu struktury (zoznamu)
		ld a,6
		add A,l
		ld l,a
		ld a,(HL)		; (6) код спрайта
		and 0Fh		; odmaskuj iba zakladny kod
		cp 11		; maximalny kod je 10
		jp C,InitSprC
		ld a,8		; kody mimo rozsah nastav na 8 - SprBrickB
		ld (HL),a
InitSprC:	ex DE,HL
		ld hl,InitSprData	; inicializacne data
		ld bc,22		; offset na init. data pre druhu skupinu
		ld A,(de)		; (6) kod spritu
		and 10h		; prva skupina spritov?
		jp Z,InitSprD	; ano, skoc dalej
		add HL,bc		; HL=init data pre druhu skupinu
InitSprD:	ld A,(de)
		and 0Fh		; odmaskuj zakladny kod
		add A,a		; *2 - 2 inicializacne byty
		ld c,a		; uloz do BC
		add HL,bc		; HL=init data pre tento sprite
		dec de		; (5)
		ld a,(HL)		; offset do zoznamu spritov
		ld (de),A		; (5) uloz do struktury spritu
		ld a,6
		add A,e
		ld e,a		; (11)
		inc hl
		ld a,(HL)		; offset do zoznamu "obsluznych" rutin
		ld (de),A		; (11) uloz do struktury spritu
		ex DE,HL
		inc hl		; (12)
		ld c,(HL)		; inic. hodnota sekvencie/otocenia spritu
		inc hl		; (13)
		pop de		; (0) obnov adresu struktury
		ld a,(HL)		; (13) -> (0)
		ld (de),A		;  - posun na posledne 3 byty
		inc hl		;    presun posledne 3 byty na zaciatok,
		inc de		;    kde je pociatocna pozicia spritu
		ld a,(HL)		; (14) -> (1)
		ld (de),A
		inc hl
		inc de
		ld a,(HL)		; (15) -> (2)
		ld (de),A
		ld a,-9
		add A,l
		ld l,a		; (6)
		ld b,(HL)		; typ spritu
		inc hl		; (7)
		ld a,c
		and 7
		ld (HL),a		; (7) sekvencia spritu (otocenie)
		inc hl		; (8)
		ld a,(HL)		; (8) aktualna rychlost spritu
		cp 5		; ak je >=5,
		jp NC,InitSprE	; skoc, ju vynulovat
		ld a,b		; typ spritu
		and 0Fh		; vynuluj bit druhej skupiny spritov
		cp 9		; ak je to Lasertron,
		jp NC,InitSprE	; skoc vynulovat rychlost
		and a		; a tiez pre Vortona a AutoVortony
		jp NZ,InitSprF	; pre ostatne sprity rychlost nemen
InitSprE:	ld (HL),0; (8) vynuluj rychlost pre vybrane sprity
InitSprF:	dec de; (1)
		dec de		; (0)
		ld A,(de)		; (0) vezmi suradnicu Y
		cp 0FEh		; ak je to neaktivny sprite,
		jp NC,InitSprG	; skoc spracovat dalsi sprite
		ld c,a		; Y do BC
		ld b,0
		inc de		; (1) - XL
		ld A,(de)
		ld l,a
		inc de		; (2) - XH
		ld A,(de)
		ld h,a		; X do HL
		inc de		; (3)
		push de		; odpamataj ukazatel do struktury
		; vypocitaj adresu do VO2
		push hl		; odpamataj X
		push bc		; odpamataj Y
		add HL,bc		; HL = X + Y
		ld a,h		; Hl = HL / 2
		or a		; CY=0
		rra
		ld h,a
		ld a,l
		rra
		ld l,a
		add HL,hl		; *2
		add HL,hl		; *4
		add HL,hl		; *8
		add HL,hl		; *16
		add HL,hl		; *32
		ex DE,HL			; DE = ((X + Y) / 2) * 32
		ld hl,InnerScr2+13A3h ;TODO было =0BFFCh
		call SubHLDE		; HL = 0BFFCh - (((X + Y) / 2) * 32)
		pop de		; obnov Y do DE
		ex (SP),HL			; medzivysedok na zasobnik, HL=X
		call SubHLDE		; HL = X - Y
		ld d,8
		call Div16x8		; HL = (X - Y) / 8, A = (X - Y) MOD 8
		pop de		; obnov medzivysledok a pripocitaj
		add HL,de		; HL = (0BFFCh - (((X + Y) / 2) * 32)) + ((X - Y) / 8)
		ex DE,HL			; premiestni vysledok do DE
		pop hl		; obnov ukazatel do struktury
		ld (HL),e		; (3) a uloz vysledok do struktury
		inc hl		; (4)
		ld (HL),d
		rra			; A = ((X - Y) MOD 8) / 2
		ld c,a		; typ zobrzovacej rutiny do C {0, 1, 2, 3}
		ld a,5
		add A,l
		ld l,a		; (9)
		ld (HL),c		; uloz (0, 1, 2, 3)
InitSprG:	pop hl; obnov adresu struktury
		ld bc,16		; offset na dalsiu strukturu
		add HL,bc		; prejdi na dalsiu
		pop bc		; obnov pocitadlo
		dec b		; opakuj pre vsetky sprity
		jp NZ,InitSprB
		ret

;------------------------------------------------------------------------------
PrepSpr:	xor a
		ld (SprListOrd),A	; vyprazdni zoznam zoradenych spritov
; do hlavneho zoznamu vrat sprity, ktore boli v predoslom "frame"
		ld hl,SprPrepList	; zoznam pripravenych spritov
		ld c,14
PrepSprA:	ld a,(HL); znacka (suradnica Y)
		cp 0FFh		; je to koniec zoznamu?
		jp Z,PrepSprZ	; ano, skoc dalej
		push hl
		ld a,l
		add A,c
		ld l,a		; (14)
		ld e,(HL)		; адрес назначения povodnej struktury
		inc hl		; spritu do DE
		ld d,(HL)
		inc hl		; (0)
		ex (SP),HL			; адрес источника do HL
		ld b,13		; 13 bytov struktury
		call Copy8		; prekopiruj
		pop hl		; prejdi na dalsiu strukturu
		jp PrepSprA

; найти правильную зону в соответствии с текущей позицией Vorton и инициализировать соответствующие переменные
PrepSprZ:	ld HL,(VortonStruct); adresa struktury aktualneho hlavneho
		inc hl		;  Vortona
		ld c,(HL)		; X координаты положения в DE
		inc hl
		ld b,(HL)
		ld a,b		; ak je pozicia < 0B0h,
		and a
		jp NZ,PrepSprB
		ld a,c
		cp 0B0h
		jp NC,PrepSprB
		dec hl
		ld c,0B0h		; nastav ju na 0B0h
		ld (HL),c
PrepSprB:	ld a,1; номер зоны 1 (до 36)
		ld de,07F0h		; offset adresy VO2 pre sprity
		ld hl,00B0h		; pociatocna pozicia v zone
PrepSprC:	push af; odpamataj pocitadlo
		push bc		; odpamataj aktualnu poziciu Vortona
					; od aktualnej pozicie Vortona odpocitaj
		call SubBCHL		; pociatocnu poziciu v zone
;		mov	a,b		; ak je rozdiel < 0B0h, Vorton je
;		ana	a		; v tejto Zone
		jp NZ,PrepSprD
		ld a,c
		cp 0B0h
		jp C,PrepSprE	; a tak skoc dalej
PrepSprD:	ld bc,0B0h; posun sa do dalsej zony
		add HL,bc
		ex DE,HL
		ld bc,0AEAh		; aj offset vo VO2
		add HL,bc
		ex DE,HL
		pop bc		; obnov aktualnu poziciu Vortona
		pop af		; obnov cislo Zony
		inc a		; cislo zony +1
		jp PrepSprC

PrepSprE:	pop bc; zahod jednu polozku zasobnika
		ld (ZonePos),HL		; исходное положение в зоне
		ld bc,0FFD0h	; -30h
		add HL,bc		; обратный отсчет области перед границей зоны
		ld (ZonePosQ),HL	; uloz
		ld bc,0FF80h	; -80h
		add HL,bc		; обратный отсчет до начала предыдущей зоны
		ld (ZonePosP),HL	; uloz

		pop bc		; obnov cislo Zony do B
;		mov	a,b		; a uloz do A
;		add	a		; к каждой зоне добавляются 2 шага
;		dcr	a		; okrem prvej
;PrepSprH:	sui	3
;		jc	PrepSprI
;		inx	d		; po 3 krokoch je to jedna sestica
;		jmp	PrepSprH

;PrepSprI:	adi	3
;		sta	SprOffStep	; дополнительное смещение в шагах
		ex DE,HL
		ld (SprOffZone),HL	; offset pozicie spritov podla zony

		; priprav cislo zony a zobraz ho
		ld a,b		; cislo Zony do A
		ld (ZoneNumberT),A	; uloz
		ld hl,ZoneNumber	; adresa premennej cislo zony 1 az 31
		cp 32		; ak je to < 32
		jp C,PrepSprF	; skoc dalej
		ld a,32		; uloz maximum 32
		ld (HL),a
		dec a		; a uprav na 31
		jp PrepSprG

PrepSprF:	ld (HL),a; uloz cislo miestnosti
PrepSprG:	call PrintZoneNum

		; подготовить новый список спрайтов
		ld hl,SprList	; adresa zoznamu vsetkych struktur spritov
		ld de,SprPrepList	; adresa zoznamu pripravenych spritov
		ld bc,44		; макс. 44 объекта
PrepSprK:	ld a,(HL); Y suradnica
		cp 0FEh		; je to neaktivny sprite?
		jp NC,PrepSprL	; ano, skoc dalej
		push hl
		push de
		inc hl		; (1)
		ld e,(HL)		; X pozicia spritu do HL
		inc hl		; (2)
		ld d,(HL)
		ld HL,(ZonePosP)	; pozicia predoslej zony
		ex DE,HL
		call SubHLDE		; odpocitaj
;		mov	a,h		; ak sa tento sprite nachadza dalej, ako
		pop de
		pop hl
		cp 2		; 1 zonu pred a 1 zonu za aktualnou zonou,
		jp NC,PrepSprL	; skoc dalej
		push hl
		ld b,14		; prenos 14 bytov struktury
		call Copy8
		pop hl
		ld a,l		; na koniec pridaj samotnu adresu
		ld (de),A		; struktury
		inc de
		ld a,h
		ld (de),A
		inc de
		dec c		; zniz pocitadlo
		jp Z,PrepSprM	; skoc, ak je zoznam plny
PrepSprL:	ld a,c
		ld c,16		; prejdi na dalsiu strukturu
		add HL,bc
		ld c,a
		ld a,h		; presli sa vsetky?
		cp SprListVL/256
		jp C,PrepSprK	; nie, pokracuj dalsou
PrepSprM:	ld a,0FFh; ukonci zoznam
		ld (de),A

		; deaktivuj sprity "Vybuch"
		ld hl,SprList+5	; adresa zoznamu vsetkych struktur spritov
		ld de,(80h<<8)|0E0h
		ld bc,16		; velkost struktury
PrepSprN:	ld a,(HL); (5) je to sprite "Vybuch"?
		cp d
		jp C,PrepSprO	; nie, skoc dalej
		cp e
		jp NC,PrepSprO	; nie, skoc dalej
		inc hl		; (6)
		inc hl		; (7)
		inc hl		; (8)
		ld a,(HL)		; zrus flag rychlosti
		and 7Fh
		ld (HL),a
		ld a,-8
		add A,l
		ld l,a		; (0)
		ld (HL),0FEh		; deaktivuj sprite
		ld a,5
		add A,l
		ld l,a		; (5)
PrepSprO:	add HL,bc; dalsi sprite
		ld a,h		; presli sa vsetky?
		cp SprListVL/256
		jp C,PrepSprN	; nie, pokracuj dalsou
		ret

;------------------------------------------------------------------------------
; Zoradenie spritov podla IZO hlbky.
SortSpr:	ld hl,SprListOrd; koncova adresa zoznamu zoradenych
		ld (SprListOrdEnd),HL	;  spritov uloz
		ld (HL),0		; vyprazdni zoznam
		ld HL,(VortonStruct)	; zaciatok zoznamu spritov do IX
SortSprA:	ld a,(HL); Y pozicia spritu
		cp 0FEh		; je to neaktivny sprite?
		jp Z,SortSprF	; ano, preskoc ho
		ret NC			; koniec zoznamu, navrat
		ld b,a		; Y pozicia do B
		push hl
		ld a,6
		add A,l
		ld l,a		; (6) - typ spritu
		ld a,(HL)		; typ spritu do A
		cp 16h		; je to drsny povrch (Rough)?
		jp Z,SortSprG	; ano, preskoc ho
		cp 19h		; je to tehla (BrickA)?
		jp Z,SortSprG	; ano, preskoc ho
		ld a,-4
		add A,l
		ld l,a		; (2) - XH
		ld d,(HL)
		dec hl		; (1) - XL
		ld e,(HL)		; X pozicia do DE
		ld HL,(ZonePosQ)	; pozicia zony do HL
		ex DE,HL			; zamen
		call SubHLDE		; porovnj pozicie
;		ora	a		; nachadza sa tento sprite v aktualnej zone?
		jp NZ,SortSprG	; ak nie, preskoc ho
		ld a,b		; offset od zaciatku zony (X)
		rra
		ld b,a		; Y=Y/2
		or a
		ld a,l
		rra			; X=X/2
		add A,b
		inc a		; Z=X/2+Y/2+1
		ld hl,SprListOrd	; najdi v zozname miesto kam patri
SortSprB:	cp (HL); tento sprite podla Z
		jp NC,SortSprC	; skoc, ak patri tu
		inc hl		; prejdi na dalsiu polozku v zozname
		inc hl
		inc hl
		jp SortSprB

SortSprC:	push af; odpamataj Z spritu
		xor a		; patri aktualny sprite na koniec
		cp (HL)		;  zoznamu?
		jp NZ,SortSprD	; nie, skoc dalej
		ex DE,HL
		ld HL,(SprListOrdEnd)	; adresa konca zoznamu do HL
		inc hl		; posun ukazatel konca zoznamu
		inc hl
		inc hl
		ld (SprListOrdEnd),HL	; a uloz
		ld (HL),a		; a uloz koncovu znacku
		ex DE,HL
		jp SortSprE	; skoc ulozit refeenciu na sprite

; sprite treba vlozit do zoznamu, takze treba cast zoznamu presunut
SortSprD:	push hl; odpamataj cielovu adresu v zozname
		ex DE,HL
		ld HL,(SprListOrdEnd)	; adresa konca zoznamu do HL
		ld a,l		; vypocitaj dlzku presuvanej casti
		sub e		;  zoznamu do BC
		ld c,a
		inc c		; +1 pre koncovu znacku
		ld e,l		; HL=адрес источника presunu
		inc hl
		inc hl
		inc hl		; DE=адрес назначения presunu
		ld (SprListOrdEnd),HL	; uloz ako novu koncovu adresu zoznamu
SortSprH:	ld A,(de); presun cas zoznamu odzadu
		ld (HL),a
		dec de
		dec hl
		dec c
		jp NZ,SortSprH
		pop hl		; obnov cielovu adresu pre sprite
SortSprE:	pop af; obnov Z spritu
		pop de		; adresa strktury spritu do DE
		push de
		ld (HL),a		; uloz Z spritu
		inc hl
		ld (HL),e		; a uloz ju do zoznamu
		inc hl
		ld (HL),d
SortSprG:	pop hl
SortSprF:	ld de,16; jedna struktura spritu ma 16 bytov
		add HL,de		; dalsia struktura
		jp SortSprA	; spracuj ju

;------------------------------------------------------------------------------
