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
StartGame:	call	CheckScore	; porovnaj Score/HiScore a aktualizuj HI
		lxi	h,Score		; vynuluj Skore
		lxi	b,HILO(6,10)
ZeroScore:	mov	m,c
		inx	h
		dcr	b
		jnz	ZeroScore
		mov	m,b
		call	PrintScore	; zobraz Score

		call	InitSpdLvl	; inicializuj uroven rychlosti na 0
PlayAgain:	call	Intro		; uvodne intro

	#if CheatZone0
		lxi	h,SprStructV1+1
		lxi	d,14E8h
		mov	m,e
		inx	h
		mov	m,d
		inx	h
		lxi	d,0FEF0h
		mov	m,e
		inx	h
		mov	m,d
		inx	h		; (5)
		inx	h		; (6)
		inx	h		; (7)
		inx	h		; (8)
		inx	h		; (9)
		mvi	m,0

		lxi	h,SprStructLT+1
		lxi	d,14D8h
		mov	m,e		; (1)
		inx	h
		mov	m,d		; (2)
		inx	h
		lxi	d,0045h
		mov	m,e		; (3)
		inx	h
		mov	m,d		; (4)
		inx	h		; (5)
		inx	h		; (6)
		inx	h		; (7)
		inx	h		; (8)
		inx	h		; (9)
		mvi	m,1

		jmp	CheatJ
	#endif

; * hlavna slucka hry *
		; ukoncenie hry
GameLoop:	;mvi	a,4		; test klavesov T+G - ukoncenie hry
		;out	SysPA
		;in	SysPB		; precitaj stav
		;ani	0Ch		; su stlacene sucasne?
		;jnz	PauseMode	; nie, skoc dalej
		;inr	a		; nastav flag prerusenia hry
		;sta	Aborted
		;lxi	h,TAborted	; adresa textu "MISSION ABORTED"
		;jmp	Print85Text	; zobraz text a vrat sa do menu

		; pozastavenie hry
;PauseMode:	mvi	a,5		; test klavesu H - Hold
;		;out	SysPA
;		;in	SysPB		; precitaj stav
;		ani	8		; je stlaceny?
;		jnz	GameFrame	; nie, skoc dalej
;		;lxi	h,TPauseMode	; text "PAUSE MODE, PRESS L TO LEAVE"
;		;call	Print85Text	; zobraz text

;		lxi	h,MarkBuff+(8*SVO)+13 ; oznac miesto, ktore zakryva tento
;		lxi	b,HILO(17,2)	;  text, ze ho bude treba prekreslit z VO1
;PauseModeA:	mov	m,c
;		inx	h
;		dcr	b
;		jnz	PauseModeA
;		lxi	h,MarkBuff+(9*SVO)+9
;		mvi	b,25
;PauseModeA2:	mov	m,c
;		inx	h
;		dcr	b
;		jnz	PauseModeA2

;PauseModeB:	mvi	a,5		; test klavesu H - Hold
;		;out	SysPA
;		;in	SysPB		; precitaj stav
;		ani	8		; je uz uvolneny?
;		jz	PauseModeB	; nie, cakaj na uvolnenie

;PauseModeC:	mvi	a,8		; test klavesu L - ukoncenie Hold
;		;out	SysPA
;		;in	SysPB		; precitaj stav
;		ani	8		; je stlaceny?
;		jnz	PauseModeC	; nie, cakaj
;PauseModeD:	mvi	a,5		; test klavesu L - ukoncenie Hold
;		;out	SysPA
;		;in	SysPB		; precitaj stav
;		ani	8		; je stlaceny?
;		jz	PauseModeD	; ano, cakaj na uvolnenie

		; vykonanie jedneho frejmu (kroku)
GameFrame:	call	UndrawSpr	; zmaz sprity z VO2
		call	TestKbdJoy	; otestuj kbd/joy
		call	ProcMove	; spracuj posuny podla stavu klaves
		call	ProcSpr		; spracuj pohyb spritov a ich kolizie
		call	SortSpr		; zorad sprity podla IZO hlbky
		call	DrawSpr		; vykresli sprity
		call	RedrawChanges	; prekresli zmeny
		call	LTronMove	; zobraz posun LaserTronu na panely
		call	Sound		; spracuj zvuky

		; cakanie na LaserTron v Zone 0
		lda	ZoneNumber	; cislo zony
		cpi	30		; ak to nie je zona 0,
		jc	DecTime		; skoc dalej
		lxi	h,SprStructLT+1	; adresa struktury LaserTronu
		mov	e,m		; pozicia LT DE
		inx	h
		mov	d,m
		lxi	b,156Ch		; pozicia v Zone 0
		call	SubDEBC		; porovnaj, ci uz LT prisiel do Zony 0
		jz	LTronZone0	; ak ano, skoc dalej

		; dekrement casu
DecTime:	lhld	TimeDelay	; zdrzanie na jeden dielik casu
	#if ~~CheatNoTime
		dcx	h		; zniz
	#endif
		mov	a,l		; je nulovy?
		ora	h
		jnz	DecTimeE	; nie, skoc ulozit novu hodnotu
		lda	TimePos		; znakovy stlpec dielika casu
		rar			; vydel /2 - CY=1 pre dvojdielik
		mov	e,a		; do E
		mvi	d,26		; riadok pre TIME
		jc	DecTimeB	; pre dvojdielik, skoc dalej
		xra	a		; medzera
		call	Print88		; zmaz jednodielik
		dcr	e		; zniz znakovy stlpec na povodny
		stc			; CY=1 pre dvojdielik
		jmp	DecTimeC

DecTimeB:	mvi	a,26		; jednodielik
		call	Print88		; zobraz jednodielik
DecTimeC:	dcr	e		; zniz znakovy stlpec na predchadzajuci
		mov	a,e		; do A
		ral			; pripoj CY do 0. bitu
		sta	TimePos		; a uloz novu hodnotu
		cpi	19*2		; bol to uz posledny dielik casu?
		jnc	DecTimeD	; nie, skoc dalej
		; cas vyprsal ...
		lxi	h,TTooLate	; text "TOO LATE, MISSION TERMINATED"
		jmp	Print85Text	; skoc zobrazit text a ukoncit hru

DecTimeD:	lxi	h,3500		; inicializuj zdrzanie pre dalsi dielik casu
DecTimeE:	shld	TimeDelay	; uloz novu hodnotu zdrzania

		; test na stratu Vortona
		lhld	VortonStruct	; adresa struktury aktualneho Vortona
		mov	a,m		; nastala strata Vortona?
		cpi	0FEh
		jc	GameLoop	; nie, vrat sa do hlavnej hernej slucky

		lda	VortonHead	; znakovy stlpec hlavy akt. Vortona na panely
		mov	e,a		; uloz do E
LostVorton:	lxi	b,16		; offset na dalsiu strukturu
LostVortonA:	dad	b		; prejdi na nasledujuceho Vortona
		inr	e		; posun znakovy stlpec na dalsiu "hlavu"
		inr	e
		mov	a,l		; presli sme uz vsetkych Vortonov 
		cpi	SprStructLT&255
		jc	LostVortonB	; nie, skoc dalej
		; koniec hry
		lxi	h,TGameOver	; text "GAME OVER, ALL VORTONS DESTROYED"
		jmp	Print85Text	; zobraz text a ukonci hru

LostVortonB:	mov	a,m		; je to aktivny sprite (Vorton)?
		cpi	0FEh
		jnc	LostVortonA	; nie, skoc skusit dalsieho
		shld	VortonStruct	; uloz novu adresu aktualneho Vortona
		mvi	a,8
		add	l
		mov	l,a		; (8) - rychlost pohybu spritu
		mov	a,m		; je Vorton aktivny?
		ora	a
		jm	LostVortonA	; nie, skoc skusit dalsieho
		mov	a,e		; uloz aktualnu poziciu
		sta	VortonHead	; aktivneho Vortona na panely
		mvi	d,20		; znakovy riadok hlavy Vortona
		mvi	a,29		; zobraz hlavu pre noveho aktualneho
		call	Print88		; Vortona
		mvi	a,30
		call	Print88
		dcr	l		; (7)
		dcr	l		; (6) - "kod" spritu
		mov	a,m		; urob z AutoVortona (10h) Vortona (00h)
		ani	0Fh
		mov	m,a
		dcr	l		; (5) - sekvencia spritu
		mvi	m,0		; vynuluj sekvenciu
		mvi	a,5		; presun ukazatel v strukture
		add	l
		mov	l,a		; (10) - offset do zozamu pre urcenie sekvencie spritu
		mvi	m,0Eh		; nastav na Seq0E
CheatJ:		call	PrepSpr		; priprav sprity
		call	DrawZone	; vykresli Zonu
		jmp	GameLoop	; vrat sa do hernej slucky

;------------------------------------------------------------------------------
; Демонстрационный режим.
; Zobrazi Intro - prichod Vortona a Auto-Vortonov.
; Ukaze vsetky Zony 30 az 0.
Demo:		call	Intro		; uvodne intro
	#if DebugDemoLvl == -1
		jmp	DemoB
	#else
		lxi	h,SprStructV5+8	; zastav posledneho Vortona
		mvi	m,0
		lhld	VortonStruct	; adresa struktury aktualneho Vortona
		mvi	m,0FEh		; deaktivuj ho
		inr	l
		inr	l
		lxi	d,(31-DebugDemoLvl)*0B0h
		jmp	DemoX
	#endif

DemoA:		call	PrepSpr		; priprav sprity
		call	DrawZone	; vykresli dalsiu Zonu
DemoB:		lxi	h,TDemoMode	; text "DEMO MODE"
		call	Print85Text	; zobraz text

		mvi	b,40		; 40 krokov
DemoC:		push	b		; odpamataj pocitadlo
		call	OneStep		; vykonaj krok
		pop	b		; obnov pocitadlo
		;in	SysPB		; bol stlaceny Stop/Shift?
		cma
		ani	60h
		rnz			; ano, vrat sa
		dcr	b
		jnz	DemoC		; opakuj pre dany pocet framov

		lda	ZoneNumber	; cislo zony
	#if DebugDemoLvl == -1
		cpi	1Fh		; sme v zone 0?
	#else
		cpi	25h
	#endif
		jnc	DemoD		; ano, skoc dalej
		lxi	h,SprStructV5+8	; zastav posledneho Vortona
		mvi	m,0
		lhld	VortonStruct	; adresa struktury aktualneho Vortona
		mvi	m,0FEh		; deaktivuj ho
		inr	l
		mov	e,m		; jeho pozicia
		inr	l
		mov	d,m
		xchg			;  do HL
		lxi	b,0B0h		; posun ho do dalsej miestnosti
		dad	b
		xchg
DemoX:		mov	m,d		; a uloz do struktury
		dcr	l
		mov	m,e
		jmp	DemoA

DemoD:		lxi	h,InnerScr	; vymaz VO
		lxi	b,VVO*SVO
		call	Fill16Z

		lxi	h,InnerScr	; vykresli oramovanie
		lxi	d,InnerScr+(143*SVO)
		mvi	c,VVO-2		; vyska mriezky -2
		call	DrawBord

 		mvi	l,VVO		; vykresli do VRAM
		lxi	d,InnerScr
		lxi	b,BaseVramAdr
		call	DrawInnerScr

		lxi	h,TOneWay	; text "THERE IS ONLY ONE WAY..."
		call	Print85Text	; zobraz text
		jmp	WaitAnyKeyT10

;------------------------------------------------------------------------------
ShowPanel:	call	Cls			; zmazanie obrazovky

	#if UsePackedGrp
		lxi	h,GamePanel		; rozpakovanie panelu
		lxi	d,0C000h-GamePaneSize
		call	dzx7
		lxi	h,BaseVramAdr+(152*64)+1	; vykreslenie panelu
		lxi	d,0C000h-GamePaneSize
		lxi	b,HILO(41,35)
		call	DrawSprite
	#else
		lxi	h,BaseVramAdr+(256-184)	; vykreslenie panelu
		lxi	d,GamePanel
		lxi	b,HILO(32,34)
		call	DrawSprite
	#endif

		lxi	d,HILO(24,19)		; AT 24,19
		lxi	h,HILO(4,21)		; zobraz POWER symboly
ShowPanelP:	mov	a,l
		call	Print88
		inr	l
		dcr	h
		jnz	ShowPanelP

		lxi	d,HILO(26,19)		; AT 26,19
		lxi	h,HILO(4,25)		; zobraz casove jednotky
ShowPanelT:	mov	a,l
		call	Print88
		dcr	h
		jnz	ShowPanelT

		call	PrtScore		; zobraz Score a HiScore
		jmp	PrtHiScore

;------------------------------------------------------------------------------
; Начальная анимация
; - iniciaizacia premennych
; - zobrazenie panelu a Zony 30
; - prichod Vortonov a Lasetronu
Intro:		lxi	h,BackupVars	; inicializuj pociatocne hodnoty
		lxi	d,Vars		; premennych
		mvi	b,VarsLen
		call	Copy8
		call	ShowPanel	; zmaz obr. a zobraz dolny panel
		call	InitSpr		; inicializuj sprity
		call	PrepSpr		; priprav sprity
		call	DrawZone	; vykresli Zonu 30
		mvi	a,0FFh		; vyprazdni zoznam aktivnych spritov
		sta	SprPrepList

		mvi	a,1		; aktivuj pohyb hlavneho Vortona
		sta	SprStructV1+8
		xra	a		; ziadna zmena rychlosti a otocenia
		mvi	b,16		; 16 krokov
		call	AutoStep	; vykonaj
IntroA:		mvi	a,5		; FLRUD - zabrzdi Vortona a otacaj doprava
		mvi	b,1		; jeden krok
		call	AutoStep	; vykonaj
		sui	6		; otacaj Vortona, kym nebude otoceny
		jnz	IntroA		;  na Sever
		inr	a		; aktivuj pohyb hlavneho Vortona
		sta	SprStructV1+8
		xra	a		; ziadna zmena rychlosti a otocenia
		mvi	b,14		; 14 krokov
		call	AutoStep	; vykonaj
IntroB:		mvi	a,4		; FLRUD - otacaj Vortona doprava
		mvi	b,1		; 1 krok
		call	AutoStep	; vykonaj
		ana	a		; otacaj, kym nebude otoceny na vychod
		jnz	IntroB
IntroC:		mvi	a,5		; FLRUD - zabrzdi Vortona a otacaj doprava
		mvi	b,1		; 1 krok
		call	AutoStep	; vykonaj
		cpi	3		; otacaj Vortona, kym nebude otoceny
		jnz	IntroC		;  na Juho-Zapad
		lxi	h,SprStructV2+8	; aktivuj pohyb Auto-Vortonov
		lxi	d,16
		lxi	b,HILO(4,1)	; 4 Auto-Vortoni
IntroD:		mov	m,c
		dad	d
		dcr	b
		jnz	IntroD
		xra	a		; ziadna zmena rychlosti a otocenia
		mvi	b,39		; 39 krokov
		call	AutoStep	; vykonaj
		lxi	h,SprStructV2+7 ; zmen smer pohybu Auto-Vortonov
		lxi	d,16
		lxi	b,HILO(7,1)
		mov	m,b		; Severo-Vychod
		dad	d
		mov	m,c		; Juho-Vychod
		dad	d
		mov	m,b		; Severo-Vychod
		dad	d
		mov	m,c		; Juho-Vychod
		xra	a		; ziadna zmena rychlosti a otocenia
		mvi	b,12		; 12 krokov
		call	AutoStep	; vykonaj
		lxi	h,SprStructV2+7 ; zastav Auto-Vortonov a nastav smer 
		lxi	d,15		;  pohybu na Vychod
		mvi	b,4
IntroE:		mov	m,d		; smer na Vychod
		inx	h
		mov	m,d		; zastav pohyb
		dad	d
		dcr	b
		jnz	IntroE
IntroF:		mvi	a,9		; FLRUD - zabrzdi Vortona a otacaj dolava
		mvi	b,1		; 1 krok
		call	AutoStep	; vykonaj
		dcr	a		; otacaj Vortona, kym nebude otoceny
		jnz	IntroF		;  na Juho-Vychod
		inr	a		; aktivuj pohyb hlavneho Vortona
		sta	SprStructV1+8
		xra	a		; ziadna zmena rychlosti a otocenia
		mvi	b,32		; 32 krokov
		call	AutoStep	; vykonaj
IntroG:		mvi	a,9		; FLRUD - zabrzdi Vortona a otacaj dolava
		mvi	b,1		; 1 krok
		call	AutoStep	; vykonaj
		ana	a		; otacaj Vortona, kym nebude otoceny
		jnz	IntroG		;  na Vychod
		lxi	h,SprStructV2+8	; aktivuj pohyb Auto-Vortonov
		lxi	d,16
		lxi	b,HILO(4,1)	; 4 Auto-Vortoni
IntroH:		mov	m,c
		dad	d
		dcr	b
		jnz	IntroH

		jmp	PrepSprZ	; priprav sprity

;------------------------------------------------------------------------------
; Автоматический шаг Vorton в нужном направлении.
; I: A=maska smeru/otacania Vortona, B=pocet krokov
; O: A=aktualne otocenie Vortona
AutoStep:	sta	KbdState	; - FLRUD
AutoStepL:	push	b		; odpamataj pocitadlo
		call	UndrawSpr	; zmaz sprity z VO2
		call	ProcMove	; spracuj posuny podla stavu klaves
		call	ProcSpr		; spracuj pohyb spritov a ich kolizie
		call	SortSpr		; zorad sprity podla IZO hlbky
		call	DrawSpr		; vykresli sprity
		call	RedrawChanges	; prekresli zmeny
		call	LTronMove	; zobraz posun LaserTronu na panely
		call	Sound		; spracuj zvuky
		pop	b		; obnov pocitadlo
		dcr	b
		jnz	AutoStepL	; opakuj pre pozadovany pocet krokov
		lda	SprStructV1+7	; aktualne otocenie Vortona do A
		ret

;------------------------------------------------------------------------------
OneStep:	call	UndrawSpr	; zmaz sprity z VO2
		call	ProcSeq		; spracuj zmeny sekvencii spritov
		call	ProcSpr		; spracuj pohyb spritov a ich kolizie
		call	SortSpr		; zorad sprity podla IZO hlbky
		call	DrawSpr		; vykresli sprity
		call	RedrawChanges	; prekresli zmeny
		call	LTronMove	; zobraz posun LaserTronu na panely
		jmp	Sound		; spracuj zvuky

;------------------------------------------------------------------------------
LTronZone0:	mvi	b,5		; deaktivuj vsetkych zostavajucich
		lxi	h,SprListVL	; Vortonov
DeactVortA:	mov	a,m		; je to aktivny Vorton?
		cpi	0FEh
		jnc	DeactVortB	; nie, skoc dalej
		mvi	a,5
		add	l
		mov	l,a		; (5)
		mvi	m,80h		; nastav sprite SprBlast
		inr	l		; (6)
		inr	l		; (7)
		inr	l		; (8)
		mov	a,m
		ori	80h		; deaktivuj ho - vybuchne
		mov	m,a
		mvi	a,-8
		add	l
		mov	l,a		; (0)
		lxi	d,SndType	; premenna pre naplanovanie zvuku
		ldax	d
		ori	1<<6		; "naplanuj" zvukovy efekt vybuch
		stax	d
		push	b
		push	h
		mvi	b,100		; zvys Score o 1000 bodov
		call	IncScore
		pop	h
		pop	b
DeactVortB:	lxi	d,16		; posun na dalsiu strukturu
		dad	d
		dcr	b
		jnz	DeactVortA	; opakuj pre vsetkych Vortonov
		mvi	a,8
		add	l
		mov	l,a		; (8)
		mov	m,b		; aktivuj Lasertron
		mvi	b,24		; 24 krokov
		xra	a		; ziadna zmena rychlosti a otocenia
		call	AutoStep	; vykonaj
		lxi	h,SprStructLT	; nastav Lasertron
		shld	VortonStruct	; ako aktualny Vorton sprite
		mvi	b,15		; 15 krokov
		xra	a		; ziadna zmena rychlosti a otocenia
		call	AutoStep	; vykonaj

		; zmazanie hornej casti panelu s cislami Vortonov
		lxi	h,BaseVramAdr+(155*64)+9
		lxi	d,64-12
		mvi	c,5		; vyska 5 mikroriadkov
CleanPanelA:	mvi	b,12		; sirka 12 znakovych stlpcov
CleanPanelB:	mov	m,d		; vymaz
		inx	h
		dcr	b
		jnz	CleanPanelB	; opakuj
		dad	d		; prejdi na dalsi mikroriadok
		dcr	c		; opakuj pre vsetky mikroriadky
		jnz	CleanPanelA

		; skrytie Lasertronu na Panely
		lxi	h,BaseVramAdr+(173*64)+21
		lxi	d,64-2
		mvi	c,10		; vyska 10 mikroriadkov
CleanPanelC:	mov	m,d		; vymaz
		inx	h
		mov	m,d
		inx	h
		mov	m,d
		dad	d		; prejdi na dalsi mikroriadok
		dcr	c		; opakuj pre vsetky mikroriadky
		jnz	CleanPanelC

		; zobrazenie nadpisu "LASERTRON .ACTIVATED."
		lxi	h,BaseVramAdr+(163*64)+11
		lxi	d,LtronAct
		lxi	b,HILO(10,13)
		call	DrawSprite

		; zvuk pri aktivacii Lasertronu
		lxi	d,1E28h
		lxi	h,0204h
		call	SoundW		; zahraj si...

		; posun Lasertronu az na koniec Zony 0
LTronZone0E:	lxi	h,SprStructLT+8 ; nastav rychlost Lasertronu
		mvi	m,1		; na 1
		call	OneStep		; vykonaj jeden krok
		lda	ZoneNumberT	; uz je Lasertron na konci Zony 0?
		cpi	36
		jc	LTronZone0E	; ak nie, posuvaj ho dalej

		; otvorenie Lasertronu
LTronOpen:	mvi	b,20		; 20 krokov
		xra	a		; ziadna zmena rychlosti a otocenia
		call	AutoStep	; vykonaj
		mvi	c,3		; 3 fazy otvorenia Lasertronu
LTronOpenA:	mvi	b,3		; 3 kroky
LTronOpenB:	push	b
		call	OneStep		; vykonaj krok
		pop	b
		dcr	b
		jnz	LTronOpenB
		lxi	h,SprStructLT+5	; sekvencia spritu Lasertron
		inr	m		; posun sa na dalsiu sekvenciu
		inr	m
		dcr	c		; opakuj kym nie je Lasertron pripraveny
		jnz	LTronOpenA
		mvi	b,20		; 20 krokov
LTronShotA:	push	b
		call	OneStep		; vykonaj krok
		pop	b
		dcr	b
		jnz	LTronShotA

		; vystrel Lasertronu
		lxi	d,16		; offset na dalsiu struturu
		lxi	h,SprStructS1+5	; sekvencia spritu Strela
		mvi	b,3		; vsetky 3 strely budu SprLasShot1
LTronShotB:	mvi	m,20h		; zapis
		dad	d		; dalsia strela
		dcr	b
		jnz	LTronShotB
		mvi	a,6		; inicializacna hodnota pre
		sta	ShotTime+1	;   cas letu pre tuto Strelu
		mvi	b,60		; 60 krokov
		mvi	a,16		; Fire
		call	AutoStep	; vykonaj - vystrel Lasertron Strely
		mvi	b,8		; 8 krokov
		xra	a		; ziadna zmena smeru
		call	AutoStep	; vykonaj
		mvi	a,22		; vrat povodnu hodnotu pre cas letu Strely
		sta	ShotTime+1

		; "vyparenie" Kozmickej lode
		lxi	d,InnerScr+(88*SVO)+14 ; адрес источника VO - tam je cista mriezka
		lxi	h,InnerScr+14	; адрес назначения VO - tam je "Kozmicka" lod
		push	h
		lxi	h,VanishData	; data pre "vyparenie" Kozmickej lode
		mov	a,m		; maska mazania dat z VO
		inx	h
		xthl			; data na zasobnik, prvy ukazatel nazad do HL
VanishShipA:	cma			; invertuj ju a uloz na neskor
		sta	VanishShipC+1
		push	h		; odpamataj ukazatele
		push	d
		mvi	c,22		; vyska 22*4 mikroriadkov 
VanishShipB:	push	d
		mvi	b,29		; sirka 29 bytov
VanishShipC:	mvi	a,0		; maska
		ana	m		; aplikuj masku na cielovy obsah
		xchg
		ora	m		; pridaj zdrojove data
		xchg
		mov	m,a		; vysledok uloz do VO
		inx	h		; posun sa na dalsi znakovy stlpec
		inx	d
		dcr	b
		jnz	VanishShipC	; opakuj pre celu sirku
		mov	a,c
		mvi	c,(4*SVO)-29
		dad	b		; posun cielovu adresu o 4 mikroriadky
		xchg
		pop	h
		mvi	c,4*SVO
		rrc
		rlc
		jnc	VanishShipE
		lxi	b,-(4*SVO)
VanishShipE:	dad	b		; posun zdrojovu adresu o 4 mikroriadky hore/dole
		xchg
		mov	c,a
		dcr	c		; opakuj pre celu vysku
		jnz	VanishShipB

		; dopln chybajuci horny okraj Zony
		lxi	h,InnerScr+14
		lxi	b,HILO(28,3Fh)
VanishShipD:	mov	m,c
		inx	h
		dcr	b
		jnz	VanishShipD
		mvi	m,0Fh

		; vykreslenie kroku "vyparenia" Kozmickej lode
 		mvi	l,11*8
		lxi	d,InnerScr
		lxi	b,BaseVramAdr
		call	DrawInnerScr

		; zvuk po jednom kroku "vyparenia" Kozmickej lode
		lxi	h,SoundI
		mvi	m,0A2h
		mvi	c,0Ah
		lxi	d,7F14h
		call	SoundD

		pop	d		; obnov ukazatele do VO
		pop	h

		; dalsi krok "vyparenia" Kozmickej lode
		xthl
		mov	c,m		; offset (krok) do BC
		inx	h
		mov	b,m
		inx	h
		mov	a,m
		inx	h
		xthl
		dad	b		; pripocitaj k zdrojovemu ukazatelu
		xchg
		dad	b		; pripocitaj k cielovemu ukazatelu
		xchg
		ana	a		; koniec zoznamu?
		jnz	VanishShipA	; nie, pokracuj
		pop	h

		; male zdrzanie
		mvi	c,0E0h
Wait1:		mvi	b,0E0h
Wait2:		dcr	b
		jnz	Wait2
		dcr	c
		jnz	Wait1

		; vymazanie nadpisu LASERTRON ACTIVATED
		lxi	h,BaseVramAdr+(163*64)+11
		lxi	d,64-10
		mvi	c,13		; vyska 13 mikroriadkov
CleanLabelA:	mvi	b,10		; sirka 10 znakovych stlpcov
CleanLabelB:	mov	m,d		; vymaz
		inx	h
		dcr	b
		jnz	CleanLabelB	; opakuj
		dad	d		; prejdi na dalsi mikroriadok
		dcr	c		; opakuj pre vsetky mikroriadky
		jnz	CleanLabelA

		; uzatvorenie Lasertronu
		lxi	h,SprPrepList	; vyprazdni zoznam pripravenych spritov
		mvi	m,0FFh
		mvi	c,3		; 3 fazy uzatvorenia Lasertronu
LTronCloseA:	mvi	b,3		; 3 kroky
LTronCloseB:	push	b
		call	OneStep		; vykonaj krok
		pop	b
		dcr	b
		jnz	LTronCloseB
		lxi	h,SprStructLT+5	; sekvencia spritu Lasertron
		dcr	m		; posun sa na dalsiu sekvenciu
		dcr	m
		dcr	c		; opakuj kym nie je Lasertron pripraveny
		jnz	LTronCloseA
		mvi	b,20		; 20 krokov
LTronCloseC:	push	b
		call	OneStep		; vykonaj krok
		pop	b
		dcr	b
		jnz	LTronCloseC

		; vybuch Lasertronu
		lxi	h,SprStructLT+5 ; sekvencia spritu Lasertron
		mvi	m,80h		; nastav sprite SprBlast
		mvi	b,190		; 190 krokov
LTonBlastA:	push	b
		lxi	h,SprStructLT+8	; rychlost LT
		mvi	m,80h		; nastav flag - sprite prave vybuchuje
		call	OneStep		; vykonaj krok
		pop	b
		mov	a,b		; ak ma pocitadlo prave hodnotu 135
		cpi	135
		jnz	LTonBlastB
		push	b
		lxi	h,TPrepare	; zobraz text "PREPARE YOURSELF ..."
		call	Print85Text	; zobraz text
		pop	b
LTonBlastB:	dcr	b
		jnz	LTonBlastA	; a opakuj dany pocet krokov

		; zvysenie rychlosti pohyblivych spritov
		lda	SpeedLevel	; uroven rychlosti
		cpi	02h		; ak je uz >=2
		jnc	PlayAgain	; nezvysuj ju dalej a skoc na zaciatok hry
		inr	a		; +1
		sta	SpeedLevel	; a uloz novu uroven
		lxi	h,SprList+6	; adresa zoznamu spritov
		lxi	d,16		; offset na dalsiu strukturu
IncSpeedA:	mov	a,m		; typ spritu
		ani	0Fh		; ponechaj zakladny kod
		cpi	5		; vybranym pohyblivym spritom
		jnc	IncSpeedB
		inx	h		; (7)
		inx	h		; (8)
		inr	m		; zvys rychlost
		dcx	h		; (7)
		dcx	h		; (6)
IncSpeedB:	dad	d		; dalsi sprite
		mov	a,h		; az po Vortonov
		cpi	SprListVL/256
		jc	IncSpeedA

		jmp	PlayAgain	; skoc na zaciatok hry

;------------------------------------------------------------------------------
; Обработка смещения Vorton, выстрел по нажатию клавиш
ProcMove:	lhld	VortonStruct	; adresa struktury aktualneho Vortona
		mvi	a,8		; posun sa na Rychlost
		add	l
		mov	l,a		; (8) - rychlost pohybu
		mov	a,m		; do A
		ora	a		; je Vorton aktivny?
		jm	ProcSeq		; nie, skoc dalej
		xchg			; ukazatel na Rychlost do DE
		lda	KbdState	; - FLRUD
		mov	b,a		; stav Kbd do B

		; ускорение / замедление Vorton
		lxi	h,ChngSpdDly	; premenna pre zdrzanie pred zmenou rychlosti
		dcr	m		; zniz pocitadlo
		jp	ProcMoveC	; ak nie je nulove, skoc dalej
		inr	m
		mov	a,b
		rrc			; spomalenie?
		jnc	ProcMoveA	; nie, skoc dalej
		ldax	d		; (8) - скорость
		dcr	a		; zniz rychlost
		jm	ProcMoveC	; ak uz bola rychlost nulova, skoc dalej
		stax	d		; (8) - uloz novu rychlost
		jmp	ProcMoveB	; skoc dalej

ProcMoveA:	mov	a,b		; zrychlenie?
		ani	2
		jz	ProcMoveC	; nie, skoc dalej
		ldax	d		; (8) - скорость
		inr	a		; zvys rychlost
		cpi	3		; ak je uz maximalna rychlost (2 !!),
		jnc	ProcMoveC	; skoc dalej
		stax	d		; (8) - uloz novu rychlost
ProcMoveB:	dcr	a		; je rychlost 1 ?
		jnz	ProcMoveC	; nie, skoc dalej
		mvi	m,7		; ano, inic. zdrzanie pre dalsiu zmenu rychlosti

		; вращение Vorton
ProcMoveC:	dcr	e		; (7) - вращение
		inx	h		; posun sa na premennu pre zdrzanie pred zmenou otocenia
		dcr	m		; zniz pocitadlo
		jp	ProcMoveE	; ak nie je nulove, skoc dalej
		mvi	m,1		; inak inic. zdrzanie pre dalsiu zmenu otocenia
		mov	a,b
		ani	4		; вращение вправо?
		jz	ProcMoveD	; nie, skoc dalej
		ldax	d		; (7) - вращение
		inr	a		; zvys hodnotu otocenia
		ani	7		; a uprav na interval <0, 7>
		stax	d		; (7) - uloz novu hodnotu
ProcMoveD:	mov	a,b		; вращение влево?
		ani	8
		jz	ProcMoveE	; nie, skoc dalej
		ldax	d		; (7) - вращение
		dcr	a		; zniz hodnotu otocenia
		ani	7		; a uprav na interval <0, 7>
		stax	d		; (7) uloz novu hodnotu

		; osetrenie letiacich striel
ProcMoveE:	xchg			; ukazatel na premenne do DE
		lxi	h,SprStructS1	; adresa struktury 1. strely
		lxi	b,16		; offset na strukturu dalsej Strely

ProcMoveF:	inx	d		; posun sa na premennu - cas letu Strely
		ldax	d		; do A
		cpi	2		; ak su to 2 jednotky pred koncom
		cz	IncPower	; zvys hodnotu POWER
		ana	a		; ak uz cas Strely vyprsal,
		jnz	ProcMoveG
		mvi	m,0FEh		; deaktivuj sprite Strely
		inr	a		; korekcia pred dekrementom
ProcMoveG:	dcr	a		; zniz pocitadlo casu Strely
		stax	d		; a uloz novu hodnotu
		dad	b		; prejdi na dalsiu struturu
		mov	a,l
		cpi	((SprStructS3+16)&255) ; opakuj pre vsetky 3 Strely
		jnz	ProcMoveF

		; выстрел
		xchg
		inx	h		; posun sa na premennu - zdrzanie pred dalsim vystrelom
		dcr	m		; zniz pocitadlo
		jp	ProcSeq		; ak nie je nulove, skoc dalej
		inr	m
		lda	KbdState	; - FLRUD
		ani	16		; je stlacene FIRE ?
		jz	ProcSeq		; nie, skoc dalej
		xchg
		lxi	b,-16		; offset na predoslu strukturu
		dad	b		; posun sa na strunkturu 3. Strely
		dcx	d		; vrat sa na premennu - cas letu 3. Strely
		ldax	d		; cas letu do A
		ana	a		; je volna?
		jz	ProcMoveI	; ano, pouzi ju
		dcx	d		; posun sa na premennu - cas letu 2. Strely
		dad	b		; posun sa na strunkturu 2. Strely
		ldax	d		; cas letu do A
		ana	a		; je volna?
		jz	ProcMoveI	; ano, pouzi ju
		dad	b		; posun sa na strunkturu 1. Strely
		dcx	d		; posun sa na premennu - cas letu 1. Strely
		ldax	d		; cas letu do A
		ana	a		; je volna?
		jnz	ProcSeq		; ak nie, skoc dalej
ProcMoveI:	xchg			; adresa struktury Strely do DE
ShotTime:	mvi	m,22		; inicializuj cas letu pre tuto Strelu
		inr	a		; inicializuj premennu pre zdrzanie vystrelu
		sta	FireDelay
		; inicializuj strukturu strely podla struktury Vortona
		lhld	VortonStruct	; adresa struktury aktualneho Vortona
		mvi	b,5		; skopiruj data pozicie Vortona
		call	Copy8		; do struktury Strely
		inr	l		; (6)
		inr	l		; (7)
		inr	e		; (6)
		inr	e		; (7)
		mov	a,m		; skopiruj sekvenciu (otocenie) spritu
		stax	d
		inr	l		; (8)
		inr	l		; (9)
		inr	e		; (8)
		inr	e		; (9)
		mov	a,m		; skopiruj typ vykreslovacej rutiny
		stax	d

		; po vystrele zniz POWER
		lda	PowerIndik	; pozicia posledneho dielika POWER
		mov	e,a		; stlpec pre POWER
		dcr	a		; zniz aktualny stlpec
		sta	PowerIndik	; uloz novu hodnotu
		mvi	d,24		; ряд для POWER
		xra	a
		call	Print88		; zmaz posledny znak POWER
		mov	a,e		; kod znaku pre konkretny znak POWER
		dcr	e
		dcr	e
		call	Print88		; zobraz znak

		; priprav zvuk vystrelu
		lxi	h,SndType
		mvi	a,2
		ora	m
		mov	m,a

; Обработка изменений последовательности спрайтов
		; premenna Seq0E
ProcSeq:	lxi	d,Seq0E		; adresa premennej Seq0E do DE
		lhld	VortonStruct	; adresa struktury aktualneho Vortona
		mvi	a,7
		add	l
		mov	l,a		; (7) - sekvencia spritu (otocenie)
		mov	a,m
		add	a		; zdvojnasob
		stax	d		; a uloz novu hodnotu

		; premenna Seq0F
		lxi	h,CntSeq0F	; adresa pocitadla pre Seq0F
		dcr	m		; zniz pocitadlo, bolo nulove?
		jp	ProcSeqD	; nie, preskoc spracovanie premennej Seq0F
		mvi	m,2		; inicializuj pocitadlo
		lxi	h,Seq0F		; adresa premennej Seq0F
		lda	IncSeq0F	; inkrement pre Seq0F
		mov	b,a		; uloz do B
		mov	a,m		; hodnota Seq0F
		add	b		; pripocitaj inkrement
		cpi	7		; ak je vysledok < 7,
		jc	ProcSeqB	; je to OK, skoc
		mov	a,b		; inak neguj hodnotu inkrementu
		cma
		inr	a
		sta	IncSeq0F	; uloz novu hodnotu
		mov	b,a
		mov	a,m		; hodnota Seq0F
		add	b		; pripocitaj inkrement
ProcSeqB:	mov	m,a		; a uloz

		inr	l		; preskoc Seq10

		; premenna Seq11
		inr	l		; Seq11
		mov	a,m		; hodnota Seq11 do A
		inr	a		; +2
		inr	a
		cpi	7		; ak je vysledok < 7,
		jc	ProcSeqC	; je to OK, skoc
		xra	a		; inak vynuluj hodnotu
ProcSeqC:	mov	m,a		; uloz novu hodnotu

		; premenna Seq10
ProcSeqD:	lxi	h,CntSeq10	; adresa pocitadla pre Seq10
		dcr	m		; zniz pocitadlo, bolo nulove?
		jp	ProcSeqH	; preskoc spracovanie premennej Seq10
		mvi	m,1		; inicializuj pocitadlo
		lxi	h,Seq10		; adresa premennej Seq10
		lda	IncSeq10	; inkrement pre Seq10
		mov	b,a		; uloz do B
		mov	a,m		; hodnota Seq10
		add	b		; pripocitaj inkrement
		cpi	7		; ak je vysledok < 7,
		jc	ProcSeqF	; je to OK, skoc
		mov	a,b		; inak neguj hodnotu inkrementu
		cma
		inr	a
		sta	IncSeq10	; uloz novu hodnotu
		mov	b,a
		mov	a,m		; hodnota Seq10
		add	b		; pripocitaj inkrement
ProcSeqF:	mov	m,a		; a uloz

		inr	l		; Seq11

		; premenna Seq12
		inr	l		; Seq12
		mov	a,m		; hodnota Seq12 do A
		inr	a		; +2
		inr	a
		cpi	7		; ak je vysledok < 7,
		jc	ProcSeqG	; je to OK, skoc
		xra	a		; inak vynuluj hodnotu
ProcSeqG:	mov	m,a		; a uloz

		; premenna Seq13
ProcSeqH:	lxi	h,Seq13		; adresa premennej Seq13
		mov	a,m		; hodnota Seq13 do A
		inr	a		; +2
		inr	a
		cpi	3		; ak je vysledok < 3,
		jc	ProcSeqI	; je to OK, skoc
		xra	a		; inak vynuluj hodnotu
ProcSeqI:	mov	m,a		; a uloz
		ret

;------------------------------------------------------------------------------
; Обработка движения объектов и их столкновений
ProcSpr:	lhld	VortonStruct	; adresa struktury aktualneho Vortona
		mov	a,m		; Y suradnica
		cpi	0FEh		; je Vorton aktivny?
		jnc	NextMSpr	; nie, skoc spracovat dalsi "hlavny" sprite
		push	h		; odpamataj adresu struktury hl. spritu
		mvi	a,8
		add	l
		mov	l,a		; (8) - скорость
		mov	a,m		; скорость в A
		ora	a		; vybuchuje prave Vorton?
		jp	ProcSprA	; nie, pokracuj dalej
		dcx	h		; (7) - направление / последовательность / вращение
		mvi	m,0		; vynuluj sekvenciu spritu
		jmp	ProcSprE	; pokracuj dalej

ProcSprA:	mvi	a,-6
		add	l
		mov	l,a		; (2)
		mov	b,m
		dcx	h		; (1)
		mov	c,m		; X координата Vorton в BC
		dcx	h		; (0)
		mov	a,b		; узнать, находится ли Вортон перед Зоной 30
		ana	a
		jnz	ProcSprB	; нет, переходим
		mov	a,c		; это младший байт
		cpi	0B0h
		jc	ProcSprD	; je pred Zonou 30, preskoc test zmeny Zony

ProcSprB:	xchg			; adresa struktury docasne do DE
		lhld	ZonePos		; aktualna pozicia Zony do HL
		call	SubBCHL		; over, ci Vorton opusta aktualnu Zonu
					; ak je rozdiel zaporny,
		jnz	ProcSprC	;  Vorton prechadza do predoslej Zony
		xchg			; adresa struktury nazad do HL
		mov	a,c		; ak je rozdiel >= 0B0h,
		cpi	0B0h		;  Vorton prechadza do nasledujucej Zony
		jc	ProcSprD	; Vorton zostava v aktualnej Zone, skoc
ProcSprC:	call	PrepSpr		; priprav sprity
		call	DrawZone	; vykresli novu Zonu
		lhld	VortonStruct	; obnov do HL adresu struktury Vortona

ProcSprD:	mvi	a,8
		add	l
		mov	l,a		; (8)
		mov	a,m		; скорость движения Vorton
		ana	a		; je rychlost nulova?
		jnz	ProcSprM	; nie, skoc spracovat pohyb
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

		; slucka spracovania dalsieho spritu
ProcSprL:	push	h		; odpamataj adresu struktury "hlavneho" spritu
		mvi	a,8
		add	l
		mov	l,a		; (8)
		mov	a,m		; скорость движения объекта
		ani	0BFh		; vynuluj 6. bit - sprite v pohybe po odrazeni
					; ak nie je sprite v pohybe,
		jz	NextMSprP	;  skoc spracovat dalsi "hlavny" sprite
					; vybuchuje prave sprite?
		jp	ProcSprM	; nie, skoc spracovat pohyb
		dcx	h		; (7)
ProcSprE:	dcx	h		; (6)
		dcx	h		; (5)
		mov	a,m		; sekvencia spritu vybuch
		adi	8		; posun sa na dalsiu sekvenciu vybuchu
		cpi	0DCh		; конец взрыва?
		jc	ProcSprF	; nie, skoc dalej
		inx	h		; (6)
		inx	h		; (7)
		inx	h		; (8)
		mov	a,m		; (8) - скорость объекта
		ani	7Fh		; zrus flag vybuchu
		mov	m,a		; a uloz
		jmp	ShotOff		; skoc deaktivovat sprite, prejdi na dalsi

ProcSprF:	mov	m,a		; (5) - uloz novu sekvenciu spritu
		inx	h		; (6) - kod spritu
		mov	a,m		; kod spritu do A
		ani	0Fh		; ponechaj iba zakladny kod
		jz	ProcSprH	; ak je to Vorton, skoc dalej
		mvi	e,1<<3		; Snd3 pre pohyblive objekty
		cpi	7		; ak su to pohyblive objekty,
		jc	ProcSprG	; skoc nastavit zvuk a prejdi na dalsi sprite
		mvi	e,1<<7		; pre ostatne sprity Snd7
		jmp	ProcSprG	; skoc nastavit zvuk a prejdi na dalsi sprite

		; стирание Vortona с панели
ProcSprH:	mov	a,l		; z adresy struktury aktualneho Vortona
		rrc			; vypocitaj znakovy stlpec Vortona na panely
		rrc
		rrc
		ani	1Fh
		adi	6
		mov	e,a		; uloz do E
		mvi	d,24		; riadok, kde je Vorton na panely
		mvi	l,3		; vyska Vortona 3 znaky
ProcSprI:	xra	a		; zmaz lavy znak
		call	Print88
		xra	a		; zmaz pravy znak
		call	Print88
		inr	d		; dalsi riadok
		dcr	e		; vrat sa na prvy stlpec
		dcr	e
		dcr	l
		jnz	ProcSprI
		mvi	e,1<<6		; Snd6 pre Vortona
ProcSprG:	lxi	h,SndType	; adresa typu zvuku pri vybuchu do HL
		mov	a,m
		ora	e		; priprav zvuk
		mov	m,a
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

		; spracovanie pohybu a kolizie spritov
ProcSprM:	dcr	a		; rychlost pohybu -1 => <0,3>
		rrc			; 
		rrc			; A = (A - 1) * 64
		mov	e,a		; offset do tabulky podla rychlosti
		dcx	h		; (7)
		mov	a,m		; sekvencia spritu (otocenie)
		add	a		; x2
		add	a		; x4
		add	a		; x8
		add	e		; + offset podla otocenia
		mov	e,a		; uloz do E
		mvi	d,MovTable/256	; D = vyssi byte tabulky posunu spritu
		mvi	a,-7
		add	l
		mov	l,a		; (0) - pozicia Y spritu
		ldax	d		; inkrement Y pozicie spritu
		add	m		; pripocitaj Y poziciu spritu
;		sta	ChDir4Y+1	; uloz na neskor
		xchg			; adresa tabulky do HL, struktura do DE
		cpi	49h		; ak by bola po posune Y suradnica
		jnc	ProcSprO	; mimo rozsah <0, 48h>, skoc dalej
		sui	07h		; uprav Y suradnicu pre test kolizie
		sta	ProcSprColl+1	; a uloz na neskor
		inx	h		; posun sa na inkrement X
		mov	c,m		; inkrement X do BC
		inx	h
		mov	b,m
		shld	MovTablePtr+1	; odpamataj ukazatel na tabulku
		xchg			; adresa struktury spritu do HL
		inx	h		; (1) - XL
		mov	e,m		; X pozicia spritu do DE
		inx	h		; (2) - XH
		mov	d,m
		xchg			; X pozicia spritu do HL, struktura do DE
		dad	b		; pripocitaj inkrement
		mov	c,l
		mov	b,h		; vysledok do BC
		lhld	ZonePosP	; pozicia predchadzajucej Zony do HL
		call	SubBCHL		; vypocitaj vzdialenost aktualneho spritu
					;   od predoslej Zony
		cpi	02h		; ak je to maximalne rozdiel (takmer) 3 Zon
		jc	ProcSprZ	; tak spracuj tento Sprite
		.db	1		; LXI B - preskoc nasledujuce 2 instrukcie
ProcSprO:	inx	d		; (1)
		inx	d		; (2)
		mvi	a,7*2		; pokracuj, akoby sa narazilo do GlassBrick
		pop	b		; obnov adresu struktury hlavneho spritu
		push	b		; do BC a znovu uloz
		jmp	ProcSprCollC	; skoc vykonat nepriamy skok do rutiny

		; osetrenie kolizie aktualneho spritu s inym
ProcSprZ:	dad	b		; vrat povodnu hodnotu pozicie X spritu
		lxi	b,-7		; -7
		dad	b		; uprav X poziciu pre test kolizie
		shld	NextCSpr0+1	; a uloz
; prejdeme vsetky sprity v danej Zone a preverime ich koliziu s hlavnym spritom
		lhld	VortonStruct	; zacneme aktualnym Vortonom
NextCSpr0:	lxi	b,0		; X pozicia pre test kolizie
		mov	a,m		; Y suradnica spritu pre test na koliziu
		cpi	0FEh		; je to aktivny sprite?
		jc	ProcSprColl	; ano, skoc previest testy
		jnz	ProcSprNoColl	; ak je to koniec zoznamu, skoc dalej
NextCSpr16:	lxi	d,16		; dalsi sprite
		dad	d
		jmp	NextCSpr0	; skoc overit dalsi sprite

		; nenasla sa ziadna kolizia
ProcSprNoColl:	pop	d		; obnov adresu struktury hlavneho spritu
		push	d		; do DE a znovu uloz
		lda	ProcSprColl+1	; vrat Y poziciu na povodnu hodnotu
		adi	7
		stax	d		; a uloz do struktury spritu
		lxi	h,7		; vrat X poziciu na povodnu hodnotu
		dad	b
		xchg			; a presun do DE
		inx	h		; (1)
		mov	m,e		; a uloz do struktury spritu
		inx	h		; (2)
		mov	m,d
		mvi	a,7		; posun sa na typ rutiny
		add	l
		mov	l,a		; (9) - тип процедуры
MovTablePtr:	lxi	d,0		; obnov ukazatel do tabulky
		inx	d		; posun ukazatel na inkrement typu rutiny
		ldax	d		; inkrement do A
		inx	d		; posun ukazatel na inkrement VO2
		add	m		; pripocitaj inkrement k aktualnej hodnote
		jm	ProcSprNoCollA	; ak je sucasna hodnota <0, uprav ju na kladnu
		cpi	4		; ak sme v rozsahu {0, 1, 2},
		jc	ProcSprNoCollC	; skoc novu hodnotu ulozit
		sui	4		; ak je sucasna hodnota >2,
		jp	ProcSprNoCollB	;  uprav ju na povoleny rozsah

ProcSprNoCollA:	adi	4		; uprav hodnotu na povoleny rozsah
ProcSprNoCollB:	inx	d		; pri opusteni znakovej pozicie, posun
		inx	d		; ukazatel v tabulke na druhy inkrement
ProcSprNoCollC:	mov	m,a		; (9) - uloz novu hodnotu
		mvi	a,-5
		add	l
		mov	l,a		; (4)
		mov	b,m
		dcx	h		; (3)
		mov	c,m		; sucasna adresa VO2 spritu do BC
		xchg
		mov	a,m
		inx	h
		mov	h,m
		mov	l,a		; inkrement adresy VO2 do HL
		dad	b		; pripocitaj inkrement
		xchg
		mov	m,e		; a uloz novu hodnotu
		inx	h		; (4)
		mov	m,d
		inx	h		; (5)
		inx	h		; (6)
		mov	a,m		; kod spritu do A
		inx	h		; (7)
		xchg			; adresa struktury +7 do DE
		cpi	4		; je to Sprite Frog?
		jnz	ProcSprNoCollE	; nie, skoc dalej
		; Frog (04h)
		mvi	a,5
		add	e
		mov	e,a		; (12)
ProcSprNoCollD:	call	Rand		; nahodna hodnota do (HL)
		ldax	d		; inicializacna hodnota pre sekvenciu
		add	a		;  spritu (otocenie) *2
		mvi	b,0		; vypocitany offset uloz do BC
		mov	c,a
		mvi	a,-5
		add	e
		mov	e,a		; (7)
		mov	a,m		; nahodna hodnota do A
;		rrc			; horne 4 bity na miesto dolnych
;		rrc
;		rrc
;		rrc
		lxi	h,SeqMaskTab	; tabulka pre nahodnu zmenu sekvencie
		dad	b		; spritu - pripocitaj offset
		ana	m		; na nahodnu hodnotu aplikuj masku
		inx	h
		ora	m		; a pripoj definovanu hodnotu
		stax	d		; uloz novu sekvenciu
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

ProcSprNoCollE:	ani	0Fh		; ponechaj iba zakladny kod spritu
		cpi	3		; je to sprite Eye alebo Disk?
		jnz	ProcSprNoCollG	; nie, skoc dalej
		; Eye (03h) alebo Disk (13h)
		call	Rand		; nahodna hodnota do A
					; podla hodnoty, zvol zmenu sekvencie
		cpi	0F5h		; ak je < 0F5h,
		jc	ProcSprNoCollF	; skoc dalej
		ldax	d		; cislo sekvencie spritu sa dekrementuje
		dcr	a
		ani	7		; uprav na rozsah <0, 7>
		stax	d		; uloz novu hodnotu sekvencie
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

ProcSprNoCollF:	cpi	0Ah		; ak je > 0Ah,
		jnc	NextMSprP	;  skoc spracovat dalsi "hlavny" sprite
		ldax	d		; cislo sekvencie spritu sa inkrementuje
		inr	a
		ani	7		; uprav na rozsah <0, 7>
		stax	d		; uloz novu hodnotu sekvencie
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

ProcSprNoCollG:	cpi	10		; je to sprite Block alebo Barrel?
		jnz	NextMSprP	; nie, skoc spracovat dalsi "hlavny" sprite
		; Block (0Ah) alebo Barrel (1Ah)
		inx	d		; (8)
NextMSprS:	ldax	d		; (8) - rychlost do A
		ani	0BFh		; zrus flag, ze je Block/Barrel v pohybe
		rar			; vydel rychlost dvoma
		stax	d		; uloz novu hodnotu
NextMSprP:	pop	h
NextMSpr:	lxi	d,16		; prejdi na dalsiu strukturu
NextMSprD:	dad	d
		mov	a,m		; dalsi sprite
		cpi	0FEh		; je aktivny?
		jc	ProcSprL	; ano, skoc ho spracovat
		jz	NextMSprD	; nie, skus dalsi sprite
		ret

; pokracovanie osetrenia kolizie aktualneho spritu s inym
; (SP) = adresa hlavneho spritu
; BC = suradnica X "hlavneho" spritu
; (ProcSprColl+1) = suradnica Y "hlavneho" spritu
; HL = adresa struktury "kolizneho" spritu
; A = suradnica Y "kolizneho" spritu
ProcSprColl:	sui	0		; porovnaj suradnice Y spritov
		cpi	0Fh		; ak je rozdiel >= 0Fh
		jnc	NextCSpr16	; sprity nie su v kolizii, skoc
		inx	h		; (1)
		mov	e,m		; 
		inx	h		; (2)
		mov	d,m
		call	SubDEBC		; porovnaj suradnice X spritov
		jnz	NextCSpr14	; ak je rozdiel >= 0Fh, sprity nie su v kolizii, skoc
		mov	a,e		; este nizsi byte
		cpi	0Fh
		jc	ProcSprCollA	; su v kolizii, skoc
NextCSpr14:	lxi	d,14		; prejdi na dalsi sprite
		dad	d
		jmp	NextCSpr0

		; nasla sa kolizia
ProcSprCollA:	pop	b		; adresa struktury "hlavneho" spritu
		push	b		; do BC a znovu uloz
		mov	a,c		; este otestuj, ci to nie je ta ista
		inr	a		;  struktura
		inr	a
		cmp	l
		jnz	ProcSprCollB	; nie je, skoc
		mov	a,b
		cmp	h
		jz	NextCSpr14	; je, prejdi na dalsi sprite

ProcSprCollB:	xchg			; adresa "kolizneho" spritu +2 do DE
		mvi	a,4		; posun sa na typ "kolizneho" spritu
		add	e		; (6)
		mov	l,a
		mov	h,d
		mov	a,m		; (6) typ spritu
		ani	0Fh		; iba zakladny kod
		add	a		; *2
ProcSprCollC:	mov	l,a		; uloz do L
		mvi	a,11		; posun sa na bazovy offset na zoznam
		add	c		; "hlavneho" spritu
		mov	c,a		; (11)
		ldax	b		; bazovy offset na zoznam z "hlavneho" spritu
		add	l		; pripocitaj bazovy offset na zoznam
		mov	l,a		; obsluznych rutin kolizie
		mvi	h,RtnList/256	; HL=adresa v zozname rutin
		mov	a,m		; samotnu adresu obsluznej rutiny do HL
		inx	h
		mov	h,m
		mov	l,a
		dcx	b		; (10)
		dcx	b		; (9)
		dcx	b		; (8) - adresa "hlavneho" spritu +8 v BC
		pchl			; skoc nepriamo do obsluznej rutiny
		; HL = adresa obsluznej rutiny kolizie
		; BC = adresa +8 struktury "hlavneho" spritu
		; DE = adresa +2 struktury "kolizneho" spritu

;------------------------------------------------------------------------------
; Vorton (00h) narazil do Lasertron (09h) alebo do BrickA (19h).
; Ak je Vorton otoceny na V, SV, JV, tak bude Lasertron tlacit.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vorton (00h), Auto-Vorton (10h)
;    DE=adresa +2 struktury "kolizneho" spritu
;        - Lasertron (09h), BrickA (19h)
PushLTron:	mvi	a,4		; prejdi na kod "kolizneho" spritu
		add	e
		mov	e,a		; (6) - kod spritu
		ldax	d
		ani	10h		; je to BrickA (19h)?
		jnz	NextMSprSB	; ano, skoc znizit rychlost Vortona
		dcr	c		; (7) - otocenie Vortona
		ldax	b		; otocenie Vortona do A
		inr	c		; (8)
		dcr	a		; over povolene otocenie Vortona,
		dcr	a		;  aby mohol tlacit Lasertron
		cpi	05h		; je Vorton otoceny na V, SV, JV?
		jc	VortHit		; nie, skoc osetrit naraz
		inr	e		; (7) - sekvencia "kolizneho" spritu
		xra	a
		stax	d		; inak vynuluj sekvenciu Lasertronu
		inr	e		; (8) - rychlost
		inr	a
		stax	d		; nastav Lasertronu aj Vortonu
		stax	b		; rychlost 1
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Osetrenie narazu Block (0Ah) do Barrel (1Ah) a naopak
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Block (0Ah), Barrel (1Ah)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Block (0Ah), Barrel (1Ah)
BlkBrlHit:	ldax	b		; rychlost "hlavneho" spritu
		mov	l,a		; do L
		ani	40h		; je Block/Barrel v pohybe?
		jnz	BlkBrlHitA	; ano, skoc dalej
		mov	a,l
		cpi	02h		; je rychlost <2 ?
		jc	NextMSprP	; ano, skoc spracovat dalsi "hlavny" sprite
NextMSprSB:	mov	e,c		; presun adresu struktury "hlavneho"
		mov	d,b		; spritu do DE
		jmp	NextMSprS	; a skoc znizit rychlost

BlkBrlHitA:	mov	a,l
		ani	0BFh		; zrus flag "hlavneho" spritu v pohybe
		mov	l,a		; nazad do L
		stax	b		; a uloz do struktury
		mvi	a,4		; prejdi na kod "kolizneho" spritu
		add	e
		mov	e,a		; (6) - kod spritu
		ldax	d
		ani	10h		; ak je to Barrel,
		mov	a,l
		jnz	BlkBrlHitB	; preskoc znizenie rychlosti
		rar			; pre Block zniz rychlost
BlkBrlHitB:	inr	e		; (7)
		inr	e		; (8) - rychlost spritu
		ori	40h		; nastav flag, ze je Block/Barrel v pohybe
		stax	d		; uloz novu hodnotu
		dcr	e		; (7) - smer spritu
		dcr	c		; (7)
		ldax	b		; skopiruj smer z jedneho spritu
		stax	d		; do druheho
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Zasiahnutie Block (0Ah), Barrel (1Ah) strelou.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Block (0Ah), Barrel (1Ah)
ShotBlkBrl:	mvi	a,-8		; presun sa na suradnicu Y Strely
		add	c
		mov	c,a		; (0)
		mvi	a,0FEh		; deaktivuj strelu
		stax	b
		mvi	a,8		; vrat sa na rychlost
		add	c
		mov	c,a		; (8)

; Narazenie Vrtona (00h) do Block (0Ah), Barrel (1Ah).
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vorton (00h), Auto-Vorton (10h), Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Block (0Ah), Barrel (1Ah)
VortBlkBrl:	mvi	a,05h		; prejdi na sekvenciu spritu
		add	e
		mov	e,a		; (7) - smer spritu Vortona/Strely
		dcr	c		; (7) - smer spritu Block/Barell
		ldax	b		; skopiruj smer Vortona/Strely
		stax	d		; do Block/Barell
		inr	c		; (8) - rychlost Vortona/Strely
		ldax	b
		mov	l,a		; do L
		dcr	e		; (6) - kod "kolizneho" spritu
		ldax	d
		ani	10h		; je to Barrel?
		mov	a,l		;  - rychlost do A
		jnz	VortBlkBrlA	; ano, skoc
		rar			; vydel rychlost /2
VortBlkBrlA:	inr	e		; (7)
		inr	e		; (8)
		ori	40h		; nastav, ze sprite je v pohybe
		stax	d		; uloz novu rychlost

;---------------
; Vorton narazil do Auto-Vortona (10h), GlassBrick (07h, 17h), BrickB (08h), BrickA (18h).
; Z predosleho kodu Vorton/Strela narazili do Block (0Ah), Barrel (1Ah).
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vorton (00h), Auto-Vorton (10h), Shot (01h), LasShot (11h)
VortHit:	dcr	c		; (7)
		dcr	c		; (6) - kod spritu
		ldax	b		; do A
		inr	c		; (7)
		inr	c		; (8)
		dcr	a		; je to Vorton alebo Strela?
		jm	VortonHitV	; ano, je to Vorton, skoc dalej
		jnz	NextMSprP	; ani jeden, skoc spracovat dalsi "hlavny" sprite
		mvi	e,1<<4		; Snd4 pre Strelu
		jmp	ProcSprG	; skoc pripravit zvuk
					; a spracovat dalsi "hlavny" sprite

VortonHitV:	lxi	d,0		; ziadny zvuk
		lxi	h,ChngSpdDly
		mov	a,m		; zdrzanie pri zmene rychlosti Vortona
		cpi	7		; je to pociatocna hodnota?
		jz	VortonHitN	; ano, skoc - bez zvuku
		mvi	e,1<<4		; inak, naplanuj zvuk Snd4
VortonHitN:	ldax	b		; (8)
		ora	a		; CY=0
		rar			; vydel /2 rychlost Vortona/Strely
		stax	b		; a uloz
		ora	a
		jz	VortonHitZ	; ak je uz nulova, skoc vynulovat zdrzanie
		mvi	d,2		; zdrzanie 3 kroky
VortonHitZ:	mov	m,d		; uloz nove zdrzanie
		jmp	ProcSprG	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Prechod na dalsiu strukturu "kolizneho" spritu.
; I: DE=adresa +2 struktury "kolizneho" spritu
NextCSpr:	xchg			; adresa struktury spritu +2 do HL
		jmp	NextCSpr14	; prejdi na dalsi sprite

;------------------------------------------------------------------------------
; Zasiahnutie Cyclop, Disk, Eye, Frog strelou.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Cyclop (02h), Disk (12h), Eye (03h), Disk (13h), Frog (04h), Frog (14h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Shot (01h), LasShot (11h)
EnemyShot:	xchg			; adresa struktury spritu +2 do HL
		dcx	h		; (1)
		dcx	h		; (0)
		mvi	m,0FEh		; deaktivuj Strelu
		mvi	e,80h
		ldax	b		; (8)
		ora	e		; nastav flag - vybuch
		stax	b
		dcx	b		; (7)
		dcx	b		; (6)
		dcx	b		; (5)
		mov	a,e		; nastav sprite Blast
EnemyShotX:	stax	b
		mvi	b,25		; zvys Score o 250 bodov
		call	IncScore
		mvi	e,1<<3		; naplanuj zvuk
		jmp	ProcSprG	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Vorton narazil na pohybliveho nepriatela.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vortona (00h), Auto-Vortona (10h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Cyclop (02h), Disk (12h), Eye (03h), Disk (13h), Frog (04h),
;       - Frog (14h), Star (05h), Cyclop (15h), Flame (06h), Rough (16h)
VortBlast:	xchg			; adresa struktury spritu +2 do HL
		mvi	a,6		; +6
		add	l
		mov	l,a		; (8) - rychlost
		mov	a,m		; rychlost do A
		ora	a		; uz je tento sprite v procese vybuchu?
		jm	NextCSpr8	; ano, skoc spracovat dalsi "kolizny" sprite
		dcr	l		; (7)
		dcr	l		; (6) - kod spritu
		mov	d,m		; kod spritu do D
		mvi	a,-6		; -6
		add	l
		mov	l,a		; (0)
		mov	a,d		; kod spritu
		cpi	16h		; je to Rough?
		jz	VortHit		; ano, skoc osetrit naraz
		cpi	06h		; je to Flame?
		jz	VortBlastB	; ano, preskoc deaktivovanie spritu
		cpi	05h		; je to Star?
		jz	VortBlastB	; ano, preskoc deaktivovanie spritu
		mvi	m,0FEh		; deaktivuj sprite, ktory znicil Vortona
	#if CheatLife
VortBlastB:	jmp	NextCSpr16
	#else
VortBlastB:	mvi	e,80h
		ldax	b
		ora	e		; nastav flag - vybuch
		stax	b
		dcx	b		; (7)
		dcx	b		; (6)
		dcx	b		; (5)
		mov	a,e
		stax	b		; nastav sprite Blast
		mvi	e,1<<6		; naplanuj zvuk vybuchu
		jmp	ProcSprG	; skoc spracovat dalsi "hlavny" sprite
	#endif

;------------------------------------------------------------------------------
; Zasiahnutie Cyclop, Disk, Eye, Frog strelou.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Cyclop (02h), Disk (12h), Eye (03h), Disk (13h), Frog (04h), Frog (14h)
ShotEnemy:	xchg			; adresa struktury spritu +2 do HL
		mvi	a,6		; +6
		add	l
		mov	l,a		; (8) - rychlost
		mov	a,m		; rychlost do A
		ora	a		; uz je tento sprite v procese vybuchu?
		jm	NextCSpr8	; ano, skoc spracovat dalsi "kolizny" sprite
		lxi	d,0FE80h
		ora	e		; nastav flag - vybuch
		mov	m,a
		dcr	l		; (7)
		dcr	l		; (6)
		dcr	l		; (5)
		mov	m,e		; nastav sprite Blast
		mvi	a,-8
		add	c
		mov	c,a
		mov	a,d
		jmp	EnemyShotX	; deaktivuj sprite Strely, naplanuj zvuk
					; a prejdi na dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Prechod na dalsiu strukturu "kolizneho" spritu.
; I: HL=adresa +8 struktury spritu
NextCSpr8:	lxi	d,8		; offset +8
		dad	d
		jmp	NextCSpr0	; prejdi na dalsi sprite

;------------------------------------------------------------------------------
; Rozbijanie BrickB (08h) a BrickA (18h) strelou.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - BrickB (08h) a BrickA (18h)
ShotBrick:	xchg			; adresa struktury spritu +2 do HL
		mvi	a,6		; +6
		add	l
		mov	l,a		; (8) - rychlost
		mov	a,m		; rychlost do A
		ora	a		; uz je tento sprite v procese vybuchu?
		jm	NextCSpr8	; ano, skoc spracovat dalsi "kolizny" sprite
		mvi	a,-8
		add	c
		mov	c,a		; (0)
		mvi	a,0FEh		; deaktivuj sprite Strely
		stax	b
		dcr	l		; (7)
		dcr	l		; (6) - kod spritu
		lxi	b,8060h		; offset konca sekvencie BrickB
		mov	a,m
		ani	10h		; je to BrickB ?
		jz	ShotBrickB	; ano, skoc
		mvi	c,0EEh		; offset konca sekvencie BrickA
ShotBrickB:	dcr	l		; (5) - sekvencia spritu
		mov	a,m		; posun sa na dalsiu sekvenciu spritu
		adi	2
		mov	m,a
		cmp	c		; uz boli vsetky sekvencie?
		jc	ShotBrickX	; nie, skoc dalej
		mov	m,b		; inak, nastav sprite Blast
		inr	l		; (6)
		inr	l		; (7)
		inr	l		; (8)
		mov	m,b		; nastav flag - vybuch
ShotBrickX:	mvi	e,1<<7		; naplanuj zvuk
		jmp	ProcSprG	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Движущийся враг врезался в Вортона.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Cyclop (02h), Disk (12h), Eye (03h), Disk (13h)
;       - Frog (04h), Frog (14h), Star (05h), Cyclop (15h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Vortona (00h), Auto-Vortona (10h)
EnemyBlast:	dcx	b		; (7)
		dcx	b		; (6)
		ldax	b		; kod spritu
		cpi	5		; je to Star?
		jz	EnemyBlastD	; ano, preskoc deaktivovanie spritu
		mvi	a,-6
		add	c
		mov	c,a		; (0)
		mvi	a,0FEh
		stax	b		; deaktivuj sprite
EnemyBlastD:	xchg			; adresa struktury Vortona +2 do HL
		mvi	e,80h
		inr	l		; (3)
		inr	l		; (4)
		inr	l		; (5) - sekvencia spritu
		mov	a,m		; do A
		cmp	e		; prebieha uz vybuch?
	#if ~~CheatLife
		jc	EnemyBlastB	; nie, skoc dalej
	#endif
		dcr	l		; (4)
		dcr	l		; (3)
		dcr	l		; (2)
		jmp	NextCSpr14	; prejdi na dalsi sprite

EnemyBlastB:	mov	m,e		; nastav sprite Blast
		inr	l		; (6)
		inr	l		; (7)
		inr	l		; (8) - rychlost
		mov	m,e		; nastav flag - vybuch
		mvi	e,1<<6		; naplanuj zvuk
		jmp	ProcSprG	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Strela, ktora je na zaciatku letu este v kolizii s Vortonom (00h) sa necha
; letiet dalej.
; Strela, ktora zasiahne Star (05h), Cyclop (15h) sa iba deaktivuje.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vortona (00h), Auto-Vortona (10h), Star (05h), Cyclop (15h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Shot (01h), LasShot (11h)
ShotFlyOffV:	xchg			; adresa +2 druheho spritu do HL
		inx	b		; (9)
		inx	b		; (10)
		ldax	b		; offset na Seq
		cpi	0Eh		; je to Vorton? - po vystrele je strela
		jz	NextCSpr14	;  este v kolizii s Vortonom
		dcr	l		; (1)
		dcr	l		; (0)
		mvi	m,0FEh		; deaktivuj Strelu
		jmp	NextCSpr16	; prejdi na dalsi sprite

;------------------------------------------------------------------------------
; Strela, ktora je na zaciatku letu este v kolizii s Vortonom (00h) sa necha
; letiet dalej.
; Strela, ktora zasiahne Star (05h), Cyclop (15h) sa iba deaktivuje.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Vortona (00h), Auto-Vortona (10h), Star (05h), Cyclop (15h)
ShotFlyOff:	xchg			; adresa +2 druheho spritu do HL
		mvi	a,8		; +8
		add	l
		mov	l,a
		mov	a,m		; (10) - offset na Seq
		cpi	0Eh		; je to Vorton? - po vystrele je strela
		jnz	ShotOff		;  este v kolizii s Vortonom
		lxi	d,6		; ano, je to Vorton
		dad	d		; posun na dalsi sprite
		jmp	NextCSpr0	; skoc spracovat dalsi sprite

;------------------------------------------------------------------------------
; Deaktivovanie spritu (Strely).
; I: (SP)=adresa struktury spritu (Shot (01h), LasShot (11h))
ShotOff:	pop	h
		mvi	m,0FEh		; deaktivuj sprite
		jmp	NextMSpr	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Nahodna zmena smeru po narazeni do ineho spritu,
; ale vzdy iba "v pravom uhle" - V, J, Z, S
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Cyclop (02h), Disk (12h)
ChDir2:		call	Rand		; nahodna hodnota do A
		ani	6		; odmaskuj iba potrebny rozsah
		dcx	b		; (7) - smer spritu
		stax	b		; a uloz ako novu hodnotu smeru
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Nahodna zmena smeru po narazeni do ineho spritu - do vsetkych smerov.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Eye (03h), Disk (13h)
ChDir3:		call	Rand		; nahodna hodnota do A
		ani	7		; odmaskuj iba potrebny rozsah
		dcx	b		; (7) - smer spritu
		stax	b		; a uloz ako novu hodnotu smeru
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Случайное изменение направления после столкновения с другим объектом.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Frog (04h), Frog (14h)
ChDir4:		mov	e,c		; presun adresu do DE
		mov	d,b
;ChDir4Y:	mvi	a,0		; Y po kolizii
;		cpi	49h		; ak by bola po posune Y suradnica
;		jnc	ChDir4D		; mimo rozsah <0, 48h>, skoc dalej
		mvi	a,4
		add	e
		mov	e,a		; (12) - init hodnota smeru
		call	Rand		; nahodna hodnota do A
		ani	7		; odmaskuj iba potrebny rozsah
		stax	d		; a uloz ako init hodnotu smeru
		jmp	ProcSprNoCollD	; pokracuj zmenou smeru spritu Frog

; Sprite Frog (04h) mal tendenciu zaseknut sa pri Severnom alebo Juznom okraji
; drahy. Dovodom je zrejme rutina Rand, ktora sa lisi od povodnej zo ZX Spectra.
; Preto sa zmeni smer spritu J <-> S.
;ChDir4D:	xchg
;		dcx	h		; (7) - smer spritu
;		mvi	a,8		; zmen smer J <-> S
;		sub	m
;		mov	m,a		; uloz novu hodnotu smeru
;		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Zmena smeru na opacny.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Star (05h), Cyclop (15h)
ChDir5:		dcx	b		; (7) - smer spritu
		ldax	b		; vezmi aktualny smer
		adi	4		; zmen na opacny
		ani	7		; odmaskuj iba potrebny rozsah
		stax	b		; a uloz novu hodnotu smeru
		jmp	NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Обработка движения Lasertron.
LTronMove:	lxi	h,SprStructLT+8	; adresa rychlosti Lasertronu
		mov	a,m
		ana	a		; je nulova?
		jz	LTronMoveE	; ano, skoc dalej
		lxi	h,SprStructLT+2	; adresa pozicie LT
		mov	b,m		; pozicia LT do BC
		dcr	l		; (1)
		mov	c,m
		dcr	l		; (0)
		lxi	d,-16		; offset na predchadzajuceho Auto-Vortona
		mvi	a,4		; 4 Auto-Vortoni
		jmp	LTronMoveB

LTronMoveA:	mvi	a,4		; pocitadlo AV vrat do A
		dcr	a		; zniz pocitadlo
		jz	LTronMoveC	; ak uz nie je aktivny ziadny AV, skoc
LTronMoveB:	sta	LTronMoveA+1	; odpamataj pocitadlo AV
		dad	d		; posun sa na strukturu AV
		mov	a,m		; (0) - Y pozicia AV
		cpi	0FEh		; je aktivny tento AV?
		jnc	LTronMoveA	; nie, skoc skusit dalsieho
		mvi	a,6		; posun sa na kod spritu
		add	l
		mov	l,a
		mov	a,m		; (6) - kod spritu
		ana	a		; je to uz Hlavny Vorton ?
		jz	LTronMoveC	; ano, skoc dalej
		mvi	a,-4
		add	l
		mov	l,a		; (2)
		mov	d,m		; - XH
		dcr	l		; (1)
		mov	e,m		; - XL
		call	SubDEBC		; porovnaj vdialenost medzi AV a LT
					; rozdiel vzdialenosti moze byt max 10h
		inr	a		; ak je vacsi,
		jnz	LTronMoveC	;  skoc skusit Hlavneho Vortona
		mov	a,e
		cpi	0F0h		; ak je v rozsahu,
		jnc	LTronMoveF	;  skoc spracovat posun LT

		; test, ci je Hlavny Vorton pred Lasertronom
LTronMoveC:	lhld	VortonStruct	; adresa struktury aktualneho Vortona do HL
		mov	a,m		; aby mohol Vorton tlacit LT, Y pozicia
		cpi	2Ch		;  musi byt v intervale <1Dh, 2Bh>
		jnc	LTronMoveD	; ak nie je, skoc dalej
		cpi	1Dh
		jc	LTronMoveD
		inr	l		; (1)
		mov	e,m
		inr	l		; (2)
		mov	d,m		; X pozicia Vortona do DE
		call	SubDEBC		; porovnaj vdialenost medzi Vortonom a LT
					; rozdiel vzdialenosti moze byt max 10h
		inr	a		; ak je vacsi,
		jnz	LTronMoveD	;  skoc zastavit LT
		mov	a,e
		cpi	0F0h		; ak je v rozsahu,
		jnc	LTronMoveF	;  skoc spracovat posun LT

LTronMoveD:	xra	a		; attr. pre "zhasnutie" sipky nad LT na panely
		sta	SprStructLT+8	; zastav LT - vynuluj jeho Rychlost
LTronMoveE:	mov	h,a
		mov	l,a
LTronMoveG:	lxi	d,HILO(24,16)
		mov	a,h
		call	Print88
		mov	a,l
		jmp	Print88

LTronMoveF:	lda	LTronStep	; pocitadlo krokov LT
		inr	a		; inkrement
		ani	7		; uprav na rozsah <0, 7>
		sta	LTronStep	; uloz novu hodnotu
		jz	LTronMoveE	; ak je nulova, skoc zhasnut sipku
		cpi	4		; ak ma polovicnu hodnotu,
		rnz
		mvi	b,1		; zvys Score o 10 bodov
		call	IncScore
		lxi	h,HILO(27,28)	; znaky sipky nad LT na panely
		jmp	LTronMoveG	; skoc zobrazit sipku

;------------------------------------------------------------------------------
IncPower:	push	d		; odpamataj pouzivane registre
		push	b
		push	psw
		lda	PowerIndik	; stlpec posledneho dielika POWER
		inr	a		; inkrementuj
		sta	PowerIndik	; a uloz novu hodnotu
		mov	e,a		; stlpec
		mvi	d,24		; a riadok pre POWER
		adi	2		; kod znaku pre konkretny znak POWER
		call	Print88		; zobraz znak
		pop	psw		; obnov registre
		pop	b
		pop	d
		ret

;------------------------------------------------------------------------------
IncScore:	lxi	h,Score+5	; adresa Score - desiatky
		lxi	d,10		; D=0, E=10
IncScoreA:	mov	a,m		; vezmi cislicu
		cmp	e		; je to medzera?
		jnz	IncScoreB	; nie, skoc dalej
		xra	a		; z medzery bude cislica 0
IncScoreB:	inr	a		; inkrementuj cislicu
		cmp	e		; naplnil sa tento rad?
		jnz	IncScoreC	; nie, skoc dalej
		mov	m,d		; ano, nastav ho na nulu
		dcx	h		; presun sa na dalsi rad (cislicu)
		jmp	IncScoreA

IncScoreC:	mov	m,a		; uloz novu hodnotu
		dcr	b
		jnz	IncScore	; opakuj pre celu vysku inkrementu

		jmp	PrtScore	; zobraz novu hodnotu

;------------------------------------------------------------------------------
InitSpdLvl:	lda	SpeedLevel	; uroven rychlosti
		ora	a		; ak je 0
		rz			; nerob nic
		dcr	a		; inak zniz o 1 uroven
		sta	SpeedLevel	; a uloz
		lxi	h,SprList+6	; adresa zoznamu spritov
		lxi	d,16		; offset na dalsiu strukturu
InitSpdLvlA:	mov	a,m		; (6) - kod spritu
		ani	0Fh		; ponechaj zakladny kod
		cpi	5		; vybranym pohyblivym spritom
		jnc	InitSpdLvlB
		inx	h		; (7)
		inx	h		; (8)
		dcr	m		; zniz bazovu rychlost
		dcx	h		; (7)
		dcx	h		; (6)
InitSpdLvlB:	dad	d
		mov	a,h		; az po Vortonov a spol
		cpi	SprListVL/256
		jc	InitSpdLvlA
		jmp	InitSpdLvl	; opakuj, kym nebude SpeedLevel 0

;------------------------------------------------------------------------------
CheckScore:	lxi	h,HiScore	; porovnaj Score a HiScore
		lxi	d,Score
		mvi	b,7		; 7 cislic
CheckScoreA:	ldax	d		; cislica Score
		cmp	m		; porovnaj s HiScore
		jz	CheckScoreB	; su rovnake, prejdi na dalsiu cislicu
		jnc	CheckScoreC	; cislica Score > HiScore, skoc
		mov	a,m		; cislica HiScore > Score
		cpi	10		; ak je cislica HiScore medzera,
		jz	CheckScoreD	;  Score > HiScore, skoc
CheckScoreB:	inx	h		; dalsia cislica
		inx	d
		dcr	b
		jnz	CheckScoreA
		jmp	PrtHiScore

CheckScoreC:	cpi	10		; ak je cislica Score medzera,
		jz	PrtHiScore	;  HiScore > Score, skoc
CheckScoreD:	lxi	h,Score		; Score > HiScore
		lxi	d,HiScore	;  skopiruj Score do HiScore
		mvi	b,7		; 7 cislic
		call	Copy8
		jmp	PrtHiScore	

;------------------------------------------------------------------------------
