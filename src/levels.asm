WAIT_TIME:	equ	120



InitLevel:
		call	BeginScore
		call	DISSCR
		ld	a,1
		ld	(NumLevel),a

		ld	bc,$4000
		ld	hl,0
		call	FILVRM
		call	.initpat
		call	.initcol

		call	.initsp
		call	ENASCR
		ret

.initsp:	ld	bc,800h
		xor	a
		ld	hl,3800h
		call	FILVRM
		ld	hl,sprdata
		ld	de,3800h
		call	UnTCFV
		ld	bc,8
		ld	a,0ffh
		ld	hl,3800h+250*8
		call	FILVRM
		ld	a,254
		ld	hl,spratt
		ld	de,spratt+1
		ld	bc,32*4-1
		ld	(hl),a
		ldir
		call	set_spd8
		ret


.initpat:
		ld	a,3
		ld	de,0
.cppat:		ld	hl,scrpat
		;ld	bc,800h
		push	de
		push	af
		call    UnTCFV
		pop	af
		pop	hl
		ld	de,800h
		add	hl,de
		ex	de,hl
		dec	a
		jr	nz,.cppat

		ld	hl,120*8
		ld	bc,6*8
		ld	de,basegfxt
		call	LDIRMV


		ld	hl,basegfxt+8
		ld	bc,3*8
		ld	de,1000h+160*8
		call	LDIRVM
		ret



.initcol:
		ld	a,3
		ld	de,2000h
.cpcol:		ld	hl,scrcol
		ld	bc,sprdata-scrcol
		push	de
		push	af
		call    LDIRVM
		pop	af
		pop	hl
		ld	de,800h
		add	hl,de
		ex	de,hl
		dec	a
		jr	nz,.cpcol

		ld	hl,scrcol+121*8
		ld	bc,3*8
		ld	de,3000h+160*8
		call	LDIRVM
		ret


TestDeath:
		ld	a,(DeathF)
		or	a
		ret





InsIsrLevel:
		di
		xor	a
		ld	(DeathF),a
		ld	a,0c3h
		ld	hl,LevelISR
		ld	(0fd9ah),a
		ld	(0fd9bh),hl
		ei
		ret



DelIsrLevel:	di
		ld	a,0c9h
		ld	(0fd9ah),a
		ei
		ret






TestEnd:
		call	TestBoom
		jr	nz,.noend


		ld	a,(NumEnemy)
		or	a
		jr	z,.endLevel


		ld	a,(NumLives)
		or	a
		jr	z,.newgame


		ld	a,(DeathF)
		or	a
		jr	nz,.death

%if ESCAPE
 		ld	a,7
 		call	SNSMAT
 		bit	2,a
 		jr	z,.endLevel
%endif

		jr	.noend

.endLevel:
		ld	a,(METEOR_PROB)
		add	a,METEOR_DINC
		cp	METEOR_DMAX
		jr	c,.endLevel.prob
		ld	a,METEOR_DMAX
.endLevel.prob:
		ld	(METEOR_PROB),a
		ld	a,1
		or	a
		ret

.newgame:	ld	a,2
		or	a
		ret


.noend:		xor	a
		ret

.death:		ld	a,3
		or	a
		ret


;;; ************************************************


PlayLevel:
		cp	1
		ld	hl,NumLevel
		ld	a,(hl)
		jr	nz,.nonewlevel
		inc	a
		ld	(hl),a
.nonewlevel:	cp	11
		jr	nz,.BeginPlay
		xor	a
		ret


.BeginPlay:
		call	initsound
		ld	a,(NumLives)
		or	a
		jr	z,TestEnd.newgame

		ld	a,WAIT_TIME
		ld	(waitgame),a
		call	CleanScr
		call	.showLevel
		call	.CleanMap
		call	.initMap
		call	VisOff
		call    InitEnemy
		call	renderFire
		call	InitMeteors
		call	initPJ
		call	PrintScore
		call	InsIsrLevel


.GameLoop:
%if DEBUG
		ld	a,4
 		call	set_cfondo
%endif
		ei
 		halt
                xor     a
                ld      (vblankf),a
		call	doPj
		call	doEnemy
		call	doMeteors
		call	VisOn
		call	TestDeath
		jr	nz,.death
                ld      a,1
                ld      (vblankf),a
		call	TestEnd
		jr	z,.GameLoop


.endGame:
        	push	af
                call	.WaitTime
	        ld	a,208
	        ld	hl,$1b00
	        call	WRTVRM
		call	DelIsrLevel
		pop	af
		ret

.death:
                ld      a,1
                ld      (vblankf),a
		ld	hl,waitgame
		dec	(hl)
		jr	nz,.GameLoop
 		call	TestEnd
  		jr	z,.GameLoop
 		jr	.endGame




.WaitTime:
		ld	b,50
.1:		ei
		halt
                ld      a,1
                ld      (vblankf),a
		push	bc
                ld      a,1
                ld      (vblankf),a
		call	renderPJ
		pop	bc
		djnz	.1
		ret




;;; ****************************************************


.initMap:
		ld	hl,PatternMap+21*32

		ld	b,2
		ld	a,30
.initMapLoopE:	push	bc
		ld	b,16
.initMapLoop:	push	af
		ld	(hl),a
		inc	hl
		inc	a
		ld	(hl),a
		inc	hl
		pop	af
		djnz	.initMapLoop
		pop	bc
		ld	a,62
		djnz	.initMapLoopE

		ld	a,138
		ld	hl,PatternMap
		ld	b,8
.initMapLoop2:	ld	(hl),a
		inc	a
		inc	hl
		djnz	.initMapLoop2
		xor	a
		ld	(hl),a
		inc	hl
		ld	(hl),a
		inc	hl
		ld	(hl),a

		ld	hl,PatternMap+13 ;Paint Score
		ld	a,141
		ld	b,5
.initMapLoop21:	ld	(hl),a
		inc	hl
		inc	a
		djnz	.initMapLoop21



		ld	hl,PatternMap+759 ;Paint TNI CopyRight
		ld	a,146
		ld	b,8
.initMapLoop3:	ld	(hl),a
		inc	hl
		inc	a
		djnz	.initMapLoop3


		ld	a,(NumLives)
		or	a
		jr	z,.noPJs
		ld	b,a
		cp	6
		jr	c,.initMapLoopGo
		ld	b,5
.initMapLoopGo:	ld	hl,PatternMap+23*32
.initMapLoopE1:	push	bc
		ld	a,160
		ld	b,3
.initMapLoop4:	ld	(hl),a
		inc	a
		inc	hl
		djnz	.initMapLoop4
		pop	bc
		djnz	.initMapLoopE1
.noPJs:
		ld	hl,PatternMap
		ld	de,1800h
		ld	bc,32*24
		call	LDIRVM
		ret





.CleanMap:
		ld	bc,32*24-1
		xor	a
		ld	hl,PatternMap
		ld	de,PatternMap+1
		ld	(hl),a
		ldir
		ret




.showLevel:	ld	d,8
		ld	e,8
		xor	a
		call	.PrintDigit
		ld	a,2
		call	.PrintDigit
		ld	a,4
		call	.PrintDigit
		ld	a,6
		call	.PrintDigit
		ld	a,8
		call	.PrintDigit
		inc	de
		inc	de
		ld	a,(NumLevel)
		cp	10
		jr	nz,.showl1

		ld	a,12
		call	.PrintDigit
		ld	a,10
		call	.PrintDigit
		jr	.showl2


.showl1:	add	a,a
		add	a,10
		call	.PrintDigit
.showl2:
		ld	b,2*60
.showLevelloop:	ei
		halt
		djnz	.showLevelloop

		ret





.PrintDigit:	push	de
		ld	l,d
		ld	h,0
		ld	d,h
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,de
		ld	de,1800h
		add	hl,de
		ld	b,3
		ld	de,31


.PrintDigitloop:
		push	af
		call	WRTVRM
		pop	af
		inc	a
		push	af
		inc	hl
		call	WRTVRM
		pop	af
		add	a,e
		add	hl,de
		djnz	.PrintDigitloop
		pop	de
		inc	de
		inc	de
		ret










LevelISR:
                call	SoundISR
                ld      hl,vblankf
                xor     a
                or      (hl)
                ret     z

                ld      (hl),0
%if DEBUG
		ld	a,5
 		call	set_cfondo
%endif
		ld	hl,time
		inc	(hl)

		ld	c,98h
		ld	de,1b00h
		call	SetPtr_VRAM
		ld	hl,spratt
		call    R_outi + 480 - 8 * 32

		ld	de,0+96*8
		call	SetPtr_VRAM
                ld	hl,(bufferPtrUp1)
		call    R_outi + 480 - 2 * 48

		ld	de,0+102*8
		call	SetPtr_VRAM
	        ld	hl,(bufferPtrUp2)
		call    R_outi + 480 - 2 * 48

		ld	de,0+108*8
		call	SetPtr_VRAM
		ld	hl,(bufferPtrDw1)
		call    R_outi + 480 - 2 * 48

		ld	de,0+114*8
		call	SetPtr_VRAM
		ld	hl,(bufferPtrDw2)
		call    R_outi + 480 - 2 * 48

  		ld	de,1800h+3*32
		call	SetPtr_VRAM
		ld	hl,PatternMap+3*32
		call    R_outi + 480 - 2 * 64
  		ld	de,1800h+6*32
		call	SetPtr_VRAM
		ld	hl,PatternMap+6*32
 		call    R_outi + 480 - 2 * 64



.meteorMap:	ld	de,1800h+4*32+20*8
		call	SetPtr_VRAM
		ld	hl,PatternMap+9*32
 		call    R_outi + 480 - 2 * 32

		ld	de,1800h+6*32+20*8
		call	SetPtr_VRAM
		ld	hl,PatternMap+11*32
 		call    R_outi + 480 - 2 * 32

		ld	de,1800h+8*32+20*8
		call	SetPtr_VRAM
		ld	hl,PatternMap+13*32
 		call    R_outi + 480 - 2 * 32

		ld	de,1800h+10*32+20*8
		call	SetPtr_VRAM
		ld	hl,PatternMap+15*32
 		call    R_outi + 480 - 2 * 32

  		ld	de,1800h+20*32			;base
		call	SetPtr_VRAM
		ld	hl,PatternMap+20*32
		call    R_outi + 480 - 2 * 32

		ld	de,800h+METEOR_VOFF1
		call	SetPtr_VRAM
		ld	hl,MeteorBufferR
		call    R_outi + 480 - 2 * 24

		ld	de,800h+METEOR_VOFF2
		call	SetPtr_VRAM
		ld	hl,MeteorBufferL
		call    R_outi + 480 - 2 * 24

		call	.colours

%if DEBUG
 		ld	a,12
  		call	set_cfondo
%endif
		ld	de,1000h+METEOR_VOFF2
		call	SetPtr_VRAM
		ld	hl,MeteorBufferL
		call    tovram3x8_slow

		ld	de,1800h+13*32+20*8
		call	SetPtr_VRAM
		ld	hl,PatternMap+18*32
 		call    tovram4x8_slow

		ld	de,1000h+120*8
		call	SetPtr_VRAM
		ld	hl,basegfx
		call    tovram5x8_slow

 		call	.changefloor
%if DEBUG
		ld	a,10
  		call	set_cfondo
%endif

%if DEBUG
 		ld	a,1
  		call	set_cfondo
%endif
		ret



.colours:

		ld	de,2000h+ENEMYVOFF
		call	SetPtr_VRAM
		ld	hl,(BuffColorPtr1)
		call    R_outi + 480 - 2 * 8
		ld	hl,(BuffColorPtr1)
		call    R_outi + 480 - 2 * 8
		ld	hl,(BuffColorPtr1)
		call    R_outi + 480 - 2 * 8
		ld	hl,(BuffColorPtr1)
		ld	de,8
		add	hl,de
		call    R_outi + 480 - 2 * 8
		ld	hl,(BuffColorPtr1)
		ld	de,8
		add	hl,de
		call    R_outi + 480 - 2 * 8
%if DEBUG
		ld	a,2
 		call	set_cfondo
%endif
		ld	hl,(BuffColorPtr1)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow


		ld	hl,(BuffColorPtr2)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow


		ld	hl,(BuffColorPtr1)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr1)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr1)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr1)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr1)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr1)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow


		ld	hl,(BuffColorPtr2)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow
		ld	hl,(BuffColorPtr2)
		ld	de,8
		add	hl,de
		call    tovram1x8_slow

		ret





.changefloor:
		ld	a,(NumLevel)
		dec	a
		and	0feh
		add	a,a
		add	a,a
		ld	e,a
		ld	l,a
		ld	d,0
		ld	h,0
		add	hl,de
		add	hl,de
		add	hl,de
		add	hl,de
		add	hl,hl
		ld	a,(time)
		and	1
		jp	z,.1
		ld	de,5*8
		add	hl,de

.1:		push	hl
		ld	de,floorpat
		add	hl,de
		ld	de,1000h+30*8
		call	SetPtr_VRAM
		ld	c,98h
		call	tovram2x8_slow


		ld	de,1000h+62*8
		call	SetPtr_VRAM
		ld 	c,98h
		call	tovram4x8_slow

		pop	de
		ld	hl,floorcol
		add	hl,de
		ld	de,3000h+30*8
		call	SetPtr_VRAM
		ld	c,98h
		call	tovram2x8_slow

		ld	de,3000h+62*8
		call	SetPtr_VRAM
		ld 	c,98h
		call  	tovram4x8_slow
		ret





tovram5x8_slow:
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
tovram4x8_slow:
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
tovram3x8_slow:
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
tovram2x8_slow:
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
tovram1x8_slow:
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	nop
	nop
	outi
	ret



ReadPTR_VRAM:
	di
        ld      a,e
	out	(99h),a		;VDP acess
	ld	a,d
	out	(99h),a		;VDP acess
	ret



;Nombre:  SetPtr_VRAM
;Entrada: de -> Direccion a escribir
;Modifica: af

SetPtr_VRAM:
	di
	ld	a,e
	out	(99h),a		;VDP acess
	ld	a,d
	or	40h		;'@'
	out	(99h),a		;VDP acess
	ret


;nombre: set_spd8
;objetivo: poner los sprites en 16x16


set_spd8:
	di
	ld	a,(RG1SAV)
	res	1,a
	ld	(RG1SAV),a
	out	(99h),a
	ld	a,128+1
	out	(99h),a
	ei
	ret




CleanScr:	xor	a
		ld	bc,400h
		ld	hl,1800h
		call	FILVRM
		ret


;Nombre: VisOn
;Autor: Roberto Vargas Caballero
;Objetivo: Esta Funcion Habilita La Visualizacion De La Pantalla Ademas
;          De Colocar El Tamagno De Sprites A 16x16
;Modifica: A


VisOn:	di
	ld	a,(rg1sav)
	set	6,a
	ld	(rg1sav),a
	out	(99h),a
	ld	a,128+1
	out	(99h),a
	ret




%if DEBUG
;Nombre: set_cfondo
;Objetivo: colocar un color de fondo.
;Entrada: a -> color
;Modifica: a


set_cfondo:
	di
	out	(99h),a
	ld	a,128+7
	out	(99h),a
	ret
%endif


;nombre: VisOff
;Autor: Roberto Vargas Caballero
;Objetivo: Esta Funcion Deshabilita La Visualizacion De La Pantalla
;          Ademas De Colocar El Tamagno De Los Sprites A 16x16
;Modifica: A


visoff:	di
	ld	a,(rg1sav)
	res	6,a
	ld	(rg1sav),a
	out	(99h),a
	ld	a,128+1
	out	(99h),a
	ei
	ret




section rdata

vblankf:        rb      1
waitgame:	rb	1
DeathF:		rb	1
time:		rb	1
NumLevel:	rb	1
NumLives:	rb	1
PatternMap:	rb	32*24
spratt:		rb	4*32




section code
