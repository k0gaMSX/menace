

	
	
InitLevel:
		call	BeginScore
		call	DISSCR
		ld	a,3
		ld	(NumLives),a
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
		ld	bc,512
		ld	hl,sprdata
		ld	de,3800h
		call	LDIRVM
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
		ld	bc,800h
		push	de
		push	af
		call    LDIRVM
		pop	af
		pop	hl
		ld	de,800h
		add	hl,de
		ex	de,hl
		dec	a
		jr	nz,.cppat

		ld	hl,scrpat+121*8
		ld	bc,3*8
		ld	de,1000h+160*8
		call	LDIRVM
		ret	


	
.initcol:		
		ld	a,3
		ld	de,2000h
.cpcol:		ld	hl,scrcol
		ld	bc,800h
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

 		ld	a,7
 		call	SNSMAT
 		bit	2,a
 		jr	z,.endLevel
	
	
		jr	.noend
	
.endLevel:
		ld	hl,NumLevel
		inc	(hl)	
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
		ld	a,(NumLevel)
		cp	11
		jr	nz,.BeginPlay
		xor	a
		ret

		
.BeginPLay: 		
		call	CleanScr
		call	.showLevel
		call	.CleanMap	
		call	.initMap
		call	VisOff	
		call    InitEnemy
		call	InitMeteors
		call	initPJ
		call	PrintScore
		call	InsIsrLevel
	
		
.GameLoop:
		ld	a,4
		call	set_cfondo
		ei
		halt
		call	doPj
		call	doEnemy
		call	doMeteors
		call	VisOn
		call	TestDeath
		jr	nz,.death
		call	TestEnd
		jr	z,.GameLoop		


.endGame:	
		push	af
		call	DelIsrLevel
		pop	af
		ret

.death:
 		call	TestEnd
  		jr	z,.GameLoop
 		jr	.endGame


	

	
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
		ld	b,a
		ld	hl,PatternMap+23*32
.initMapLoopE1:	push	bc
		ld	a,160
		ld	b,3
.initMapLoop4:	ld	(hl),a
		inc	a
		inc	hl
		djnz	.initMapLoop4
		pop	bc
		djnz	.initMapLoopE1
	
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
		ld	a,5
		call	set_cfondo
		ld	hl,time
		inc	(hl)

		ld	de,1b00h
		call	SetPtr_VRAM
		ld	hl,spratt
		ld	c,98h
		call    tovram16x8
	
		ld	de,0+96*8
		call	SetPtr_VRAM
                ld	hl,(bufferPtrUp1)
		ld	c,98h
		call    tovram12x8

		ld	de,0+102*8
		call	SetPtr_VRAM
	        ld	hl,(bufferPtrUp2)	
		ld	c,98h
		call    tovram12x8

		ld	de,0+108*8
		call	SetPtr_VRAM
		ld	hl,(bufferPtrDw1)
		ld	c,98h
		call    tovram12x8

		ld	de,0+114*8
		call	SetPtr_VRAM
		ld	hl,(bufferPtrDw2)
		ld	c,98h
		call    tovram12x8
	
  		ld	de,1800h+3*32
		call	SetPtr_VRAM
		ld	hl,PatternMap+3*32
		call	tovram8x8
  		ld	de,1800h+6*32
		call	SetPtr_VRAM
		ld	hl,PatternMap+6*32
 		call	tovram8x8
		


.meteorMap:	ld	de,1800h+4*32+20*8
		call	SetPtr_VRAM
		ld	hl,PatternMap+9*32
 		call	tovram16x8

		ld	a,2
		call	set_cfondo

  		ld	de,1800h+20*32
		call	SetPtr_VRAM
		ld	hl,PatternMap+20*32
		call	tovram4x8

		ld	de,800h+METEOR_VOFF1
		call	SetPtr_VRAM
		ld	hl,MeteorBufferR
		ld	c,98h	
		call	tovram3x8_slow

		ld	de,800h+METEOR_VOFF2
		call	SetPtr_VRAM
		ld	hl,MeteorBufferL
		ld	c,98h	
		call	tovram3x8_slow

		ld	de,1000h+120*8
		call	SetPtr_VRAM
		ld	hl,basegfx
		ld 	c,98h	
		call  	tovram5x8_slow	
 		call	.changefloor
	
		ld	a,1
		call	set_cfondo
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
	
; WE MUST CHANGE destroyed floor!!!
	
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
		ret        ; TODO: WE MUST CHANGE color of destroyed floor!!!





tovram5x8_slow:
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	
tovram4x8_slow:
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
tovram3x8_slow:	
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
tovram2x8_slow:	
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
tovram1x8_slow:		
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	nop
	outi
	ret

	


;TODO: Change tovramXxX routines to auto generated RAM routine for this	
	

tovram16x8:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	

	
tovram15x8:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	
	
tovram14x8:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	

tovram13x8:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	
		
tovram12x8:	
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi

tovram11x8:		
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi

	
tovram10x8:	
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi

tovram9x8:		
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	

tovram8x8:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	

tovram7x8:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	
	
tovram6x8:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	

tovram5x8:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi	
		
tovram4x8:	
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi

tovram3x8:		
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi

	
tovram2x8:	
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi

tovram1x8:		
	outi
	outi
	outi
	outi
	outi
	outi
	outi
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

DeathF:		rb	1
time:		rb	1	
NumLevel:	rb	1
NumLives:	rb	1
PatternMap:	rb	32*24
spratt:		rb	4*32	



	
section code	
