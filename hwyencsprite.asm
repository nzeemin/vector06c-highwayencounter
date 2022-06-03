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
; Отображение спрайта без маски.
; I: DE=данные спрайта, HL=адрес VRAM, B=ширина, C=высота
; O: -
; M: все
DrawSprite:	push	b
		push	h
DrawSpriteL:	ldax	d		; vezmi byte spritu
		inx	d		; posun v datach
		mov	m,a		; uloz do VRAM
		inr	h		; posun adresu VRAM
		dcr	b		; opakuj pre celu sirku
		jnz	DrawSpriteL
		pop	h
		dcr	l
DrawSpriteW:	pop	b
		dcr	c		; opakuj pre celu vysku spritu
		jnz	DrawSprite
		ret

;------------------------------------------------------------------------------
; Отображение спрайта с маской 3x24 для титульной надписи в меню.
; Sprite sa kresli do vnutornej obrazovky po riadkoch od spodu hore.
; I: DE=adresa dat spritu, HL=adresa VO; A=тип процедуры 0..3
; O: -
; M: все
DrawSpriteM:	
		push	h
		add	a		; *2
		add	a		; *4
		add	a		; *8
		mov	c,a
		mvi	b,0
		lxi	h,DrawSpriteM0
		dad	b
		pop	b
		pchl
;
DrawSpriteM0:	; тип процедуры 0
		mov	l,c
		mov	h,b
		mvi	c,24
		jmp	DrawSprite4	; рисование спрайта +2
		nop
		; тип процедуры 1
		mov	l,c
		mov	h,b
		mvi	c,24
		jmp	DrawSprite6	; рисование спрайта -4
		nop
		; тип процедуры 2
		mov	l,c
		mov	h,b
		mvi	c,24
		jmp	DrawSprite2	; рисование спрайта -2
		nop
		; тип процедуры 3
		mov	l,c
		mov	h,b
		mvi	c,24
		jmp	DrawSpriteML	; рисование спрайта 0

DrawSpriteML:	ldax	d		; maska
		ana	m		; aplikuj masku na obsah VO
		mov	m,a		; uloz zmenu
		inx	d		; posun v datach
		inx	h		; posun adresy VO
		ldax	d		; opakuj este 2x
		ana	m
		mov	m,a
		inx	d
		inx	h
		ldax	d
		ana	m
		mov	m,a
		inx	d
		dcx	h		; adresa VO nazad
		dcx	h
		ldax	d		; data spritu
		ora	m		; pridaj data spritu
		mov	m,a		; uloz zmenu do VO
		inx	d		; posun v datach
		inx	h		; posun adresy VO
		ldax	d		; opakuj este 2x
		ora	m
		mov	m,a
		inx	d
		inx	h
		ldax	d
		ora	m
		mov	m,a
		inx	d
		mov	a,c
		lxi	b,-(2+SVO)	; posun adresu VO na predosly
		dad	b		; mikroriadok
		mov	c,a
		dcr	c		; opakuj pre celu vysku
		jnz	DrawSpriteML
		ret

;------------------------------------------------------------------------------
; Отображение замаскированного спрайта 4x24 в базовой позиции (без сдвига).
; Sprite sa kresli do vnutornej obrazovky po riadkoch od spodu hore.
; I: DE=adresa dat spritu, HL=adresa VO
; O: -
; M: все
DrawSprite0:	mvi	c,24		; vyska spritu 24 bodov
DrawSprite0L:	ldax	d		; maska
		ana	m		; aplikuj masku na obsah VO
		mov	m,a		; uloz zmenu
		inx	d		; posun v datach
		inx	h		; posun adresy VO
		ldax	d		; 2
		ana	m
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 3
		ana	m
		mov	m,a
		inx	d
		dcx	h		; adresa VO nazad
		dcx	h
		ldax	d		; data spritu
		ora	m		; pridaj data spritu
		mov	m,a		; uloz zmenu do VO
		inx	d		; posun v datach
		inx	h		; posun adresy VO
		ldax	d		; 2
		ora	m
		mov	m,a
		inx	d
		inx	h
		ldax	d		; 3
		ora	m
		mov	m,a
		inx	d
		mov	a,c
		lxi	b,-(2+SVO)	; posun adresu VO na predosly
		dad	b		; mikroriadok
		mov	c,a
		dcr	c		; opakuj pre celu vysku
		jnz	DrawSprite0L
		ret

;------------------------------------------------------------------------------
; Отображение замаскированного спрайта 4х24 со сдвигом на 2 точки влево.
; Sprite sa kresli do vnutornej obrazovky po riadkoch od spodu hore.
; I: DE=adresa dat spritu, HL=adresa VO
; O: -
; M: A, C, DE, HL
DrawSpriteX:
DrawSprite2:	mvi	c,24		; vyska spritu 24 bodov
DrawSprite2L:	push	b
		push	h		; odpamataj adresu VO
		xchg			; predloha do HL
		mov	a,m		; jeden riadok masky do DBC
		inx	h
		mov	b,m
		inx	h
		mov	c,m
		inx	h
		xthl			; odpamataj adresu predlohy
		push	h		; aj adresu VO
;		ori	0C0h		; zlava vstupia do masky jednotky
		rar			; odrotuj masku dolava
		mov	d,a
		mov	a,b
		rar
		mov	b,a
		mov	a,c
		rar
		mov	b,a
		mov	a,c
		rar
		mov	c,a
		mov	a,d
		rar
		mov	d,a
		rar
		mov	d,a
		mov	a,b
		rar
		mov	b,a
		mov	a,c
		rar
		mov	b,a
		mov	a,c
		rar
		mov	c,a
		pop	h		; adresa VO do HL
		mov	a,d		; get 1st mask byte
		ana	m		; aplikuj narotovanu masku
		mov	m,a
		inx	h
		mov	a,b
		ana	m
		mov	m,a
		inx	h
		mov	a,c
		ana	m
		mov	m,a
		dcx	h
		dcx	h
		xthl			; adresa predlohy do HL
		mov	a,m		; jeden riadok predlohy do DBC
		inx	h
		mov	b,m
		inx	h
		mov	c,m
		inx	h
		xthl			; odpamataj adresu predlohy
		push	h		; aj adresu VO
;		ora	a		; zlava vstupi do predlohy nula
		rar			; odrotuj predlohu dolava
		mov	d,a
		mov	a,b
		rar
		mov	b,a
		mov	a,c
		rar
		mov	c,a
		mov	a,d
		rar
		mov	d,a
		mov	a,b
		rar
		mov	b,a
		mov	a,c
		rar
		mov	c,a
		pop	h		; obnov adresu VO
		mov	a,d		; odrotuj predlohu dolava este raz
		ora	m		; zapis narotovanu predlohu
		mov	m,a
		inx	h
		mov	a,b
		ora	m
		mov	m,a
		inx	h
		mov	a,c
		ora	m
		mov	m,a
		pop	d		; obnov adresu predlohy
		lxi	b,-(2+SVO)	; posun adresu VO na predchadzajuci
		dad	b		; mikroriadok
		pop	b		; obnov pocitadlo vysky
		dcr	c		; opakuj pre celu vysku
		jnz	DrawSprite2L
		ret

;------------------------------------------------------------------------------
; Отображение замаскированного спрайта 4х24 со сдвигом на 2 точки вправо.
; Sprite sa kresli do vnutornej obrazovky po riadkoch od spodu hore.
; I: DE=adresa dat spritu, HL=adresa VO
; O: -
; M: AF, C, DE, HL
DrawSprite4:	mvi	c,24		; vyska spritu 24 bodov
DrawSprite4L:	push	b
		push	h		; odpamataj adresu VO
		xchg			; predloha do HL
		mov	b,m		; jeden riadok masky do BCD
		inx	h
		mov	c,m
		inx	h
		mov	a,m
		inx	h
		xthl			; odpamataj adresu predlohy
		push	h		; aj adresu VO
;		stc			; zprava vstupi do masky jednotka
		ral			; odrotuj masku doprava
		mov	d,a
		mov	a,c
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		mov	a,c
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		pop	h		; obnov adresu VO
		mov	a,b
		ana	m
		mov	m,a
		inx	h
		mov	a,c
		ana	m
		mov	m,a
		inx	h
		mov	a,d
		ana	m
		mov	m,a
		dcx	h
		dcx	h
		xthl			; adresa predlohy do HL
		mov	b,m		; jeden riadok predlohy do BCD
		inx	h
		mov	c,m
		inx	h
		mov	a,m
		inx	h
		xthl			; odpamataj adresu predlohy
		push	h		; aj adresu VO
;		ora	a		; zprava vstupi do predlohy nula
		ral			; odrotuj predlohu doprava
		mov	d,a
		mov	a,c
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
;		ora	a		; zprava vstupi do predlohy nula
		mov	a,d		; odrotuj masku doprava este raz
		ral
		mov	d,a
		mov	a,c
		ral
		mov	c,a
		mov	a,b
		ral
;		mov	b,a
		pop	h		; obnov adresu HL
;		mov	a,c		; uloz narotovanu predlohu
		ora	m
		mov	m,a
		inx	h
		mov	a,c
		ora	m
		mov	m,a
		inx	h
		mov	a,d
		ora	m
		mov	m,a
		pop	d		; obnov adresu predlohy
		lxi	b,-(2+SVO)	; posun adresu VO na predchadzajuci
		dad	b		; mikroriadok
		pop	b		; obnov pocitadlo vysky
		dcr	c		; opakuj pre celu vysku
		jnz	DrawSprite4L
		ret

;------------------------------------------------------------------------------
; Отображение замаскированного спрайта 4х24 со сдвигом на 4 точки влево.
; I: DE=adresa dat spritu, HL=adresa VO
; O: -
; M: A, C, DE, HL
DrawSprite6:	mvi	c,24		; vyska spritu 24 bodov
DrawSprite6L:	push	b
		push	h		; odpamataj adresu VO
		xchg			; predloha do HL
		mov	a,m		; jeden riadok masky do DBC
		inx	h
		mov	b,m
		inx	h
		mov	d,m
		inx	h
		xthl			; odpamataj adresu predlohy
		push	h		; aj adresu VO
;		ori	0C0h		; zlava vstupia do masky jednotky
		ral			; 1 - odrotuj masku dolava
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		mov	a,c		; 2
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		mov	a,c		; 3
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		mov	a,c		; 4
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		pop	h		; adresa VO do HL
		mov	a,d		; get 1st mask byte
		ana	m		; aplikuj narotovanu masku
		mov	m,a
		inx	h
		mov	a,b
		ana	m
		mov	m,a
		inx	h
		mov	a,c
		ana	m
		mov	m,a
		dcx	h
		dcx	h
		xthl			; adresa predlohy do HL
		mov	a,m		; jeden riadok predlohy do DBC
		inx	h
		mov	b,m
		inx	h
		mov	c,m
		inx	h
		xthl			; odpamataj adresu predlohy
		push	h		; aj adresu VO
;		ora	a		; zlava vstupi do predlohy nula
		ral			; 1 - odrotuj predlohu dolava
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		mov	a,c		; 2
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		mov	a,c		; 3
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		mov	a,c		; 4
		ral
		mov	c,a
		mov	a,b
		ral
		mov	b,a
		mov	a,d
		ral
		mov	d,a
		pop	h		; obnov adresu VO
		mov	a,d		; odrotuj predlohu dolava este raz
		ora	m		; zapis narotovanu predlohu
		mov	m,a
		inx	h
		mov	a,b
		ora	m
		mov	m,a
		inx	h
		mov	a,c
		ora	m
		mov	m,a
		pop	d		; obnov adresu predlohy
		lxi	b,-(2+SVO)	; posun adresu VO na predchadzajuci
		dad	b		; mikroriadok
		pop	b		; obnov pocitadlo vysky
		dcr	c		; opakuj pre celu vysku
		jnz	DrawSprite2L
		ret

;------------------------------------------------------------------------------
; Vykreslenie pripravenych spritov v zozanme do VO2.
DrawSpr:	lxi	h,SprListOrd	; адрес списка отсортированных спрайтов
DrawSprA:	mov	a,m		; znacka v zozname
		ana	a		; конец списка?
		jz	DrawSprE	; да, назад
		inx	h		; пропустить отметку
		mov	e,m		; адрес структуры объекта в DE
		inx	h
		mov	d,m
		inx	h
		push	h		; odpamataj adresu zoznamu
		xchg			; адрес структуры в HL
		inx	h		; (1)
		inx	h		; (2)
		inx	h		; (3)
		mov	c,m
		inx	h		; (4)
		mov	b,m		; смещение спрайта в зоне в BC
		inx	h		; (5)
		mov	e,m		; aktualny offset na zoznam adries spritov do E
		mvi	a,4
		add	l
		mov	l,a		; {9}
;		lda	SprOffStep	; дополнительный сдвиг
;		add	m		; pripocitaj typ rutiny { 0, 1, 2 }
		mov	a,m
;		cpi	4		; ak je to viac ako 2
		ani	3
;		jc	DrawSprB
;		sui	4		; uprav na spravnu hodnotu
;		inx	b		; a inkrementuj posun spritu v Zone
DrawSprB:	mov	d,a		; тип процедуры временно в D
		inx	h		; {10}
		mov	l,m		; offset pre urcenie sekvencie spritu
		mvi	h,Vars/256	; vyssi byte adresy bloku premennych
		mov	a,m		; sekvencia do A
		add	e		; pripocitaj aktualny offset na zoznam
		mov	l,a		;   adries spritov a uloz do L
		mvi	h,SprAddrs/256	; vyssi byte zoznamu adries spritov do H
		mov	a,d		; тип процедуры обратно в A
		mov	e,m		; адрес искомого спрайта в DE
		inx	h
		mov	d,m
		lhld	SprOffZone	; смещение положения спрайта в соответствии с зоной
		dad	b		; HL=адрес назначения vo VO2
		mov	c,a		; запомнить тип процедуры
		mov	a,h		; спрайт находится в области VO2?
		cpi	InnerScr2/256
		jc	DrawSprD	; нет, пропустить рисование
		push	h		; адрес назначения vo VO2 na zasobnik
		push	h		; a este raz
		mov	a,c
		add	a		; тип процедуры *2
		add	a		; *4
		add	a		; *8
		mov	c,a
		mvi	b,0
		lxi	h,DrawSprR	; находим правильный адрес процедуры
		dad	b		; в HL
		pop	b		; адрес назначения VO2 в BC
		pchl			; косвенный переход на процедуру рисования спрайта
;
; Отображение спрайта 4x24 с правильным смещением; здесь четыре блока кода по 8 байт
; I: DE=адрес данных спрайта, BC=адрес назначения
DrawSprR:	; тип процедуры 0
		mov	l,c
		mov	h,b
		call	DrawSprite4	; рисование спрайта
		jmp	DrawSprC	; идём дальше
		; тип процедуры 1
		mov	l,c
		mov	h,b
		call	DrawSprite0	; рисование спрайта
		jmp	DrawSprC	; идём дальше
		; тип процедуры 2
		mov	l,c
		mov	h,b
		call	DrawSprite2	; рисование спрайта
		jmp	DrawSprC	; идём дальше
		; тип процедуры 3
		mov	l,c
		mov	h,b
		call	DrawSprite6
;
DrawSprC:	pop	h		; obnov cielovu adresu vo VO2
		mvi	a,2		; znacka
		mvi	c,4		; 4 bloky na vysku
		call	MarkBlocks	; oznac bloky, ktore obsadil sprite
DrawSprD:	pop	h		; obnov adresu zoznamu
		jmp	DrawSprA	; dalsi sprite

; po vykresleni spritov este male upravy

; Prejdi lave tri znakove stlpce zaciatku drahy a hladaj znacku nakresleneho
; spritu v dalsom riadku bloku.
; Tieto znacky su pridane pri kresleni spritu na pravom kraji drahy.
DrawSprE:	lxi	d,MarkBuff+(9*SVO)
		lxi	h,MarkBuff+(10*SVO)
		lxi	b,7
DrawSprF:	mvi	a,2
		cmp	m		; je tu znacka?
		jnz	DrawSprG	; nie, skoc dalej
		stax	d		; o riadok vyssie daj znacku tiez
DrawSprG:	inx	h
		inx	d
		cmp	m		; je tu znacka?
		jnz	DrawSprH	; nie, skoc dalej
		stax	d		; o riadok vyssie daj znacku tiez
DrawSprH:	inx	h
		inx	d
		cmp	m		; je tu znacka?
		jnz	DrawSprI	; nie, skoc dalej
		stax	d		; o riadok vyssie daj znacku tiez
DrawSprI:	mov	a,c
		mvi	c,SVO-2
		dad	b
		xchg
		dad	b
		xchg
		mov	c,a
		dcr	c
		jnz	DrawSprF

		lxi	h,InnerScr2+SVO-1 ; vymaz 2 pixely v poslednom stlpci VO
		lxi	d,SVO
		lxi	b,HILO(50,0Fh)
DrawSprJ:	mov	a,m
		ana	c
		mov	m,a
		dad	d
		dcr	b
		jnz	DrawSprJ
		ret

;------------------------------------------------------------------------------
DrawRough:	lxi	h,RoughAdrs	; inicializuj adresu zoznamu cielovych
		shld	DrawRoughE+1	; adries VO2 kam budu vykreslene sprity
		mvi	m,0
		lxi	h,SprPrepList	; zoznam pripravenych spritov
DrawRoughA:	mov	a,m		; (0) vezmi Y poziciu spritu
		cpi	0FEh		; это неактивный объект?
		jz	DrawRoughD	; да, идём дальше
		jnc	DrawRoughF	; koniec zoznamu, skoc dalej
		push	h		; odpamataj adresu struktury
		mvi	a,6		; posun ukazatela na typ spritu
		add	l
		mov	l,a
		mov	a,m		; (6) тип спрайта
		cpi	16h		; je to drsny povrch?
		jnz	DrawRoughC	; nie, prejdi na dalsi sprite
		mvi	a,-5		; posun ukazatela na X poziciu spritu
		add	l
		mov	l,a
		mov	c,m		; (1)
		inx	h
		mov	b,m		; (2) pozicia spritu do BC
		xchg
		lhld	ZonePosQ	; pozicia zony do HL
		call	SubBCHL		; porovnaj, ci je sprite v aktualnej zone
		jnz	DrawRoughC	; nie je, prejdi na dalsi sprite
		xchg
		inx	h
		mov	c,m		; (3)
		inx	h
		mov	b,m		; (4) posun spritu v Zone do BC
		xchg
		lhld	SprOffZone	; offset pozicie spritov podla zony
		dad	b		; HL=адрес назначения vo VO2
		mov	a,h		; ak je cely sprite mimo VO2 (pred VO2)
		cpi	InnerScr2/256
		jc	DrawRoughC	; vynechaj ho
		mov	c,l		; адрес назначения в BC
		mov	b,h
		xchg
		mvi	a,5		; posun ukazatela na typ rutiny
		add	l
		mov	l,a		; (9) тип процедуры
		mov	a,m
		ani	3
DrawRoughE:	lxi	h,0		; adresa zoznamu adries VO2
		mvi	d,0		; D=0; koncova znacka
		mov	m,b		; uloz adresu cielovu adresu CO2
		inx	h		; do zoznamu - zamerne najprv vyssi byte!
		mov	m,c
		inx	h
		mov	m,d		; koncova znacka
		shld	DrawRoughE+1	; uloz novy ukazatel
		add	a		; тип процедуры *2
		mov	e,a
		add	a		; *4
		add	a		; *8
		add	e		; *10
		mov	e,a
		lxi	h,DrawRoughB	; najdi spravnu adresu rutiny
		dad	d		; do HL
M256S5:		lxi	d,SprRough	; adresa spritu - drsny povrch
		pchl			; skoc nepriamo vykreslit sprite
;
; Отображение спрайта с правильным смещением; здесь четыре блока кода по 10 байт
; I: DE=адрес данных спрайта, BC=адрес назначения
DrawRoughB:	; typ rutiny 0
		mov	l,c
		mov	h,b
		mvi	c,7		; vyska 7 bodov
M256R2B:	call	DrawSprite6L	; vykreslenie spritu narotovaneho o 2 body dolava
		jmp	DrawRoughC	; skoc dalej
		; typ rutiny 1
		mov	l,c
		mov	h,b
		mvi	c,7		; vyska 7 bodov
M256R0B:	call	DrawSprite4L	; vykreslenie spritu bez posunutia
		jmp	DrawRoughC	; skoc dalej
		; typ rutiny 2
		mov	l,c
		mov	h,b
		mvi	c,7		; vyska 7 bodov
M256R4B:	call	DrawSprite0L	; vykreslenie spritu narotovaneho o 2 body doprava
		jmp	DrawRoughC	; skoc dalej
		; typ rutiny 3
		mov	l,c
		mov	h,b
		mvi	c,7		; vyska 7 bodov
		call	DrawSprite2L

DrawRoughC:	pop	h		; adresu struktury spritu
DrawRoughD:	lxi	d,16
		dad	d
		jmp	DrawRoughA

DrawRoughF:	lda	RoughAdrs	; ak neboli vykrelsene ziadne sprity,
		ora	a
		rz			; hned sa vrat

		; prekopiruj VO2 do VO
		mvi	l,VVO
		lxi	d,InnerScr2
		lxi	b,InnerScr
		call	CopyInnerBuf

		; vytvor znacky blokov kam sa vykreslili sprity
		lxi	h,RoughAdrs	; zoznam adries
DrawRoughM:	mov	a,m		; vezmi vyssi byte
		ora	a		; koniec zoznamu?
		rz			; ano, konecne navrat
		mov	d,a
		inx	h
		mov	e,m		; adresa VO2 do DE
		inx	h
		push	h		; adresa zoznamu na zasobnik
		xchg			; adresa VO2 do HL
		mvi	a,1		; znacka
		mvi	c,3		; 3 bloky na vysku
		call	MarkBlocks	; oznac bloky, ktore obsadil sprite
		pop	h
		jmp	DrawRoughM

;------------------------------------------------------------------------------
; Oznaci "Bloky", pod ktorymi sa nachadza vykresleny sprite.
; Blokom sa mysli 8 sestic nad sebou. Znacky sa zapisuju do MarkBuff.
; I: HL=adresa vo VO2, A=znacka, C=pocet blokov na vysku
; O: -
; M: все
MarkBlocks:	sta	MarkBlocksM+1	; uloz znacku
		lxi	d,InnerScr2	; odpocitaj bazovu adresu VO2
		call	SubHLDE		; HL=offset od zaciatku VO2
		rc
MarkBlocksX:	mvi	d,SVO		; vydel sirkou mikroriadku VO
		call	Div16x8		; HL=mikroriadok <0,143>, A=stlpec <0,31>
		mov	b,a		; stlpec do B
		mov	a,l
		ani	0F8h
		mov	l,a		; HL=INT(HL/8)*8 - vyska bloku 8 mikroriadkov
		rrc
		rrc
		rrc
		mov	d,h		; DE=HL/8
		mov	e,a
		mov	e,l		; *8 do DE
		dad	h		; *16
		dad	h		; *32
		mov	e,b		; DE=stlpec
		dad	d		; +stlpec
		lxi	d,MarkBuff
		dad	d		; HL=адрес назначения pre znacky
MarkBlocksY:	lxi	d,-(3+SVO)	; offset na predchadzajuci riadok
MarkBlocksM:	mvi	b,0		; znacka
MarkBlocksL:	mov	m,b		; uloz 4 znacky v jednom riadku blokov
		inx	h
		mov	m,b
		inx	h
		mov	m,b
		inx	h
		mov	m,b
		dad	d		; prejdi na predchadzajuci riadok
		dcr	c
		jnz	MarkBlocksL	; opakuj
		ret

;------------------------------------------------------------------------------
; (9822h)
; Zmazanie spritov z VO2.
; Prakticky sa do VO2 nakopiruje obsah z VO1 v miestach, kde boli sprity
; vykreslene.
UndrawSpr:	lxi	h,SprListOrd	; zoznam zoradenych spritov
UndrawSprA:	mov	a,m 
		ana	a		; koniec zoznamu?
		rz			; ano, navrat
		inx	h		; preskoc znacku
		mov	e,m		; adresa struktury spritu do DE
		inx	h
		mov	d,m
		inx	h
		push	h		; adresa zoznamu na zasobnik
		xchg			; adresa struktury spritu do HL
		inx	h		; (1)
		inx	h		; (2)
		inx	h		; (3)
		mov	c,m
		inx	h		; (4)
		mov	b,m		; pozicia spritu vo VO2 do BC
		xchg
		lhld	SprOffZone	; offset pozicie spritov podla zony
		dad	b		; pripocitaj
		mov	a,h		; ak je cely sprite mimo VO2 (pred VO2)
		cpi	InnerScr2/256
		jc	UndrawSprD	; vynechaj ho
		mov	c,l		; адрес назначения do BC
		mov	b,h
		xchg
		mvi	a,5		; posun ukazatela na typ rutiny
		add	l
		mov	l,a		; (9) typ rutiny
;		lda	SprOffStep	; kroky naviac
;		add	m		; pripocitaj typ rutiny { 0, 1, 2 }
;		cpi	3		; ak je to viac ako 2
;		jc	UndrawSprB
;		sui	3		; uprav na spravnu hodnotu
;		inx	b		; a posun cielovu adresu
UndrawSprB:	mov	e,c		; a uloz do DE
		mov	d,b
		lxi	h,InnerScr-InnerScr2 ; offset pre navrat na VO1
		dad	b		; HL=pozicia spritu vo VO1

		lxi	b,HILO(255,24)	; vyska spritu 24
UndrawSprC:	mov	a,m		; prekopiruj jeden riadok
		stax	d		; pod spritom z VO1 do VO2
		inx	h
		inx	d
		mov	a,m
		stax	d
		inx	h
		inx	d
		mov	a,m
		stax	d
		inx	h
		inx	d
		mov	a,m
		stax	d
		mov	a,c
		mvi	c,-(3+SVO)	; presun na predosly mikroriadok
		dad	b		; vo VO1
		xchg
		dad	b		; vo VO2
		xchg
		mov	c,a
		dcr	c
		jnz	UndrawSprC
UndrawSprD:	pop	h		; obnov adresu zoznamu
		jmp	UndrawSprA	; pokracuj dalsim spritom

;------------------------------------------------------------------------------
; Перерисовать изменения без прерываний
RedrawChangesDI:
		di
		call	RedrawChanges
		ei
		ret

; Перерисовать изменения
RedrawChanges:
		lxi	h,RedrawList	; zoznam adries pre aplikovanie zmien
RedrawChangesA:	mov	a,m		; ширина в A
		ora	a
		rz
		inx	h
		mov	e,m		; адрес VO2 в DE
		inx	h
		mov	d,m
		inx	h
		push	d		; a na zasobnik
		mov	e,m		; адрес VRAM в DE
		inx	h
		mov	d,m
		inx	h
		mov	c,m		; adresa flagov zmien (vo VO1) do BC
		inx	h
		mov	b,m
		inx	h
		xthl			; HL=VO2, DE=VRAM, BC=флаги
RedrawChangesB:	push	psw		; sirka na zasobnik
		ldax	b		; берём флаг
		dcr	a		; нужна перерисовка?
		jm	RedrawChangesC	; нет, переходим
		stax	b		; a uloz novu hodnotu
		push	b		; сохраняем адрес флагов
		lxi	b,SVO		; смещение к следующей микро-строке в VO2
;
		mov	a,m		; байт из VO2
		stax	d		; пишем в VRAM
		dad	b		; сдвигаем на микро-строку в VO2
		dcr	e		; сдвигаем на микро-строку в VRAM
		mov	a,m
		stax	d		; 2
		dad	b
		dcr	e
		mov	a,m
		stax	d		; 3
		dad	b
		dcr	e
		mov	a,m
		stax	d		; 4
		dad	b
		dcr	e
		mov	a,m
		stax	d		; 5
		dad	b
		dcr	e
		mov	a,m
		stax	d		; 6
		dad	b
		dcr	e
		mov	a,m
		stax	d		; 7
		dad	b
		dcr	e
		mov	a,m
		stax	d		; 8
;
		lxi	b,-(7*SVO)	; adresa VO2 na povodnu hodnotu
		dad	b
		mov	a,e
		adi	7
		mov	e,a		; vyssi byte VRAM na povodnu hodnotu
		pop	b		; obnov adresu flagov
RedrawChangesC:	dcx	h		; posun na znakovu poziciu do prava
;		dcr	d		; следующий столбец в VRAM
		mov	a,d
		dcr	a
		ani	01Fh
		ori	BaseVramAdr/256
		mov	d,a
		dcx	b		; следующий байт флагов
		pop	psw
		dcr	a		; opakuj pre celu sirku
		jnz	RedrawChangesB
		pop	h		; obnov adresu zoznamu
		jmp	RedrawChangesA	; navrat do slucky

;------------------------------------------------------------------------------
; Список адресов, которые перерисовываются справа налево в рамках трека.
; Формат:
;   DB ширина в sesticiach,
;   DW адрес VO2, адрес VRAM, адрес флагов (MarkBuff)
RedrawList:	.db	10
		.dw	InnerScr2+(17*SVO8)+9,BaseVramAdr+HILO(2,(255-19*8)),MarkBuff+(17*SVO)+9
		.db	12
		.dw	InnerScr2+(16*SVO8)+11,BaseVramAdr+HILO(4,(255-18*8)),MarkBuff+(16*SVO)+11
		.db	14
		.dw	InnerScr2+(15*SVO8)+13,BaseVramAdr+HILO(6,(255-17*8)),MarkBuff+(15*SVO)+13
		.db	16
		.dw	InnerScr2+(14*SVO8)+15,BaseVramAdr+HILO(8,(255-16*8)),MarkBuff+(14*SVO)+15
		.db	18
		.dw	InnerScr2+(13*SVO8)+17,BaseVramAdr+HILO(10,(255-15*8)),MarkBuff+(13*SVO)+17
		.db	20
		.dw	InnerScr2+(12*SVO8)+19,BaseVramAdr+HILO(12,(255-14*8)),MarkBuff+(12*SVO)+19
		.db	22
		.dw	InnerScr2+(11*SVO8)+21,BaseVramAdr+HILO(14,(255-13*8)),MarkBuff+(11*SVO)+21
		.db	24
		.dw	InnerScr2+(10*SVO8)+23,BaseVramAdr+HILO(16,(255-12*8)),MarkBuff+(10*SVO)+23
		.db	26
		.dw	InnerScr2+(9*SVO8)+25,BaseVramAdr+HILO(18,(255-11*8)),MarkBuff+(9*SVO)+25
		.db	27
		.dw	InnerScr2+(8*SVO8)+26,BaseVramAdr+HILO(19,(255-10*8)),MarkBuff+(8*SVO)+26
		.db	27
		.dw	InnerScr2+(7*SVO8)+28,BaseVramAdr+HILO(21,(255-9*8)),MarkBuff+(7*SVO)+28
		.db	27
		.dw	InnerScr2+(6*SVO8)+31,BaseVramAdr+HILO(24,(255-8*8)),MarkBuff+(6*SVO)+31
		.db	25
		.dw	InnerScr2+(5*SVO8)+31,BaseVramAdr+HILO(24,(255-7*8)),MarkBuff+(5*SVO)+31
		.db	23
		.dw	InnerScr2+(4*SVO8)+31,BaseVramAdr+HILO(24,(255-6*8)),MarkBuff+(4*SVO)+31
		.db	21
		.dw	InnerScr2+(3*SVO8)+31,BaseVramAdr+HILO(24,(255-5*8)),MarkBuff+(3*SVO)+31
		.db	19
		.dw	InnerScr2+(2*SVO8)+31,BaseVramAdr+HILO(24,(255-4*8)),MarkBuff+(2*SVO)+31
		.db	17
		.dw	InnerScr2+(1*SVO8)+31,BaseVramAdr+HILO(24,(255-3*8)),MarkBuff+(1*SVO)+31
		.db	15
		.dw	InnerScr2+(0*SVO8)+31,BaseVramAdr+HILO(24,(255-2*8)),MarkBuff+(0*SVO)+31
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
InitSpr:	lxi	h,SprListVL+6
		lxi	d,14		; Главный Vorton
		mvi	b,5
InitSprA:	mov	m,d		; (6) тип спрайта
		mvi	a,4
		add	l
		mov	l,a
		mov	m,e		; (10) offset pre urcenie sekvencie spritu
		mvi	a,12
		add	l
		mov	l,a		; (6) dalsia struktura spritu
		lxi	d,HILO(10h,13)	; Auto-Vorton'ы
		dcr	b
		jnz	InitSprA
		mvi	a,0FFh
		sta	SprPrepList	; vyprazdni zoznam pripravenych spritov
		lxi	h,SprList	; zoznam vsetkych spritov
		mvi	b,249		; 249 структур спрайтов
InitSprB:	push	b		; odpamataj pocitadlo
		push	h		; odpamataj adresu struktury (zoznamu)
		push	h		; odpamataj adresu struktury (zoznamu)
		mvi	a,6
		add	l
		mov	l,a
		mov	a,m		; (6) код спрайта
		ani	0Fh		; odmaskuj iba zakladny kod
		cpi	11		; maximalny kod je 10
		jc	InitSprC
		mvi	a,8		; kody mimo rozsah nastav na 8 - SprBrickB
		mov	m,a
InitSprC:	xchg
		lxi	h,InitSprData	; inicializacne data
		lxi	b,22		; offset na init. data pre druhu skupinu
		ldax	d		; (6) kod spritu
		ani	10h		; prva skupina spritov?
		jz	InitSprD	; ano, skoc dalej
		dad	b		; HL=init data pre druhu skupinu
InitSprD:	ldax	d
		ani	0Fh		; odmaskuj zakladny kod
		add	a		; *2 - 2 inicializacne byty
		mov	c,a		; uloz do BC
		dad	b		; HL=init data pre tento sprite
		dcx	d		; (5)
		mov	a,m		; offset do zoznamu spritov
		stax	d		; (5) uloz do struktury spritu
		mvi	a,6
		add	e
		mov	e,a		; (11)
		inx	h
		mov	a,m		; offset do zoznamu "obsluznych" rutin
		stax	d		; (11) uloz do struktury spritu
		xchg
		inx	h		; (12)
		mov	c,m		; inic. hodnota sekvencie/otocenia spritu
		inx	h		; (13)
		pop	d		; (0) obnov adresu struktury
		mov	a,m		; (13) -> (0)
		stax	d		;  - posun na posledne 3 byty
		inx	h		;    presun posledne 3 byty na zaciatok,
		inx	d		;    kde je pociatocna pozicia spritu
		mov	a,m		; (14) -> (1)
		stax	d
		inx	h
		inx	d
		mov	a,m		; (15) -> (2)
		stax	d
		mvi	a,-9
		add	l
		mov	l,a		; (6)
		mov	b,m		; typ spritu
		inx	h		; (7)
		mov	a,c
		ani	7
		mov	m,a		; (7) sekvencia spritu (otocenie)
		inx	h		; (8)
		mov	a,m		; (8) aktualna rychlost spritu
		cpi	5		; ak je >=5,
		jnc	InitSprE	; skoc, ju vynulovat
		mov	a,b		; typ spritu
		ani	0Fh		; vynuluj bit druhej skupiny spritov
		cpi	9		; ak je to Lasertron,
		jnc	InitSprE	; skoc vynulovat rychlost
		ana	a		; a tiez pre Vortona a AutoVortony
		jnz	InitSprF	; pre ostatne sprity rychlost nemen
InitSprE:	mvi	m,0		; (8) vynuluj rychlost pre vybrane sprity
InitSprF:	dcx	d		; (1)
		dcx	d		; (0)
		ldax	d		; (0) vezmi suradnicu Y
		cpi	0FEh		; ak je to neaktivny sprite,
		jnc	InitSprG	; skoc spracovat dalsi sprite
		mov	c,a		; Y do BC
		mvi	b,0
		inx	d		; (1) - XL
		ldax	d
		mov	l,a
		inx	d		; (2) - XH
		ldax	d
		mov	h,a		; X do HL
		inx	d		; (3)
		push	d		; odpamataj ukazatel do struktury
		; vypocitaj adresu do VO2
		push	h		; odpamataj X
		push	b		; odpamataj Y
		dad	b		; HL = X + Y
		mov	a,h		; Hl = HL / 2
		ora	a		; CY=0
		rar
		mov	h,a
		mov	a,l
		rar
		mov	l,a
		dad	h		; *2
		dad	h		; *4
		dad	h		; *8
		dad	h		; *16
		dad	h		; *32
		xchg			; DE = ((X + Y) / 2) * 32
		lxi	h,InnerScr2+13A3h ;TODO было =0BFFCh
		call	SubHLDE		; HL = 0BFFCh - (((X + Y) / 2) * 32)
		pop	d		; obnov Y do DE
		xthl			; medzivysedok na zasobnik, HL=X
		call	SubHLDE		; HL = X - Y
		mvi	d,8
		call	Div16x8		; HL = (X - Y) / 8, A = (X - Y) MOD 8
		pop	d		; obnov medzivysledok a pripocitaj
		dad	d		; HL = (0BFFCh - (((X + Y) / 2) * 32)) + ((X - Y) / 8)
		xchg			; premiestni vysledok do DE
		pop	h		; obnov ukazatel do struktury
		mov	m,e		; (3) a uloz vysledok do struktury
		inx	h		; (4)
		mov	m,d
		rar			; A = ((X - Y) MOD 8) / 2
		mov	c,a		; typ zobrzovacej rutiny do C {0, 1, 2, 3}
		mvi	a,5
		add	l
		mov	l,a		; (9)
		mov	m,c		; uloz (0, 1, 2, 3)
InitSprG:	pop	h		; obnov adresu struktury
		lxi	b,16		; offset na dalsiu strukturu
		dad	b		; prejdi na dalsiu
		pop	b		; obnov pocitadlo
		dcr	b		; opakuj pre vsetky sprity
		jnz	InitSprB
		ret

;------------------------------------------------------------------------------
PrepSpr:	xra	a
		sta	SprListOrd	; vyprazdni zoznam zoradenych spritov
; do hlavneho zoznamu vrat sprity, ktore boli v predoslom "frame"
		lxi	h,SprPrepList	; zoznam pripravenych spritov
		mvi	c,14
PrepSprA:	mov	a,m		; znacka (suradnica Y)
		cpi	0FFh		; je to koniec zoznamu?
		jz	PrepSprZ	; ano, skoc dalej
		push	h
		mov	a,l
		add	c
		mov	l,a		; (14)
		mov	e,m		; адрес назначения povodnej struktury
		inx	h		; spritu do DE
		mov	d,m
		inx	h		; (0)
		xthl			; адрес источника do HL
		mvi	b,13		; 13 bytov struktury
		call	Copy8		; prekopiruj
		pop	h		; prejdi na dalsiu strukturu
		jmp	PrepSprA

; найти правильную зону в соответствии с текущей позицией Vorton и инициализировать соответствующие переменные
PrepSprZ:	lhld	VortonStruct	; adresa struktury aktualneho hlavneho
		inx	h		;  Vortona
		mov	c,m		; X координаты положения в DE
		inx	h
		mov	b,m
		mov	a,b		; ak je pozicia < 0B0h,
		ana	a
		jnz	PrepSprB
		mov	a,c
		cpi	0B0h
		jnc	PrepSprB
		dcx	h
		mvi	c,0B0h		; nastav ju na 0B0h
		mov	m,c
PrepSprB:	mvi	a,1		; номер зоны 1 (до 36)
		lxi	d,07F0h		; offset adresy VO2 pre sprity
		lxi	h,00B0h		; pociatocna pozicia v zone
PrepSprC:	push	psw		; odpamataj pocitadlo
		push	b		; odpamataj aktualnu poziciu Vortona
					; od aktualnej pozicie Vortona odpocitaj
		call	SubBCHL		; pociatocnu poziciu v zone
;		mov	a,b		; ak je rozdiel < 0B0h, Vorton je
;		ana	a		; v tejto Zone
		jnz	PrepSprD
		mov	a,c
		cpi	0B0h
		jc	PrepSprE	; a tak skoc dalej
PrepSprD:	lxi	b,0B0h		; posun sa do dalsej zony
		dad	b
		xchg
		lxi	b,0AEAh		; aj offset vo VO2
		dad	b
		xchg
		pop	b		; obnov aktualnu poziciu Vortona
		pop	psw		; obnov cislo Zony
		inr	a		; cislo zony +1
		jmp	PrepSprC

PrepSprE:	pop	b		; zahod jednu polozku zasobnika
		shld	ZonePos		; исходное положение в зоне
		lxi	b,0FFD0h	; -30h
		dad	b		; обратный отсчет области перед границей зоны
		shld	ZonePosQ	; uloz
		lxi	b,0FF80h	; -80h
		dad	b		; обратный отсчет до начала предыдущей зоны
		shld	ZonePosP	; uloz

		pop	b		; obnov cislo Zony do B
;		mov	a,b		; a uloz do A
;		add	a		; к каждой зоне добавляются 2 шага
;		dcr	a		; okrem prvej
;PrepSprH:	sui	3
;		jc	PrepSprI
;		inx	d		; po 3 krokoch je to jedna sestica
;		jmp	PrepSprH

;PrepSprI:	adi	3
;		sta	SprOffStep	; дополнительное смещение в шагах
		xchg
		shld	SprOffZone	; offset pozicie spritov podla zony

		; priprav cislo zony a zobraz ho
		mov	a,b		; cislo Zony do A
		sta	ZoneNumberT	; uloz
		lxi	h,ZoneNumber	; adresa premennej cislo zony 1 az 31
		cpi	32		; ak je to < 32
		jc	PrepSprF	; skoc dalej
		mvi	a,32		; uloz maximum 32
		mov	m,a
		dcr	a		; a uprav na 31
		jmp	PrepSprG

PrepSprF:	mov	m,a		; uloz cislo miestnosti
PrepSprG:	call	PrintZoneNum

		; подготовить новый список спрайтов
		lxi	h,SprList	; adresa zoznamu vsetkych struktur spritov
		lxi	d,SprPrepList	; adresa zoznamu pripravenych spritov
		lxi	b,44		; макс. 44 объекта
PrepSprK:	mov	a,m		; Y suradnica
		cpi	0FEh		; je to neaktivny sprite?
		jnc	PrepSprL	; ano, skoc dalej
		push	h
		push	d
		inx	h		; (1)
		mov	e,m		; X pozicia spritu do HL
		inx	h		; (2)
		mov	d,m
		lhld	ZonePosP	; pozicia predoslej zony
		xchg
		call	SubHLDE		; odpocitaj
;		mov	a,h		; ak sa tento sprite nachadza dalej, ako
		pop	d
		pop	h
		cpi	2		; 1 zonu pred a 1 zonu za aktualnou zonou,
		jnc	PrepSprL	; skoc dalej
		push	h
		mvi	b,14		; prenos 14 bytov struktury
		call	Copy8
		pop	h
		mov	a,l		; na koniec pridaj samotnu adresu
		stax	d		; struktury
		inx	d
		mov	a,h
		stax	d
		inx	d
		dcr	c		; zniz pocitadlo
		jz	PrepSprM	; skoc, ak je zoznam plny
PrepSprL:	mov	a,c
		mvi	c,16		; prejdi na dalsiu strukturu
		dad	b
		mov	c,a
		mov	a,h		; presli sa vsetky?
		cpi	SprListVL/256
		jc	PrepSprK	; nie, pokracuj dalsou
PrepSprM:	mvi	a,0FFh		; ukonci zoznam
		stax	d

		; deaktivuj sprity "Vybuch"
		lxi	h,SprList+5	; adresa zoznamu vsetkych struktur spritov
		lxi	d,HILO(80h,0E0h)
		lxi	b,16		; velkost struktury
PrepSprN:	mov	a,m		; (5) je to sprite "Vybuch"?
		cmp	d
		jc	PrepSprO	; nie, skoc dalej
		cmp	e
		jnc	PrepSprO	; nie, skoc dalej
		inx	h		; (6)
		inx	h		; (7)
		inx	h		; (8)
		mov	a,m		; zrus flag rychlosti
		ani	7Fh
		mov	m,a
		mvi	a,-8
		add	l
		mov	l,a		; (0)
		mvi	m,0FEh		; deaktivuj sprite
		mvi	a,5
		add	l
		mov	l,a		; (5)
PrepSprO:	dad	b		; dalsi sprite
		mov	a,h		; presli sa vsetky?
		cpi	SprListVL/256
		jc	PrepSprN	; nie, pokracuj dalsou
		ret

;------------------------------------------------------------------------------
; Zoradenie spritov podla IZO hlbky.
SortSpr:	lxi	h,SprListOrd	; koncova adresa zoznamu zoradenych
		shld	SprListOrdEnd	;  spritov uloz
		mvi	m,0		; vyprazdni zoznam
		lhld	VortonStruct	; zaciatok zoznamu spritov do IX
SortSprA:	mov	a,m		; Y pozicia spritu
		cpi	0FEh		; je to neaktivny sprite?
		jz	SortSprF	; ano, preskoc ho
		rnc			; koniec zoznamu, navrat
		mov	b,a		; Y pozicia do B
		push	h
		mvi	a,6
		add	l
		mov	l,a		; (6) - typ spritu
		mov	a,m		; typ spritu do A
		cpi	16h		; je to drsny povrch (Rough)?
		jz	SortSprG	; ano, preskoc ho
		cpi	19h		; je to tehla (BrickA)?
		jz	SortSprG	; ano, preskoc ho
		mvi	a,-4
		add	l
		mov	l,a		; (2) - XH
		mov	d,m
		dcx	h		; (1) - XL
		mov	e,m		; X pozicia do DE
		lhld	ZonePosQ	; pozicia zony do HL
		xchg			; zamen
		call	SubHLDE		; porovnj pozicie
;		ora	a		; nachadza sa tento sprite v aktualnej zone?
		jnz	SortSprG	; ak nie, preskoc ho
		mov	a,b		; offset od zaciatku zony (X)
		rar
		mov	b,a		; Y=Y/2
		ora	a
		mov	a,l
		rar			; X=X/2
		add	b
		inr	a		; Z=X/2+Y/2+1
		lxi	h,SprListOrd	; najdi v zozname miesto kam patri
SortSprB:	cmp	m		; tento sprite podla Z
		jnc	SortSprC	; skoc, ak patri tu
		inx	h		; prejdi na dalsiu polozku v zozname 
		inx	h
		inx	h
		jmp	SortSprB

SortSprC:	push	psw		; odpamataj Z spritu
		xra	a		; patri aktualny sprite na koniec
		cmp	m		;  zoznamu?
		jnz	SortSprD	; nie, skoc dalej
		xchg
		lhld	SprListOrdEnd	; adresa konca zoznamu do HL
		inx	h		; posun ukazatel konca zoznamu
		inx	h
		inx	h
		shld	SprListOrdEnd	; a uloz
		mov	m,a		; a uloz koncovu znacku
		xchg
		jmp	SortSprE	; skoc ulozit refeenciu na sprite

; sprite treba vlozit do zoznamu, takze treba cast zoznamu presunut
SortSprD:	push	h		; odpamataj cielovu adresu v zozname
		xchg
		lhld	SprListOrdEnd	; adresa konca zoznamu do HL
		mov	a,l		; vypocitaj dlzku presuvanej casti
		sub	e		;  zoznamu do BC
		mov	c,a
		inr	c		; +1 pre koncovu znacku
		mov	e,l		; HL=адрес источника presunu
		inx	h
		inx	h
		inx	h		; DE=адрес назначения presunu
		shld	SprListOrdEnd	; uloz ako novu koncovu adresu zoznamu
SortSprH:	ldax	d		; presun cas zoznamu odzadu
		mov	m,a
		dcx	d
		dcx	h
		dcr	c
		jnz	SortSprH
		pop	h		; obnov cielovu adresu pre sprite
SortSprE:	pop	psw		; obnov Z spritu
		pop	d		; adresa strktury spritu do DE
		push	d
		mov	m,a		; uloz Z spritu
		inx	h
		mov	m,e		; a uloz ju do zoznamu
		inx	h
		mov	m,d
SortSprG:	pop	h
SortSprF:	lxi	d,16		; jedna struktura spritu ma 16 bytov
		dad	d		; dalsia struktura
		jmp	SortSprA	; spracuj ju

;------------------------------------------------------------------------------
