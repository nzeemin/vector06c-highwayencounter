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
StartGame:	call CheckScore; porovnaj Score/HiScore a aktualizuj HI
		ld hl,Score		; vynuluj Skore
		ld bc, (6<<8)|10
ZeroScore:	ld (HL),c
		inc hl
		dec b
		jp NZ,ZeroScore
		ld (HL),b
		call PrintScore	; zobraz Score

		call InitSpdLvl	; inicializuj uroven rychlosti na 0
PlayAgain:	call Intro; uvodne intro

	if CheatZone0
		ld hl,SprStructV1+1
		ld de,14E8h
		ld (HL),e
		inc hl
		ld (HL),d
		inc hl
		ld de,0FEF0h
		ld (HL),e
		inc hl
		ld (HL),d
		inc hl		; (5)
		inc hl		; (6)
		inc hl		; (7)
		inc hl		; (8)
		inc hl		; (9)
		ld (HL),0

		ld hl,SprStructLT+1
		ld de,14D8h
		ld (HL),e		; (1)
		inc hl
		ld (HL),d		; (2)
		inc hl
		ld de,0045h
		ld (HL),e		; (3)
		inc hl
		ld (HL),d		; (4)
		inc hl		; (5)
		inc hl		; (6)
		inc hl		; (7)
		inc hl		; (8)
		inc hl		; (9)
		ld (HL),1

		jp CheatJ
	endif

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
;		lxi	b, (17<<8)|2	;  text, ze ho bude treba prekreslit z VO1
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
GameFrame:	call UndrawSpr; zmaz sprity z VO2
		call TestKbdJoy	; otestuj kbd/joy
		call ProcMove	; spracuj posuny podla stavu klaves
		call ProcSpr		; spracuj pohyb spritov a ich kolizie
		call SortSpr		; zorad sprity podla IZO hlbky
		call DrawSpr		; vykresli sprity
		call RedrawChangesDI	; prekresli zmeny
		call LTronMove	; zobraz posun LaserTronu na panely
		call Sound		; spracuj zvuky

		; cakanie na LaserTron v Zone 0
		ld A,(ZoneNumber)	; cislo zony
		cp 30		; ak to nie je zona 0,
		jp C,DecTime		; skoc dalej
		ld hl,SprStructLT+1	; adresa struktury LaserTronu
		ld e,(HL)		; pozicia LT DE
		inc hl
		ld d,(HL)
		ld bc,156Ch		; pozicia v Zone 0
		call SubDEBC		; porovnaj, ci uz LT prisiel do Zony 0
		jp Z,LTronZone0	; ak ano, skoc dalej

		; dekrement casu
DecTime:	ld HL,(TimeDelay); zdrzanie na jeden dielik casu
	if ~~CheatNoTime
		dec hl		; zniz
	endif
		ld a,l		; je nulovy?
		or h
		jp NZ,DecTimeE	; nie, skoc ulozit novu hodnotu
		ld A,(TimePos)		; znakovy stlpec dielika casu
		rra			; vydel /2 - CY=1 pre dvojdielik
		ld e,a		; do E
		ld d,26		; riadok pre TIME
		jp C,DecTimeB	; pre dvojdielik, skoc dalej
		xor a		; medzera
		call Print88		; zmaz jednodielik
		dec e		; zniz znakovy stlpec na povodny
		scf			; CY=1 pre dvojdielik
		jp DecTimeC

DecTimeB:	ld a,26; jednodielik
		call Print88		; zobraz jednodielik
DecTimeC:	dec e; zniz znakovy stlpec na predchadzajuci
		ld a,e		; do A
		rla			; pripoj CY do 0. bitu
		ld (TimePos),A		; a uloz novu hodnotu
		cp 19*2		; bol to uz posledny dielik casu?
		jp NC,DecTimeD	; nie, skoc dalej
		; cas vyprsal ...
		ld hl,TTooLate	; text "TOO LATE, MISSION TERMINATED"
		jp Print85Text	; skoc zobrazit text a ukoncit hru

DecTimeD:	ld hl,3500; inicializuj zdrzanie pre dalsi dielik casu
DecTimeE:	ld (TimeDelay),HL; uloz novu hodnotu zdrzania

		; test na stratu Vortona
		ld HL,(VortonStruct)	; adresa struktury aktualneho Vortona
		ld a,(HL)		; nastala strata Vortona?
		cp 0FEh
		jp C,GameLoop	; nie, vrat sa do hlavnej hernej slucky

		ld A,(VortonHead)	; znakovy stlpec hlavy akt. Vortona na panely
		ld e,a		; uloz do E
LostVorton:	ld bc,16; offset na dalsiu strukturu
LostVortonA:	add HL,bc; prejdi na nasledujuceho Vortona
		inc e		; posun znakovy stlpec na dalsiu "hlavu"
		inc e
		ld a,l		; presli sme uz vsetkych Vortonov
		cp SprStructLT&255
		jp C,LostVortonB	; nie, skoc dalej
		; koniec hry
		ld hl,TGameOver	; text "GAME OVER, ALL VORTONS DESTROYED"
		jp Print85Text	; zobraz text a ukonci hru

LostVortonB:	ld a,(HL); je to aktivny sprite (Vorton)?
		cp 0FEh
		jp NC,LostVortonA	; nie, skoc skusit dalsieho
		ld (VortonStruct),HL	; uloz novu adresu aktualneho Vortona
		ld a,8
		add A,l
		ld l,a		; (8) - rychlost pohybu spritu
		ld a,(HL)		; je Vorton aktivny?
		or a
		jp M,LostVortonA	; nie, skoc skusit dalsieho
		ld a,e		; uloz aktualnu poziciu
		ld (VortonHead),A	; aktivneho Vortona na panely
		ld d,20		; znakovy riadok hlavy Vortona
		ld a,29		; zobraz hlavu pre noveho aktualneho
		call Print88		; Vortona
		ld a,30
		call Print88
		dec l		; (7)
		dec l		; (6) - "kod" spritu
		ld a,(HL)		; urob z AutoVortona (10h) Vortona (00h)
		and 0Fh
		ld (HL),a
		dec l		; (5) - sekvencia spritu
		ld (HL),0		; vynuluj sekvenciu
		ld a,5		; presun ukazatel v strukture
		add A,l
		ld l,a		; (10) - offset do zozamu pre urcenie sekvencie spritu
		ld (HL),0Eh		; nastav na Seq0E
CheatJ:		call PrepSpr; priprav sprity
		call DrawZone	; vykresli Zonu
		jp GameLoop	; vrat sa do hernej slucky

;------------------------------------------------------------------------------
; Демонстрационный режим.
; Zobrazi Intro - prichod Vortona a Auto-Vortonov.
; Ukaze vsetky Zony 30 az 0.
Demo:		call Intro; uvodne intro
	if DebugDemoLvl == -1
		jp DemoB
	else
		ld hl,SprStructV5+8	; zastav posledneho Vortona
		ld (HL),0
		ld HL,(VortonStruct)	; adresa struktury aktualneho Vortona
		ld (HL),0FEh		; deaktivuj ho
		inc l
		inc l
		ld de,(31-DebugDemoLvl)*0B0h
		jp DemoX
	endif

DemoA:		call PrepSpr; priprav sprity
		call DrawZone	; vykresli dalsiu Zonu
DemoB:		ld hl,TDemoMode; text "DEMO MODE"
		call Print85Text	; zobraz text

		ld b,40		; 40 krokov
DemoC:		push bc; odpamataj pocitadlo
		call OneStep		; vykonaj krok
		pop bc		; obnov pocitadlo
		;in	SysPB		; bol stlaceny Stop/Shift?
		cpl
		and 60h
		ret NZ			; ano, vrat sa
		dec b
		jp NZ,DemoC		; opakuj pre dany pocet framov

		ld A,(ZoneNumber)	; cislo zony
	if DebugDemoLvl == -1
		cp 1Fh		; sme v zone 0?
	else
		cp 25h
	endif
		jp NC,DemoD		; ano, skoc dalej
		ld hl,SprStructV5+8	; zastav posledneho Vortona
		ld (HL),0
		ld HL,(VortonStruct)	; adresa struktury aktualneho Vortona
		ld (HL),0FEh		; deaktivuj ho
		inc l
		ld e,(HL)		; jeho pozicia
		inc l
		ld d,(HL)
		ex DE,HL			;  do HL
		ld bc,0B0h		; posun ho do dalsej miestnosti
		add HL,bc
		ex DE,HL
DemoX:		ld (HL),d; a uloz do struktury
		dec l
		ld (HL),e
		jp DemoA

DemoD:		ld hl,InnerScr; vymaz VO
		ld bc,VVO*SVO
		call Fill16Z

		ld hl,InnerScr	; vykresli oramovanie
		ld de,InnerScr+(143*SVO)
		ld c,VVO-2		; vyska mriezky -2
		call DrawBord

 		ld l,VVO		; vykresli do VRAM
		ld de,InnerScr
		ld bc,BaseVramAdr
		call DrawInnerScr

		ld hl,TOneWay	; text "THERE IS ONLY ONE WAY..."
		call Print85Text	; zobraz text
		jp WaitAnyKeyT10

;------------------------------------------------------------------------------
ShowPanel:	call Cls; zmazanie obrazovky

	if UsePackedGrp
		ld hl,GamePanel		; rozpakovanie panelu
		ld de,0C000h-GamePaneSize
		call dzx7
		ld hl,BaseVramAdr+(152*64)+1	; vykreslenie panelu
		ld de,0C000h-GamePaneSize
		ld bc, (41<<8)|35
		call DrawSprite
	else
		ld hl,BaseVramAdr+(256-184)	; vykreslenie panelu
		ld de,GamePanel
		ld bc,(32<<8)|34
		call DrawSprite
	endif

		ld de, (24<<8)|19
		ld hl, (4<<8)|21
ShowPanelP:	ld a,l
		call Print88
		inc l
		dec h
		jp NZ,ShowPanelP

		ld de, (26<<8)|19
		ld hl, (4<<8)|25
ShowPanelT:	ld a,l
		call Print88
		dec h
		jp NZ,ShowPanelT

		call PrtScore		; zobraz Score a HiScore
		jp PrtHiScore

;------------------------------------------------------------------------------
; Начальная анимация
; - iniciaizacia premennych
; - zobrazenie panelu a Zony 30
; - prichod Vortonov a Lasetronu
Intro:		ld hl,BackupVars; inicializuj pociatocne hodnoty
		ld de,Vars		; premennych
		ld b,VarsLen
		call Copy8
		call ShowPanel	; zmaz obr. a zobraz dolny panel
		call InitSpr		; inicializuj sprity
		call PrepSpr		; priprav sprity
		call DrawZone	; vykresli Zonu 30
		ld a,0FFh		; vyprazdni zoznam aktivnych spritov
		ld (SprPrepList),A

		ld a,1		; aktivuj pohyb hlavneho Vortona
		ld (SprStructV1+8),A
		xor a		; ziadna zmena rychlosti a otocenia
		ld b,16		; 16 krokov
		call AutoStep	; vykonaj
IntroA:		ld a,5; FLRUD - zabrzdi Vortona a otacaj doprava
		ld b,1		; jeden krok
		call AutoStep	; vykonaj
		sub 6		; otacaj Vortona, kym nebude otoceny
		jp NZ,IntroA		;  na Sever
		inc a		; aktivuj pohyb hlavneho Vortona
		ld (SprStructV1+8),A
		xor a		; ziadna zmena rychlosti a otocenia
		ld b,14		; 14 krokov
		call AutoStep	; vykonaj
IntroB:		ld a,4; FLRUD - otacaj Vortona doprava
		ld b,1		; 1 krok
		call AutoStep	; vykonaj
		and a		; otacaj, kym nebude otoceny na vychod
		jp NZ,IntroB
IntroC:		ld a,5; FLRUD - zabrzdi Vortona a otacaj doprava
		ld b,1		; 1 krok
		call AutoStep	; vykonaj
		cp 3		; otacaj Vortona, kym nebude otoceny
		jp NZ,IntroC		;  na Juho-Zapad
		ld hl,SprStructV2+8	; aktivuj pohyb Auto-Vortonov
		ld de,16
		ld bc, (4<<8)|1
IntroD:		ld (HL),c
		add HL,de
		dec b
		jp NZ,IntroD
		xor a		; ziadna zmena rychlosti a otocenia
		ld b,39		; 39 krokov
		call AutoStep	; vykonaj
		ld hl,SprStructV2+7 ; zmen smer pohybu Auto-Vortonov
		ld de,16
		ld bc, (7<<8)|1
		ld (HL),b		; Severo-Vychod
		add HL,de
		ld (HL),c		; Juho-Vychod
		add HL,de
		ld (HL),b		; Severo-Vychod
		add HL,de
		ld (HL),c		; Juho-Vychod
		xor a		; ziadna zmena rychlosti a otocenia
		ld b,12		; 12 krokov
		call AutoStep	; vykonaj
		ld hl,SprStructV2+7 ; zastav Auto-Vortonov a nastav smer
		ld de,15		;  pohybu na Vychod
		ld b,4
IntroE:		ld (HL),d; smer na Vychod
		inc hl
		ld (HL),d		; zastav pohyb
		add HL,de
		dec b
		jp NZ,IntroE
IntroF:		ld a,9; FLRUD - zabrzdi Vortona a otacaj dolava
		ld b,1		; 1 krok
		call AutoStep	; vykonaj
		dec a		; otacaj Vortona, kym nebude otoceny
		jp NZ,IntroF		;  na Juho-Vychod
		inc a		; aktivuj pohyb hlavneho Vortona
		ld (SprStructV1+8),A
		xor a		; ziadna zmena rychlosti a otocenia
		ld b,32		; 32 krokov
		call AutoStep	; vykonaj
IntroG:		ld a,9; FLRUD - zabrzdi Vortona a otacaj dolava
		ld b,1		; 1 krok
		call AutoStep	; vykonaj
		and a		; otacaj Vortona, kym nebude otoceny
		jp NZ,IntroG		;  na Vychod
		ld hl,SprStructV2+8	; aktivuj pohyb Auto-Vortonov
		ld de,16
		ld bc, (4<<8)|1
IntroH:		ld (HL),c
		add HL,de
		dec b
		jp NZ,IntroH

		jp PrepSprZ	; priprav sprity

;------------------------------------------------------------------------------
; Автоматический шаг Vorton в нужном направлении.
; I: A=maska smeru/otacania Vortona, B=pocet krokov
; O: A=aktualne otocenie Vortona
AutoStep:	ld (KbdState),A; - FLRUD
AutoStepL:	push bc; odpamataj pocitadlo
		call UndrawSpr	; zmaz sprity z VO2
		call ProcMove	; spracuj posuny podla stavu klaves
		call ProcSpr		; spracuj pohyb spritov a ich kolizie
		call SortSpr		; zorad sprity podla IZO hlbky
		call DrawSpr		; vykresli sprity
		call RedrawChangesDI	; prekresli zmeny
		call LTronMove	; zobraz posun LaserTronu na panely
		call Sound		; spracuj zvuky
		pop bc		; obnov pocitadlo
		dec b
		jp NZ,AutoStepL	; opakuj pre pozadovany pocet krokov
		ld A,(SprStructV1+7)	; aktualne otocenie Vortona do A
		ret

;------------------------------------------------------------------------------
OneStep:	call UndrawSpr; zmaz sprity z VO2
		call ProcSeq		; spracuj zmeny sekvencii spritov
		call ProcSpr		; spracuj pohyb spritov a ich kolizie
		call SortSpr		; zorad sprity podla IZO hlbky
		call DrawSpr		; vykresli sprity
		call RedrawChangesDI	; prekresli zmeny
		call LTronMove	; zobraz posun LaserTronu na panely
		jp Sound		; spracuj zvuky

;------------------------------------------------------------------------------
LTronZone0:	ld b,5; deaktivuj vsetkych zostavajucich
		ld hl,SprListVL	; Vortonov
DeactVortA:	ld a,(HL); je to aktivny Vorton?
		cp 0FEh
		jp NC,DeactVortB	; nie, skoc dalej
		ld a,5
		add A,l
		ld l,a		; (5)
		ld (HL),80h		; nastav sprite SprBlast
		inc l		; (6)
		inc l		; (7)
		inc l		; (8)
		ld a,(HL)
		or 80h		; deaktivuj ho - vybuchne
		ld (HL),a
		ld a,-8
		add A,l
		ld l,a		; (0)
		ld de,SndType	; premenna pre naplanovanie zvuku
		ld A,(de)
		or 1<<6		; "naplanuj" zvukovy efekt vybuch
		ld (de),A
		push bc
		push hl
		ld b,100		; zvys Score o 1000 bodov
		call IncScore
		pop hl
		pop bc
DeactVortB:	ld de,16; posun na dalsiu strukturu
		add HL,de
		dec b
		jp NZ,DeactVortA	; opakuj pre vsetkych Vortonov
		ld a,8
		add A,l
		ld l,a		; (8)
		ld (HL),b		; aktivuj Lasertron
		ld b,24		; 24 krokov
		xor a		; ziadna zmena rychlosti a otocenia
		call AutoStep	; vykonaj
		ld hl,SprStructLT	; nastav Lasertron
		ld (VortonStruct),HL	; ako aktualny Vorton sprite
		ld b,15		; 15 krokov
		xor a		; ziadna zmena rychlosti a otocenia
		call AutoStep	; vykonaj

		; zmazanie hornej casti panelu s cislami Vortonov
		ld hl,BaseVramAdr+(155*64)+9
		ld de,64-12
		ld c,5		; vyska 5 mikroriadkov
CleanPanelA:	ld b,12; sirka 12 znakovych stlpcov
CleanPanelB:	ld (HL),d; vymaz
		inc hl
		dec b
		jp NZ,CleanPanelB	; opakuj
		add HL,de		; prejdi na dalsi mikroriadok
		dec c		; opakuj pre vsetky mikroriadky
		jp NZ,CleanPanelA

		; skrytie Lasertronu na Panely
		ld hl,BaseVramAdr+(173*64)+21
		ld de,64-2
		ld c,10		; vyska 10 mikroriadkov
CleanPanelC:	ld (HL),d; vymaz
		inc hl
		ld (HL),d
		inc hl
		ld (HL),d
		add HL,de		; prejdi na dalsi mikroriadok
		dec c		; opakuj pre vsetky mikroriadky
		jp NZ,CleanPanelC

		; zobrazenie nadpisu "LASERTRON .ACTIVATED."
		ld hl,BaseVramAdr+(163*64)+11
		ld de,LtronAct
		ld bc, (10<<8)|13
		call DrawSprite

		; zvuk pri aktivacii Lasertronu
		ld de,1E28h
		ld hl,0204h
		call SoundW		; zahraj si...

		; posun Lasertronu az na koniec Zony 0
LTronZone0E:	ld hl,SprStructLT+8; nastav rychlost Lasertronu
		ld (HL),1		; na 1
		call OneStep		; vykonaj jeden krok
		ld A,(ZoneNumberT)	; uz je Lasertron na konci Zony 0?
		cp 36
		jp C,LTronZone0E	; ak nie, posuvaj ho dalej

		; otvorenie Lasertronu
LTronOpen:	ld b,20; 20 krokov
		xor a		; ziadna zmena rychlosti a otocenia
		call AutoStep	; vykonaj
		ld c,3		; 3 fazy otvorenia Lasertronu
LTronOpenA:	ld b,3; 3 kroky
LTronOpenB:	push bc
		call OneStep		; vykonaj krok
		pop bc
		dec b
		jp NZ,LTronOpenB
		ld hl,SprStructLT+5	; sekvencia spritu Lasertron
		inc (HL)		; posun sa na dalsiu sekvenciu
		inc (HL)
		dec c		; opakuj kym nie je Lasertron pripraveny
		jp NZ,LTronOpenA
		ld b,20		; 20 krokov
LTronShotA:	push bc
		call OneStep		; vykonaj krok
		pop bc
		dec b
		jp NZ,LTronShotA

		; vystrel Lasertronu
		ld de,16		; offset na dalsiu struturu
		ld hl,SprStructS1+5	; sekvencia spritu Strela
		ld b,3		; vsetky 3 strely budu SprLasShot1
LTronShotB:	ld (HL),20h; zapis
		add HL,de		; dalsia strela
		dec b
		jp NZ,LTronShotB
		ld a,6		; inicializacna hodnota pre
		ld (ShotTime+1),A	;   cas letu pre tuto Strelu
		ld b,60		; 60 krokov
		ld a,16		; Fire
		call AutoStep	; vykonaj - vystrel Lasertron Strely
		ld b,8		; 8 krokov
		xor a		; ziadna zmena smeru
		call AutoStep	; vykonaj
		ld a,22		; vrat povodnu hodnotu pre cas letu Strely
		ld (ShotTime+1),A

		; "vyparenie" Kozmickej lode
		ld de,InnerScr+(88*SVO)+14 ; адрес источника VO - tam je cista mriezka
		ld hl,InnerScr+14	; адрес назначения VO - tam je "Kozmicka" lod
		push hl
		ld hl,VanishData	; data pre "vyparenie" Kozmickej lode
		ld a,(HL)		; maska mazania dat z VO
		inc hl
		ex (SP),HL			; data na zasobnik, prvy ukazatel nazad do HL
VanishShipA:	cpl; invertuj ju a uloz na neskor
		ld (VanishShipC+1),A
		push hl		; odpamataj ukazatele
		push de
		ld c,22		; vyska 22*4 mikroriadkov
VanishShipB:	push de
		ld b,29		; sirka 29 bytov
VanishShipC:	ld a,0; maska
		and (HL)		; aplikuj masku na cielovy obsah
		ex DE,HL
		or (HL)		; pridaj zdrojove data
		ex DE,HL
		ld (HL),a		; vysledok uloz do VO
		inc hl		; posun sa na dalsi znakovy stlpec
		inc de
		dec b
		jp NZ,VanishShipC	; opakuj pre celu sirku
		ld a,c
		ld c,(4*SVO)-29
		add HL,bc		; posun cielovu adresu o 4 mikroriadky
		ex DE,HL
		pop hl
		ld c,4*SVO
		rrca
		rlca
		jp NC,VanishShipE
		ld bc,-(4*SVO)
VanishShipE:	add HL,bc; posun zdrojovu adresu o 4 mikroriadky hore/dole
		ex DE,HL
		ld c,a
		dec c		; opakuj pre celu vysku
		jp NZ,VanishShipB

		; dopln chybajuci horny okraj Zony
		ld hl,InnerScr+14
		ld bc, (28<<8)|3Fh
VanishShipD:	ld (HL),c
		inc hl
		dec b
		jp NZ,VanishShipD
		ld (HL),0Fh

		; vykreslenie kroku "vyparenia" Kozmickej lode
 		ld l,11*8
		ld de,InnerScr
		ld bc,BaseVramAdr
		call DrawInnerScr

		; zvuk po jednom kroku "vyparenia" Kozmickej lode
		ld hl,SoundI
		ld (HL),0A2h
		ld c,0Ah
		ld de,7F14h
		call SoundD

		pop de		; obnov ukazatele do VO
		pop hl

		; dalsi krok "vyparenia" Kozmickej lode
		ex (SP),HL
		ld c,(HL)		; offset (krok) do BC
		inc hl
		ld b,(HL)
		inc hl
		ld a,(HL)
		inc hl
		ex (SP),HL
		add HL,bc		; pripocitaj k zdrojovemu ukazatelu
		ex DE,HL
		add HL,bc		; pripocitaj k cielovemu ukazatelu
		ex DE,HL
		and a		; koniec zoznamu?
		jp NZ,VanishShipA	; nie, pokracuj
		pop hl

		; male zdrzanie
		ld c,0E0h
Wait1:		ld b,0E0h
Wait2:		dec b
		jp NZ,Wait2
		dec c
		jp NZ,Wait1

		; vymazanie nadpisu LASERTRON ACTIVATED
		ld hl,BaseVramAdr+(163*64)+11
		ld de,64-10
		ld c,13		; vyska 13 mikroriadkov
CleanLabelA:	ld b,10; sirka 10 znakovych stlpcov
CleanLabelB:	ld (HL),d; vymaz
		inc hl
		dec b
		jp NZ,CleanLabelB	; opakuj
		add HL,de		; prejdi na dalsi mikroriadok
		dec c		; opakuj pre vsetky mikroriadky
		jp NZ,CleanLabelA

		; uzatvorenie Lasertronu
		ld hl,SprPrepList	; vyprazdni zoznam pripravenych spritov
		ld (HL),0FFh
		ld c,3		; 3 fazy uzatvorenia Lasertronu
LTronCloseA:	ld b,3; 3 kroky
LTronCloseB:	push bc
		call OneStep		; vykonaj krok
		pop bc
		dec b
		jp NZ,LTronCloseB
		ld hl,SprStructLT+5	; sekvencia spritu Lasertron
		dec (HL)		; posun sa na dalsiu sekvenciu
		dec (HL)
		dec c		; opakuj kym nie je Lasertron pripraveny
		jp NZ,LTronCloseA
		ld b,20		; 20 krokov
LTronCloseC:	push bc
		call OneStep		; vykonaj krok
		pop bc
		dec b
		jp NZ,LTronCloseC

		; vybuch Lasertronu
		ld hl,SprStructLT+5 ; sekvencia spritu Lasertron
		ld (HL),80h		; nastav sprite SprBlast
		ld b,190		; 190 krokov
LTonBlastA:	push bc
		ld hl,SprStructLT+8	; rychlost LT
		ld (HL),80h		; nastav flag - sprite prave vybuchuje
		call OneStep		; vykonaj krok
		pop bc
		ld a,b		; ak ma pocitadlo prave hodnotu 135
		cp 135
		jp NZ,LTonBlastB
		push bc
		ld hl,TPrepare	; zobraz text "PREPARE YOURSELF ..."
		call Print85Text	; zobraz text
		pop bc
LTonBlastB:	dec b
		jp NZ,LTonBlastA	; a opakuj dany pocet krokov

		; zvysenie rychlosti pohyblivych spritov
		ld A,(SpeedLevel)	; uroven rychlosti
		cp 02h		; ak je uz >=2
		jp NC,PlayAgain	; nezvysuj ju dalej a skoc na zaciatok hry
		inc a		; +1
		ld (SpeedLevel),A	; a uloz novu uroven
		ld hl,SprList+6	; adresa zoznamu spritov
		ld de,16		; offset na dalsiu strukturu
IncSpeedA:	ld a,(HL); typ spritu
		and 0Fh		; ponechaj zakladny kod
		cp 5		; vybranym pohyblivym spritom
		jp NC,IncSpeedB
		inc hl		; (7)
		inc hl		; (8)
		inc (HL)		; zvys rychlost
		dec hl		; (7)
		dec hl		; (6)
IncSpeedB:	add HL,de; dalsi sprite
		ld a,h		; az po Vortonov
		cp SprListVL/256
		jp C,IncSpeedA

		jp PlayAgain	; skoc na zaciatok hry

;------------------------------------------------------------------------------
; Обработка смещения Vorton, выстрел по нажатию клавиш
ProcMove:	ld HL,(VortonStruct); adresa struktury aktualneho Vortona
		ld a,8		; posun sa na Rychlost
		add A,l
		ld l,a		; (8) - rychlost pohybu
		ld a,(HL)		; do A
		or a		; je Vorton aktivny?
		jp M,ProcSeq		; nie, skoc dalej
		ex DE,HL			; ukazatel na Rychlost do DE
		ld A,(KbdState)	; - FLRUD
		ld b,a		; stav Kbd do B

		; ускорение / замедление Vorton
		ld hl,ChngSpdDly	; premenna pre zdrzanie pred zmenou rychlosti
		dec (HL)		; zniz pocitadlo
		jp P,ProcMoveC	; ak nie je nulove, skoc dalej
		inc (HL)
		ld a,b
		rrca			; spomalenie?
		jp NC,ProcMoveA	; nie, skoc dalej
		ld A,(de)		; (8) - скорость
		dec a		; zniz rychlost
		jp M,ProcMoveC	; ak uz bola rychlost nulova, skoc dalej
		ld (de),A		; (8) - uloz novu rychlost
		jp ProcMoveB	; skoc dalej

ProcMoveA:	ld a,b; zrychlenie?
		and 2
		jp Z,ProcMoveC	; nie, skoc dalej
		ld A,(de)		; (8) - скорость
		inc a		; zvys rychlost
		cp 3		; ak je uz maximalna rychlost (2 !!),
		jp NC,ProcMoveC	; skoc dalej
		ld (de),A		; (8) - uloz novu rychlost
ProcMoveB:	dec a; je rychlost 1 ?
		jp NZ,ProcMoveC	; nie, skoc dalej
		ld (HL),7		; ano, inic. zdrzanie pre dalsiu zmenu rychlosti

		; вращение Vorton
ProcMoveC:	dec e; (7) - вращение
		inc hl		; posun sa na premennu pre zdrzanie pred zmenou otocenia
		dec (HL)		; zniz pocitadlo
		jp P,ProcMoveE	; ak nie je nulove, skoc dalej
		ld (HL),1		; inak inic. zdrzanie pre dalsiu zmenu otocenia
		ld a,b
		and 4		; вращение вправо?
		jp Z,ProcMoveD	; nie, skoc dalej
		ld A,(de)		; (7) - вращение
		inc a		; zvys hodnotu otocenia
		and 7		; a uprav na interval <0, 7>
		ld (de),A		; (7) - uloz novu hodnotu
ProcMoveD:	ld a,b; вращение влево?
		and 8
		jp Z,ProcMoveE	; nie, skoc dalej
		ld A,(de)		; (7) - вращение
		dec a		; zniz hodnotu otocenia
		and 7		; a uprav na interval <0, 7>
		ld (de),A		; (7) uloz novu hodnotu

		; osetrenie letiacich striel
ProcMoveE:	ex DE,HL; ukazatel na premenne do DE
		ld hl,SprStructS1	; adresa struktury 1. strely
		ld bc,16		; offset na strukturu dalsej Strely

ProcMoveF:	inc de; posun sa na premennu - cas letu Strely
		ld A,(de)		; do A
		cp 2		; ak su to 2 jednotky pred koncom
		call Z,IncPower	; zvys hodnotu POWER
		and a		; ak uz cas Strely vyprsal,
		jp NZ,ProcMoveG
		ld (HL),0FEh		; deaktivuj sprite Strely
		inc a		; korekcia pred dekrementom
ProcMoveG:	dec a; zniz pocitadlo casu Strely
		ld (de),A		; a uloz novu hodnotu
		add HL,bc		; prejdi na dalsiu struturu
		ld a,l
		cp ((SprStructS3+16)&255) ; opakuj pre vsetky 3 Strely
		jp NZ,ProcMoveF

		; выстрел
		ex DE,HL
		inc hl		; posun sa na premennu - zdrzanie pred dalsim vystrelom
		dec (HL)		; zniz pocitadlo
		jp P,ProcSeq		; ak nie je nulove, skoc dalej
		inc (HL)
		ld A,(KbdState)	; - FLRUD
		and 16		; je stlacene FIRE ?
		jp Z,ProcSeq		; nie, skoc dalej
		ex DE,HL
		ld bc,-16		; offset na predoslu strukturu
		add HL,bc		; posun sa na strunkturu 3. Strely
		dec de		; vrat sa na premennu - cas letu 3. Strely
		ld A,(de)		; cas letu do A
		and a		; je volna?
		jp Z,ProcMoveI	; ano, pouzi ju
		dec de		; posun sa na premennu - cas letu 2. Strely
		add HL,bc		; posun sa na strunkturu 2. Strely
		ld A,(de)		; cas letu do A
		and a		; je volna?
		jp Z,ProcMoveI	; ano, pouzi ju
		add HL,bc		; posun sa na strunkturu 1. Strely
		dec de		; posun sa na premennu - cas letu 1. Strely
		ld A,(de)		; cas letu do A
		and a		; je volna?
		jp NZ,ProcSeq		; ak nie, skoc dalej
ProcMoveI:	ex DE,HL; adresa struktury Strely do DE
ShotTime:	ld (HL),22; inicializuj cas letu pre tuto Strelu
		inc a		; inicializuj premennu pre zdrzanie vystrelu
		ld (FireDelay),A
		; inicializuj strukturu strely podla struktury Vortona
		ld HL,(VortonStruct)	; adresa struktury aktualneho Vortona
		ld b,5		; skopiruj data pozicie Vortona
		call Copy8		; do struktury Strely
		inc l		; (6)
		inc l		; (7)
		inc e		; (6)
		inc e		; (7)
		ld a,(HL)		; skopiruj sekvenciu (otocenie) spritu
		ld (de),A
		inc l		; (8)
		inc l		; (9)
		inc e		; (8)
		inc e		; (9)
		ld a,(HL)		; skopiruj typ vykreslovacej rutiny
		ld (de),A

		; po vystrele zniz POWER
		ld A,(PowerIndik)	; pozicia posledneho dielika POWER
		ld e,a		; stlpec pre POWER
		dec a		; zniz aktualny stlpec
		ld (PowerIndik),A	; uloz novu hodnotu
		ld d,24		; ряд для POWER
		xor a
		call Print88		; zmaz posledny znak POWER
		ld a,e		; kod znaku pre konkretny znak POWER
		dec e
		dec e
		call Print88		; zobraz znak

		; priprav zvuk vystrelu
		ld hl,SndType
		ld a,2
		or (HL)
		ld (HL),a

; Обработка изменений последовательности спрайтов
		; premenna Seq0E
ProcSeq:	ld de,Seq0E; adresa premennej Seq0E do DE
		ld HL,(VortonStruct)	; adresa struktury aktualneho Vortona
		ld a,7
		add A,l
		ld l,a		; (7) - sekvencia spritu (otocenie)
		ld a,(HL)
		add A,a		; zdvojnasob
		ld (de),A		; a uloz novu hodnotu

		; premenna Seq0F
		ld hl,CntSeq0F	; adresa pocitadla pre Seq0F
		dec (HL)		; zniz pocitadlo, bolo nulove?
		jp P,ProcSeqD	; nie, preskoc spracovanie premennej Seq0F
		ld (HL),2		; inicializuj pocitadlo
		ld hl,Seq0F		; adresa premennej Seq0F
		ld A,(IncSeq0F)	; inkrement pre Seq0F
		ld b,a		; uloz do B
		ld a,(HL)		; hodnota Seq0F
		add A,b		; pripocitaj inkrement
		cp 7		; ak je vysledok < 7,
		jp C,ProcSeqB	; je to OK, skoc
		ld a,b		; inak neguj hodnotu inkrementu
		cpl
		inc a
		ld (IncSeq0F),A	; uloz novu hodnotu
		ld b,a
		ld a,(HL)		; hodnota Seq0F
		add A,b		; pripocitaj inkrement
ProcSeqB:	ld (HL),a; a uloz

		inc l		; preskoc Seq10

		; premenna Seq11
		inc l		; Seq11
		ld a,(HL)		; hodnota Seq11 do A
		inc a		; +2
		inc a
		cp 7		; ak je vysledok < 7,
		jp C,ProcSeqC	; je to OK, skoc
		xor a		; inak vynuluj hodnotu
ProcSeqC:	ld (HL),a; uloz novu hodnotu

		; premenna Seq10
ProcSeqD:	ld hl,CntSeq10; adresa pocitadla pre Seq10
		dec (HL)		; zniz pocitadlo, bolo nulove?
		jp P,ProcSeqH	; preskoc spracovanie premennej Seq10
		ld (HL),1		; inicializuj pocitadlo
		ld hl,Seq10		; adresa premennej Seq10
		ld A,(IncSeq10)	; inkrement pre Seq10
		ld b,a		; uloz do B
		ld a,(HL)		; hodnota Seq10
		add A,b		; pripocitaj inkrement
		cp 7		; ak je vysledok < 7,
		jp C,ProcSeqF	; je to OK, skoc
		ld a,b		; inak neguj hodnotu inkrementu
		cpl
		inc a
		ld (IncSeq10),A	; uloz novu hodnotu
		ld b,a
		ld a,(HL)		; hodnota Seq10
		add A,b		; pripocitaj inkrement
ProcSeqF:	ld (HL),a; a uloz

		inc l		; Seq11

		; premenna Seq12
		inc l		; Seq12
		ld a,(HL)		; hodnota Seq12 do A
		inc a		; +2
		inc a
		cp 7		; ak je vysledok < 7,
		jp C,ProcSeqG	; je to OK, skoc
		xor a		; inak vynuluj hodnotu
ProcSeqG:	ld (HL),a; a uloz

		; premenna Seq13
ProcSeqH:	ld hl,Seq13; adresa premennej Seq13
		ld a,(HL)		; hodnota Seq13 do A
		inc a		; +2
		inc a
		cp 3		; ak je vysledok < 3,
		jp C,ProcSeqI	; je to OK, skoc
		xor a		; inak vynuluj hodnotu
ProcSeqI:	ld (HL),a; a uloz
		ret

;------------------------------------------------------------------------------
; Обработка движения объектов и их столкновений
ProcSpr:	ld HL,(VortonStruct); adresa struktury aktualneho Vortona
		ld a,(HL)		; Y suradnica
		cp 0FEh		; je Vorton aktivny?
		jp NC,NextMSpr	; nie, skoc spracovat dalsi "hlavny" sprite
		push hl		; odpamataj adresu struktury hl. spritu
		ld a,8
		add A,l
		ld l,a		; (8) - скорость
		ld a,(HL)		; скорость в A
		or a		; vybuchuje prave Vorton?
		jp P,ProcSprA	; nie, pokracuj dalej
		dec hl		; (7) - направление / последовательность / вращение
		ld (HL),0		; vynuluj sekvenciu spritu
		jp ProcSprE	; pokracuj dalej

ProcSprA:	ld a,-6
		add A,l
		ld l,a		; (2)
		ld b,(HL)
		dec hl		; (1)
		ld c,(HL)		; X координата Vorton в BC
		dec hl		; (0)
		ld a,b		; узнать, находится ли Вортон перед Зоной 30
		and a
		jp NZ,ProcSprB	; нет, переходим
		ld a,c		; это младший байт
		cp 0B0h
		jp C,ProcSprD	; je pred Zonou 30, preskoc test zmeny Zony

ProcSprB:	ex DE,HL; adresa struktury docasne do DE
		ld HL,(ZonePos)		; aktualna pozicia Zony do HL
		call SubBCHL		; over, ci Vorton opusta aktualnu Zonu
					; ak je rozdiel zaporny,
		jp NZ,ProcSprC	;  Vorton prechadza do predoslej Zony
		ex DE,HL			; adresa struktury nazad do HL
		ld a,c		; ak je rozdiel >= 0B0h,
		cp 0B0h		;  Vorton prechadza do nasledujucej Zony
		jp C,ProcSprD	; Vorton zostava v aktualnej Zone, skoc
ProcSprC:	call PrepSpr; priprav sprity
		call DrawZone	; vykresli novu Zonu
		ld HL,(VortonStruct)	; obnov do HL adresu struktury Vortona

ProcSprD:	ld a,8
		add A,l
		ld l,a		; (8)
		ld a,(HL)		; скорость движения Vorton
		and a		; je rychlost nulova?
		jp NZ,ProcSprM	; nie, skoc spracovat pohyb
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

		; slucka spracovania dalsieho spritu
ProcSprL:	push hl; odpamataj adresu struktury "hlavneho" spritu
		ld a,8
		add A,l
		ld l,a		; (8)
		ld a,(HL)		; скорость движения объекта
		and 0BFh		; vynuluj 6. bit - sprite v pohybe po odrazeni
					; ak nie je sprite v pohybe,
		jp Z,NextMSprP	;  skoc spracovat dalsi "hlavny" sprite
					; vybuchuje prave sprite?
		jp P,ProcSprM	; nie, skoc spracovat pohyb
		dec hl		; (7)
ProcSprE:	dec hl; (6)
		dec hl		; (5)
		ld a,(HL)		; sekvencia spritu vybuch
		add A,8		; posun sa na dalsiu sekvenciu vybuchu
		cp 0DCh		; конец взрыва?
		jp C,ProcSprF	; nie, skoc dalej
		inc hl		; (6)
		inc hl		; (7)
		inc hl		; (8)
		ld a,(HL)		; (8) - скорость объекта
		and 7Fh		; zrus flag vybuchu
		ld (HL),a		; a uloz
		jp ShotOff		; skoc deaktivovat sprite, prejdi na dalsi

ProcSprF:	ld (HL),a; (5) - uloz novu sekvenciu spritu
		inc hl		; (6) - kod spritu
		ld a,(HL)		; kod spritu do A
		and 0Fh		; ponechaj iba zakladny kod
		jp Z,ProcSprH	; ak je to Vorton, skoc dalej
		ld e,1<<3		; Snd3 pre pohyblive objekty
		cp 7		; ak su to pohyblive objekty,
		jp C,ProcSprG	; skoc nastavit zvuk a prejdi na dalsi sprite
		ld e,1<<7		; pre ostatne sprity Snd7
		jp ProcSprG	; skoc nastavit zvuk a prejdi na dalsi sprite

		; стирание Vortona с панели
ProcSprH:	ld a,l; z adresy struktury aktualneho Vortona
		rrca			; vypocitaj znakovy stlpec Vortona na panely
		rrca
		rrca
		and 1Fh
		add A,6
		ld e,a		; uloz do E
		ld d,24		; riadok, kde je Vorton na panely
		ld l,3		; vyska Vortona 3 znaky
ProcSprI:	xor a; zmaz lavy znak
		call Print88
		xor a		; zmaz pravy znak
		call Print88
		inc d		; dalsi riadok
		dec e		; vrat sa na prvy stlpec
		dec e
		dec l
		jp NZ,ProcSprI
		ld e,1<<6		; Snd6 pre Vortona
ProcSprG:	ld hl,SndType; adresa typu zvuku pri vybuchu do HL
		ld a,(HL)
		or e		; priprav zvuk
		ld (HL),a
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

		; spracovanie pohybu a kolizie spritov
ProcSprM:	dec a; rychlost pohybu -1 => <0,3>
		rrca			;
		rrca			; A = (A - 1) * 64
		ld e,a		; offset do tabulky podla rychlosti
		dec hl		; (7)
		ld a,(HL)		; sekvencia spritu (otocenie)
		add A,a		; x2
		add A,a		; x4
		add A,a		; x8
		add A,e		; + offset podla otocenia
		ld e,a		; uloz do E
		ld d,MovTable/256	; D = vyssi byte tabulky posunu spritu
		ld a,-7
		add A,l
		ld l,a		; (0) - pozicia Y spritu
		ld A,(de)		; inkrement Y pozicie spritu
		add A,(HL)		; pripocitaj Y poziciu spritu
;		sta	ChDir4Y+1	; uloz na neskor
		ex DE,HL			; adresa tabulky do HL, struktura do DE
		cp 49h		; ak by bola po posune Y suradnica
		jp NC,ProcSprO	; mimo rozsah <0, 48h>, skoc dalej
		sub 07h		; uprav Y suradnicu pre test kolizie
		ld (ProcSprColl+1),A	; a uloz na neskor
		inc hl		; posun sa na inkrement X
		ld c,(HL)		; inkrement X do BC
		inc hl
		ld b,(HL)
		ld (MovTablePtr+1),HL	; odpamataj ukazatel na tabulku
		ex DE,HL			; adresa struktury spritu do HL
		inc hl		; (1) - XL
		ld e,(HL)		; X pozicia spritu do DE
		inc hl		; (2) - XH
		ld d,(HL)
		ex DE,HL			; X pozicia spritu do HL, struktura do DE
		add HL,bc		; pripocitaj inkrement
		ld c,l
		ld b,h		; vysledok do BC
		ld HL,(ZonePosP)	; pozicia predchadzajucej Zony do HL
		call SubBCHL		; vypocitaj vzdialenost aktualneho spritu
					;   od predoslej Zony
		cp 02h		; ak je to maximalne rozdiel (takmer) 3 Zon
		jp C,ProcSprZ	; tak spracuj tento Sprite
		.db	1		; LXI B - preskoc nasledujuce 2 instrukcie
ProcSprO:	inc de; (1)
		inc de		; (2)
		ld a,7*2		; pokracuj, akoby sa narazilo do GlassBrick
		pop bc		; obnov adresu struktury hlavneho spritu
		push bc		; do BC a znovu uloz
		jp ProcSprCollC	; skoc vykonat nepriamy skok do rutiny

		; osetrenie kolizie aktualneho spritu s inym
ProcSprZ:	add HL,bc; vrat povodnu hodnotu pozicie X spritu
		ld bc,-7		; -7
		add HL,bc		; uprav X poziciu pre test kolizie
		ld (NextCSpr0+1),HL	; a uloz
; prejdeme vsetky sprity v danej Zone a preverime ich koliziu s hlavnym spritom
		ld HL,(VortonStruct)	; zacneme aktualnym Vortonom
NextCSpr0:	ld bc,0; X pozicia pre test kolizie
		ld a,(HL)		; Y suradnica spritu pre test na koliziu
		cp 0FEh		; je to aktivny sprite?
		jp C,ProcSprColl	; ano, skoc previest testy
		jp NZ,ProcSprNoColl	; ak je to koniec zoznamu, skoc dalej
NextCSpr16:	ld de,16; dalsi sprite
		add HL,de
		jp NextCSpr0	; skoc overit dalsi sprite

		; nenasla sa ziadna kolizia
ProcSprNoColl:	pop de; obnov adresu struktury hlavneho spritu
		push de		; do DE a znovu uloz
		ld A,(ProcSprColl+1)	; vrat Y poziciu na povodnu hodnotu
		add A,7
		ld (de),A		; a uloz do struktury spritu
		ld hl,7		; vrat X poziciu na povodnu hodnotu
		add HL,bc
		ex DE,HL			; a presun do DE
		inc hl		; (1)
		ld (HL),e		; a uloz do struktury spritu
		inc hl		; (2)
		ld (HL),d
		ld a,7		; posun sa na typ rutiny
		add A,l
		ld l,a		; (9) - тип процедуры
MovTablePtr:	ld de,0; obnov ukazatel do tabulky
		inc de		; posun ukazatel na inkrement typu rutiny
		ld A,(de)		; inkrement do A
		inc de		; posun ukazatel na inkrement VO2
		add A,(HL)		; pripocitaj inkrement k aktualnej hodnote
		jp M,ProcSprNoCollA	; ak je sucasna hodnota <0, uprav ju na kladnu
		cp 4		; ak sme v rozsahu {0, 1, 2},
		jp C,ProcSprNoCollC	; skoc novu hodnotu ulozit
		sub 4		; ak je sucasna hodnota >2,
		jp P,ProcSprNoCollB	;  uprav ju na povoleny rozsah

ProcSprNoCollA:	add A,4; uprav hodnotu na povoleny rozsah
ProcSprNoCollB:	inc de; pri opusteni znakovej pozicie, posun
		inc de		; ukazatel v tabulke na druhy inkrement
ProcSprNoCollC:	ld (HL),a; (9) - uloz novu hodnotu
		ld a,-5
		add A,l
		ld l,a		; (4)
		ld b,(HL)
		dec hl		; (3)
		ld c,(HL)		; sucasna adresa VO2 spritu do BC
		ex DE,HL
		ld a,(HL)
		inc hl
		ld h,(HL)
		ld l,a		; inkrement adresy VO2 do HL
		add HL,bc		; pripocitaj inkrement
		ex DE,HL
		ld (HL),e		; a uloz novu hodnotu
		inc hl		; (4)
		ld (HL),d
		inc hl		; (5)
		inc hl		; (6)
		ld a,(HL)		; kod spritu do A
		inc hl		; (7)
		ex DE,HL			; adresa struktury +7 do DE
		cp 4		; je to Sprite Frog?
		jp NZ,ProcSprNoCollE	; nie, skoc dalej
		; Frog (04h)
		ld a,5
		add A,e
		ld e,a		; (12)
ProcSprNoCollD:	call Rand; nahodna hodnota do (HL)
		ld A,(de)		; inicializacna hodnota pre sekvenciu
		add A,a		;  spritu (otocenie) *2
		ld b,0		; vypocitany offset uloz do BC
		ld c,a
		ld a,-5
		add A,e
		ld e,a		; (7)
		ld a,(HL)		; nahodna hodnota do A
;		rrc			; horne 4 bity na miesto dolnych
;		rrc
;		rrc
;		rrc
		ld hl,SeqMaskTab	; tabulka pre nahodnu zmenu sekvencie
		add HL,bc		; spritu - pripocitaj offset
		and (HL)		; na nahodnu hodnotu aplikuj masku
		inc hl
		or (HL)		; a pripoj definovanu hodnotu
		ld (de),A		; uloz novu sekvenciu
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

ProcSprNoCollE:	and 0Fh; ponechaj iba zakladny kod spritu
		cp 3		; je to sprite Eye alebo Disk?
		jp NZ,ProcSprNoCollG	; nie, skoc dalej
		; Eye (03h) alebo Disk (13h)
		call Rand		; nahodna hodnota do A
					; podla hodnoty, zvol zmenu sekvencie
		cp 0F5h		; ak je < 0F5h,
		jp C,ProcSprNoCollF	; skoc dalej
		ld A,(de)		; cislo sekvencie spritu sa dekrementuje
		dec a
		and 7		; uprav na rozsah <0, 7>
		ld (de),A		; uloz novu hodnotu sekvencie
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

ProcSprNoCollF:	cp 0Ah; ak je > 0Ah,
		jp NC,NextMSprP	;  skoc spracovat dalsi "hlavny" sprite
		ld A,(de)		; cislo sekvencie spritu sa inkrementuje
		inc a
		and 7		; uprav na rozsah <0, 7>
		ld (de),A		; uloz novu hodnotu sekvencie
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

ProcSprNoCollG:	cp 10; je to sprite Block alebo Barrel?
		jp NZ,NextMSprP	; nie, skoc spracovat dalsi "hlavny" sprite
		; Block (0Ah) alebo Barrel (1Ah)
		inc de		; (8)
NextMSprS:	ld A,(de); (8) - rychlost do A
		and 0BFh		; zrus flag, ze je Block/Barrel v pohybe
		rra			; vydel rychlost dvoma
		ld (de),A		; uloz novu hodnotu
NextMSprP:	pop hl
NextMSpr:	ld de,16; prejdi na dalsiu strukturu
NextMSprD:	add HL,de
		ld a,(HL)		; dalsi sprite
		cp 0FEh		; je aktivny?
		jp C,ProcSprL	; ano, skoc ho spracovat
		jp Z,NextMSprD	; nie, skus dalsi sprite
		ret

; pokracovanie osetrenia kolizie aktualneho spritu s inym
; (SP) = adresa hlavneho spritu
; BC = suradnica X "hlavneho" spritu
; (ProcSprColl+1) = suradnica Y "hlavneho" spritu
; HL = adresa struktury "kolizneho" spritu
; A = suradnica Y "kolizneho" spritu
ProcSprColl:	sub 0; porovnaj suradnice Y spritov
		cp 0Fh		; ak je rozdiel >= 0Fh
		jp NC,NextCSpr16	; sprity nie su v kolizii, skoc
		inc hl		; (1)
		ld e,(HL)		;
		inc hl		; (2)
		ld d,(HL)
		call SubDEBC		; porovnaj suradnice X spritov
		jp NZ,NextCSpr14	; ak je rozdiel >= 0Fh, sprity nie su v kolizii, skoc
		ld a,e		; este nizsi byte
		cp 0Fh
		jp C,ProcSprCollA	; su v kolizii, skoc
NextCSpr14:	ld de,14; prejdi na dalsi sprite
		add HL,de
		jp NextCSpr0

		; nasla sa kolizia
ProcSprCollA:	pop bc; adresa struktury "hlavneho" spritu
		push bc		; do BC a znovu uloz
		ld a,c		; este otestuj, ci to nie je ta ista
		inc a		;  struktura
		inc a
		cp l
		jp NZ,ProcSprCollB	; nie je, skoc
		ld a,b
		cp h
		jp Z,NextCSpr14	; je, prejdi na dalsi sprite

ProcSprCollB:	ex DE,HL; adresa "kolizneho" spritu +2 do DE
		ld a,4		; posun sa na typ "kolizneho" spritu
		add A,e		; (6)
		ld l,a
		ld h,d
		ld a,(HL)		; (6) typ spritu
		and 0Fh		; iba zakladny kod
		add A,a		; *2
ProcSprCollC:	ld l,a; uloz do L
		ld a,11		; posun sa na bazovy offset na zoznam
		add A,c		; "hlavneho" spritu
		ld c,a		; (11)
		ld A,(bc)		; bazovy offset na zoznam z "hlavneho" spritu
		add A,l		; pripocitaj bazovy offset na zoznam
		ld l,a		; obsluznych rutin kolizie
		ld h,RtnList/256	; HL=adresa v zozname rutin
		ld a,(HL)		; samotnu adresu obsluznej rutiny do HL
		inc hl
		ld h,(HL)
		ld l,a
		dec bc		; (10)
		dec bc		; (9)
		dec bc		; (8) - adresa "hlavneho" spritu +8 v BC
		jp (HL)			; skoc nepriamo do obsluznej rutiny
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
PushLTron:	ld a,4; prejdi na kod "kolizneho" spritu
		add A,e
		ld e,a		; (6) - kod spritu
		ld A,(de)
		and 10h		; je to BrickA (19h)?
		jp NZ,NextMSprSB	; ano, skoc znizit rychlost Vortona
		dec c		; (7) - otocenie Vortona
		ld A,(bc)		; otocenie Vortona do A
		inc c		; (8)
		dec a		; over povolene otocenie Vortona,
		dec a		;  aby mohol tlacit Lasertron
		cp 05h		; je Vorton otoceny na V, SV, JV?
		jp C,VortHit		; nie, skoc osetrit naraz
		inc e		; (7) - sekvencia "kolizneho" spritu
		xor a
		ld (de),A		; inak vynuluj sekvenciu Lasertronu
		inc e		; (8) - rychlost
		inc a
		ld (de),A		; nastav Lasertronu aj Vortonu
		ld (bc),A		; rychlost 1
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Osetrenie narazu Block (0Ah) do Barrel (1Ah) a naopak
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Block (0Ah), Barrel (1Ah)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Block (0Ah), Barrel (1Ah)
BlkBrlHit:	ld A,(bc); rychlost "hlavneho" spritu
		ld l,a		; do L
		and 40h		; je Block/Barrel v pohybe?
		jp NZ,BlkBrlHitA	; ano, skoc dalej
		ld a,l
		cp 02h		; je rychlost <2 ?
		jp C,NextMSprP	; ano, skoc spracovat dalsi "hlavny" sprite
NextMSprSB:	ld e,c; presun adresu struktury "hlavneho"
		ld d,b		; spritu do DE
		jp NextMSprS	; a skoc znizit rychlost

BlkBrlHitA:	ld a,l
		and 0BFh		; zrus flag "hlavneho" spritu v pohybe
		ld l,a		; nazad do L
		ld (bc),A		; a uloz do struktury
		ld a,4		; prejdi na kod "kolizneho" spritu
		add A,e
		ld e,a		; (6) - kod spritu
		ld A,(de)
		and 10h		; ak je to Barrel,
		ld a,l
		jp NZ,BlkBrlHitB	; preskoc znizenie rychlosti
		rra			; pre Block zniz rychlost
BlkBrlHitB:	inc e; (7)
		inc e		; (8) - rychlost spritu
		or 40h		; nastav flag, ze je Block/Barrel v pohybe
		ld (de),A		; uloz novu hodnotu
		dec e		; (7) - smer spritu
		dec c		; (7)
		ld A,(bc)		; skopiruj smer z jedneho spritu
		ld (de),A		; do druheho
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Zasiahnutie Block (0Ah), Barrel (1Ah) strelou.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Block (0Ah), Barrel (1Ah)
ShotBlkBrl:	ld a,-8; presun sa na suradnicu Y Strely
		add A,c
		ld c,a		; (0)
		ld a,0FEh		; deaktivuj strelu
		ld (bc),A
		ld a,8		; vrat sa na rychlost
		add A,c
		ld c,a		; (8)

; Narazenie Vrtona (00h) do Block (0Ah), Barrel (1Ah).
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vorton (00h), Auto-Vorton (10h), Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Block (0Ah), Barrel (1Ah)
VortBlkBrl:	ld a,05h; prejdi na sekvenciu spritu
		add A,e
		ld e,a		; (7) - smer spritu Vortona/Strely
		dec c		; (7) - smer spritu Block/Barell
		ld A,(bc)		; skopiruj smer Vortona/Strely
		ld (de),A		; do Block/Barell
		inc c		; (8) - rychlost Vortona/Strely
		ld A,(bc)
		ld l,a		; do L
		dec e		; (6) - kod "kolizneho" spritu
		ld A,(de)
		and 10h		; je to Barrel?
		ld a,l		;  - rychlost do A
		jp NZ,VortBlkBrlA	; ano, skoc
		rra			; vydel rychlost /2
VortBlkBrlA:	inc e; (7)
		inc e		; (8)
		or 40h		; nastav, ze sprite je v pohybe
		ld (de),A		; uloz novu rychlost

;---------------
; Vorton narazil do Auto-Vortona (10h), GlassBrick (07h, 17h), BrickB (08h), BrickA (18h).
; Z predosleho kodu Vorton/Strela narazili do Block (0Ah), Barrel (1Ah).
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vorton (00h), Auto-Vorton (10h), Shot (01h), LasShot (11h)
VortHit:	dec c; (7)
		dec c		; (6) - kod spritu
		ld A,(bc)		; do A
		inc c		; (7)
		inc c		; (8)
		dec a		; je to Vorton alebo Strela?
		jp M,VortonHitV	; ano, je to Vorton, skoc dalej
		jp NZ,NextMSprP	; ani jeden, skoc spracovat dalsi "hlavny" sprite
		ld e,1<<4		; Snd4 pre Strelu
		jp ProcSprG	; skoc pripravit zvuk
					; a spracovat dalsi "hlavny" sprite

VortonHitV:	ld de,0; ziadny zvuk
		ld hl,ChngSpdDly
		ld a,(HL)		; zdrzanie pri zmene rychlosti Vortona
		cp 7		; je to pociatocna hodnota?
		jp Z,VortonHitN	; ano, skoc - bez zvuku
		ld e,1<<4		; inak, naplanuj zvuk Snd4
VortonHitN:	ld A,(bc); (8)
		or a		; CY=0
		rra			; vydel /2 rychlost Vortona/Strely
		ld (bc),A		; a uloz
		or a
		jp Z,VortonHitZ	; ak je uz nulova, skoc vynulovat zdrzanie
		ld d,2		; zdrzanie 3 kroky
VortonHitZ:	ld (HL),d; uloz nove zdrzanie
		jp ProcSprG	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Prechod na dalsiu strukturu "kolizneho" spritu.
; I: DE=adresa +2 struktury "kolizneho" spritu
NextCSpr:	ex DE,HL; adresa struktury spritu +2 do HL
		jp NextCSpr14	; prejdi na dalsi sprite

;------------------------------------------------------------------------------
; Zasiahnutie Cyclop, Disk, Eye, Frog strelou.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Cyclop (02h), Disk (12h), Eye (03h), Disk (13h), Frog (04h), Frog (14h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Shot (01h), LasShot (11h)
EnemyShot:	ex DE,HL; adresa struktury spritu +2 do HL
		dec hl		; (1)
		dec hl		; (0)
		ld (HL),0FEh		; deaktivuj Strelu
		ld e,80h
		ld A,(bc)		; (8)
		or e		; nastav flag - vybuch
		ld (bc),A
		dec bc		; (7)
		dec bc		; (6)
		dec bc		; (5)
		ld a,e		; nastav sprite Blast
EnemyShotX:	ld (bc),A
		ld b,25		; zvys Score o 250 bodov
		call IncScore
		ld e,1<<3		; naplanuj zvuk
		jp ProcSprG	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Vorton narazil na pohybliveho nepriatela.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vortona (00h), Auto-Vortona (10h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Cyclop (02h), Disk (12h), Eye (03h), Disk (13h), Frog (04h),
;       - Frog (14h), Star (05h), Cyclop (15h), Flame (06h), Rough (16h)
VortBlast:	ex DE,HL; adresa struktury spritu +2 do HL
		ld a,6		; +6
		add A,l
		ld l,a		; (8) - rychlost
		ld a,(HL)		; rychlost do A
		or a		; uz je tento sprite v procese vybuchu?
		jp M,NextCSpr8	; ano, skoc spracovat dalsi "kolizny" sprite
		dec l		; (7)
		dec l		; (6) - kod spritu
		ld d,(HL)		; kod spritu do D
		ld a,-6		; -6
		add A,l
		ld l,a		; (0)
		ld a,d		; kod spritu
		cp 16h		; je to Rough?
		jp Z,VortHit		; ano, skoc osetrit naraz
		cp 06h		; je to Flame?
		jp Z,VortBlastB	; ano, preskoc deaktivovanie spritu
		cp 05h		; je to Star?
		jp Z,VortBlastB	; ano, preskoc deaktivovanie spritu
		ld (HL),0FEh		; deaktivuj sprite, ktory znicil Vortona
	if CheatLife
VortBlastB:	jp NextCSpr16
	else
VortBlastB:	ld e,80h
		ld A,(bc)
		or e		; nastav flag - vybuch
		ld (bc),A
		dec bc		; (7)
		dec bc		; (6)
		dec bc		; (5)
		ld a,e
		ld (bc),A		; nastav sprite Blast
		ld e,1<<6		; naplanuj zvuk vybuchu
		jp ProcSprG	; skoc spracovat dalsi "hlavny" sprite
	endif

;------------------------------------------------------------------------------
; Zasiahnutie Cyclop, Disk, Eye, Frog strelou.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Cyclop (02h), Disk (12h), Eye (03h), Disk (13h), Frog (04h), Frog (14h)
ShotEnemy:	ex DE,HL; adresa struktury spritu +2 do HL
		ld a,6		; +6
		add A,l
		ld l,a		; (8) - rychlost
		ld a,(HL)		; rychlost do A
		or a		; uz je tento sprite v procese vybuchu?
		jp M,NextCSpr8	; ano, skoc spracovat dalsi "kolizny" sprite
		ld de,0FE80h
		or e		; nastav flag - vybuch
		ld (HL),a
		dec l		; (7)
		dec l		; (6)
		dec l		; (5)
		ld (HL),e		; nastav sprite Blast
		ld a,-8
		add A,c
		ld c,a
		ld a,d
		jp EnemyShotX	; deaktivuj sprite Strely, naplanuj zvuk
					; a prejdi na dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Prechod na dalsiu strukturu "kolizneho" spritu.
; I: HL=adresa +8 struktury spritu
NextCSpr8:	ld de,8; offset +8
		add HL,de
		jp NextCSpr0	; prejdi na dalsi sprite

;------------------------------------------------------------------------------
; Rozbijanie BrickB (08h) a BrickA (18h) strelou.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - BrickB (08h) a BrickA (18h)
ShotBrick:	ex DE,HL; adresa struktury spritu +2 do HL
		ld a,6		; +6
		add A,l
		ld l,a		; (8) - rychlost
		ld a,(HL)		; rychlost do A
		or a		; uz je tento sprite v procese vybuchu?
		jp M,NextCSpr8	; ano, skoc spracovat dalsi "kolizny" sprite
		ld a,-8
		add A,c
		ld c,a		; (0)
		ld a,0FEh		; deaktivuj sprite Strely
		ld (bc),A
		dec l		; (7)
		dec l		; (6) - kod spritu
		ld bc,8060h		; offset konca sekvencie BrickB
		ld a,(HL)
		and 10h		; je to BrickB ?
		jp Z,ShotBrickB	; ano, skoc
		ld c,0EEh		; offset konca sekvencie BrickA
ShotBrickB:	dec l; (5) - sekvencia spritu
		ld a,(HL)		; posun sa na dalsiu sekvenciu spritu
		add A,2
		ld (HL),a
		cp c		; uz boli vsetky sekvencie?
		jp C,ShotBrickX	; nie, skoc dalej
		ld (HL),b		; inak, nastav sprite Blast
		inc l		; (6)
		inc l		; (7)
		inc l		; (8)
		ld (HL),b		; nastav flag - vybuch
ShotBrickX:	ld e,1<<7; naplanuj zvuk
		jp ProcSprG	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Движущийся враг врезался в Вортона.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Cyclop (02h), Disk (12h), Eye (03h), Disk (13h)
;       - Frog (04h), Frog (14h), Star (05h), Cyclop (15h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Vortona (00h), Auto-Vortona (10h)
EnemyBlast:	dec bc; (7)
		dec bc		; (6)
		ld A,(bc)		; kod spritu
		cp 5		; je to Star?
		jp Z,EnemyBlastD	; ano, preskoc deaktivovanie spritu
		ld a,-6
		add A,c
		ld c,a		; (0)
		ld a,0FEh
		ld (bc),A		; deaktivuj sprite
EnemyBlastD:	ex DE,HL; adresa struktury Vortona +2 do HL
		ld e,80h
		inc l		; (3)
		inc l		; (4)
		inc l		; (5) - sekvencia spritu
		ld a,(HL)		; do A
		cp e		; prebieha uz vybuch?
	if ~~CheatLife
		jp C,EnemyBlastB	; nie, skoc dalej
	endif
		dec l		; (4)
		dec l		; (3)
		dec l		; (2)
		jp NextCSpr14	; prejdi na dalsi sprite

EnemyBlastB:	ld (HL),e; nastav sprite Blast
		inc l		; (6)
		inc l		; (7)
		inc l		; (8) - rychlost
		ld (HL),e		; nastav flag - vybuch
		ld e,1<<6		; naplanuj zvuk
		jp ProcSprG	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Strela, ktora je na zaciatku letu este v kolizii s Vortonom (00h) sa necha
; letiet dalej.
; Strela, ktora zasiahne Star (05h), Cyclop (15h) sa iba deaktivuje.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Vortona (00h), Auto-Vortona (10h), Star (05h), Cyclop (15h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Shot (01h), LasShot (11h)
ShotFlyOffV:	ex DE,HL; adresa +2 druheho spritu do HL
		inc bc		; (9)
		inc bc		; (10)
		ld A,(bc)		; offset na Seq
		cp 0Eh		; je to Vorton? - po vystrele je strela
		jp Z,NextCSpr14	;  este v kolizii s Vortonom
		dec l		; (1)
		dec l		; (0)
		ld (HL),0FEh		; deaktivuj Strelu
		jp NextCSpr16	; prejdi na dalsi sprite

;------------------------------------------------------------------------------
; Strela, ktora je na zaciatku letu este v kolizii s Vortonom (00h) sa necha
; letiet dalej.
; Strela, ktora zasiahne Star (05h), Cyclop (15h) sa iba deaktivuje.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Shot (01h), LasShot (11h)
;    DE=adresa +2 struktury "kolizneho" spritu
;       - Vortona (00h), Auto-Vortona (10h), Star (05h), Cyclop (15h)
ShotFlyOff:	ex DE,HL; adresa +2 druheho spritu do HL
		ld a,8		; +8
		add A,l
		ld l,a
		ld a,(HL)		; (10) - offset na Seq
		cp 0Eh		; je to Vorton? - po vystrele je strela
		jp NZ,ShotOff		;  este v kolizii s Vortonom
		ld de,6		; ano, je to Vorton
		add HL,de		; posun na dalsi sprite
		jp NextCSpr0	; skoc spracovat dalsi sprite

;------------------------------------------------------------------------------
; Deaktivovanie spritu (Strely).
; I: (SP)=adresa struktury spritu (Shot (01h), LasShot (11h))
ShotOff:	pop hl
		ld (HL),0FEh		; deaktivuj sprite
		jp NextMSpr	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Nahodna zmena smeru po narazeni do ineho spritu,
; ale vzdy iba "v pravom uhle" - V, J, Z, S
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Cyclop (02h), Disk (12h)
ChDir2:		call Rand; nahodna hodnota do A
		and 6		; odmaskuj iba potrebny rozsah
		dec bc		; (7) - smer spritu
		ld (bc),A		; a uloz ako novu hodnotu smeru
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Nahodna zmena smeru po narazeni do ineho spritu - do vsetkych smerov.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Eye (03h), Disk (13h)
ChDir3:		call Rand; nahodna hodnota do A
		and 7		; odmaskuj iba potrebny rozsah
		dec bc		; (7) - smer spritu
		ld (bc),A		; a uloz ako novu hodnotu smeru
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Случайное изменение направления после столкновения с другим объектом.
; I: BC=adresa +8 struktury "hlavneho" spritu
;       - Frog (04h), Frog (14h)
ChDir4:		ld e,c; presun adresu do DE
		ld d,b
;ChDir4Y:	mvi	a,0		; Y po kolizii
;		cpi	49h		; ak by bola po posune Y suradnica
;		jnc	ChDir4D		; mimo rozsah <0, 48h>, skoc dalej
		ld a,4
		add A,e
		ld e,a		; (12) - init hodnota smeru
		call Rand		; nahodna hodnota do A
		and 7		; odmaskuj iba potrebny rozsah
		ld (de),A		; a uloz ako init hodnotu smeru
		jp ProcSprNoCollD	; pokracuj zmenou smeru spritu Frog

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
ChDir5:		dec bc; (7) - smer spritu
		ld A,(bc)		; vezmi aktualny smer
		add A,4		; zmen na opacny
		and 7		; odmaskuj iba potrebny rozsah
		ld (bc),A		; a uloz novu hodnotu smeru
		jp NextMSprP	; skoc spracovat dalsi "hlavny" sprite

;------------------------------------------------------------------------------
; Обработка движения Lasertron.
LTronMove:	ld hl,SprStructLT+8; adresa rychlosti Lasertronu
		ld a,(HL)
		and a		; je nulova?
		jp Z,LTronMoveE	; ano, skoc dalej
		ld hl,SprStructLT+2	; adresa pozicie LT
		ld b,(HL)		; pozicia LT do BC
		dec l		; (1)
		ld c,(HL)
		dec l		; (0)
		ld de,-16		; offset na predchadzajuceho Auto-Vortona
		ld a,4		; 4 Auto-Vortoni
		jp LTronMoveB

LTronMoveA:	ld a,4; pocitadlo AV vrat do A
		dec a		; zniz pocitadlo
		jp Z,LTronMoveC	; ak uz nie je aktivny ziadny AV, skoc
LTronMoveB:	ld (LTronMoveA+1),A; odpamataj pocitadlo AV
		add HL,de		; posun sa na strukturu AV
		ld a,(HL)		; (0) - Y pozicia AV
		cp 0FEh		; je aktivny tento AV?
		jp NC,LTronMoveA	; nie, skoc skusit dalsieho
		ld a,6		; posun sa na kod spritu
		add A,l
		ld l,a
		ld a,(HL)		; (6) - kod spritu
		and a		; je to uz Hlavny Vorton ?
		jp Z,LTronMoveC	; ano, skoc dalej
		ld a,-4
		add A,l
		ld l,a		; (2)
		ld d,(HL)		; - XH
		dec l		; (1)
		ld e,(HL)		; - XL
		call SubDEBC		; porovnaj vdialenost medzi AV a LT
					; rozdiel vzdialenosti moze byt max 10h
		inc a		; ak je vacsi,
		jp NZ,LTronMoveC	;  skoc skusit Hlavneho Vortona
		ld a,e
		cp 0F0h		; ak je v rozsahu,
		jp NC,LTronMoveF	;  skoc spracovat posun LT

		; test, ci je Hlavny Vorton pred Lasertronom
LTronMoveC:	ld HL,(VortonStruct); adresa struktury aktualneho Vortona do HL
		ld a,(HL)		; aby mohol Vorton tlacit LT, Y pozicia
		cp 2Ch		;  musi byt v intervale <1Dh, 2Bh>
		jp NC,LTronMoveD	; ak nie je, skoc dalej
		cp 1Dh
		jp C,LTronMoveD
		inc l		; (1)
		ld e,(HL)
		inc l		; (2)
		ld d,(HL)		; X pozicia Vortona do DE
		call SubDEBC		; porovnaj vdialenost medzi Vortonom a LT
					; rozdiel vzdialenosti moze byt max 10h
		inc a		; ak je vacsi,
		jp NZ,LTronMoveD	;  skoc zastavit LT
		ld a,e
		cp 0F0h		; ak je v rozsahu,
		jp NC,LTronMoveF	;  skoc spracovat posun LT

LTronMoveD:	xor a; attr. pre "zhasnutie" sipky nad LT na panely
		ld (SprStructLT+8),A	; zastav LT - vynuluj jeho Rychlost
LTronMoveE:	ld h,a
		ld l,a
LTronMoveG:	ld de, (24<<8)|16
		ld a,h
		call Print88
		ld a,l
		jp Print88

LTronMoveF:	ld A,(LTronStep); pocitadlo krokov LT
		inc a		; inkrement
		and 7		; uprav na rozsah <0, 7>
		ld (LTronStep),A	; uloz novu hodnotu
		jp Z,LTronMoveE	; ak je nulova, skoc zhasnut sipku
		cp 4		; ak ma polovicnu hodnotu,
		ret NZ
		ld b,1		; zvys Score o 10 bodov
		call IncScore
		ld hl, (27<<8)|28
		jp LTronMoveG	; skoc zobrazit sipku

;------------------------------------------------------------------------------
IncPower:	push de; odpamataj pouzivane registre
		push bc
		push af
		ld A,(PowerIndik)	; stlpec posledneho dielika POWER
		inc a		; inkrementuj
		ld (PowerIndik),A	; a uloz novu hodnotu
		ld e,a		; stlpec
		ld d,24		; a riadok pre POWER
		add A,2		; kod znaku pre konkretny znak POWER
		call Print88		; zobraz znak
		pop af		; obnov registre
		pop bc
		pop de
		ret

;------------------------------------------------------------------------------
IncScore:	ld hl,Score+5; adresa Score - desiatky
		ld de,10		; D=0, E=10
IncScoreA:	ld a,(HL); vezmi cislicu
		cp e		; je to medzera?
		jp NZ,IncScoreB	; nie, skoc dalej
		xor a		; z medzery bude cislica 0
IncScoreB:	inc a; inkrementuj cislicu
		cp e		; naplnil sa tento rad?
		jp NZ,IncScoreC	; nie, skoc dalej
		ld (HL),d		; ano, nastav ho na nulu
		dec hl		; presun sa na dalsi rad (cislicu)
		jp IncScoreA

IncScoreC:	ld (HL),a; uloz novu hodnotu
		dec b
		jp NZ,IncScore	; opakuj pre celu vysku inkrementu

		jp PrtScore	; zobraz novu hodnotu

;------------------------------------------------------------------------------
InitSpdLvl:	ld A,(SpeedLevel); uroven rychlosti
		or a		; ak je 0
		ret Z			; nerob nic
		dec a		; inak zniz o 1 uroven
		ld (SpeedLevel),A	; a uloz
		ld hl,SprList+6	; adresa zoznamu spritov
		ld de,16		; offset na dalsiu strukturu
InitSpdLvlA:	ld a,(HL); (6) - kod spritu
		and 0Fh		; ponechaj zakladny kod
		cp 5		; vybranym pohyblivym spritom
		jp NC,InitSpdLvlB
		inc hl		; (7)
		inc hl		; (8)
		dec (HL)		; zniz bazovu rychlost
		dec hl		; (7)
		dec hl		; (6)
InitSpdLvlB:	add HL,de
		ld a,h		; az po Vortonov a spol
		cp SprListVL/256
		jp C,InitSpdLvlA
		jp InitSpdLvl	; opakuj, kym nebude SpeedLevel 0

;------------------------------------------------------------------------------
CheckScore:	ld hl,HiScore; porovnaj Score a HiScore
		ld de,Score
		ld b,7		; 7 cislic
CheckScoreA:	ld A,(de); cislica Score
		cp (HL)		; porovnaj s HiScore
		jp Z,CheckScoreB	; su rovnake, prejdi na dalsiu cislicu
		jp NC,CheckScoreC	; cislica Score > HiScore, skoc
		ld a,(HL)		; cislica HiScore > Score
		cp 10		; ak je cislica HiScore medzera,
		jp Z,CheckScoreD	;  Score > HiScore, skoc
CheckScoreB:	inc hl; dalsia cislica
		inc de
		dec b
		jp NZ,CheckScoreA
		jp PrtHiScore

CheckScoreC:	cp 10; ak je cislica Score medzera,
		jp Z,PrtHiScore	;  HiScore > Score, skoc
CheckScoreD:	ld hl,Score; Score > HiScore
		ld de,HiScore	;  skopiruj Score do HiScore
		ld b,7		; 7 cislic
		call Copy8
		jp PrtHiScore

;------------------------------------------------------------------------------
