

	
	
InitLevel:
		call	BeginScore
		call	DISSCR
		ld	a,3
		ld	(NumLives),a
		ld	a,0
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
	
	

	
	
		
PlayLevel:	ld	a,(NumLevel)
		inc	a
		cp	11
		jr	nz,.2
		scf
		ret

		
.2: 		
		ld	(NumLevel),a				
		call	CleanScr
		call	.showLevel
		call	.CleanMap	
		call	.initMap
		call    InitEnemy
		call	initPJ
		call	PrintScore	
		ld	a,0c3h
		ld	hl,LevelISR
		ld	(0fd9ah),a
		ld	(0fd9bh),hl

.1:		ei
		halt
		call	doPj
		call	doEnemy
		ld	a,7
		call	SNSMAT
		bit	2,a
		jr	nz,.1
		ld	a,0c9h
		ld	(0fd9ah),a
		ret




	

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

	
		
	




	
	
LevelISR:	ld	hl,time
		inc	(hl)

		call	.changefloor
		ld	de,1b00h
		call	SetPtr_VRAM
		ld	hl,spratt
		ld	b,4*32
		ld	c,98h
		otir	
	
		ld	de,1000h+120*8
		call	SetPtr_VRAM
		ld	hl,basegfx
		ld	b,5*8
		ld	c,98h
		otir

		ld	de,1800h
		call	SetPtr_VRAM
		ld	hl,PatternMap
		ld	b,3
.isrloop:	push	bc
		ld	b,0
		otir
		pop	bc
		djnz	.isrloop

	
		ld	de,0+96*8
		call	SetPtr_VRAM
		ld	hl,bufferEnUp1
		ld	b,8*6*2
		ld	c,98h
		otir

		ld	de,0+102*8
		call	SetPtr_VRAM
		ld	hl,bufferEnUp2
		ld	b,8*6*2
		ld	c,98h
		otir	
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
		ld	b,2*8
		ld	c,98h
		otir

	
		ld	de,1000h+62*8
		call	SetPtr_VRAM
		ld	b,4*8
		ld	c,98h
		otir		; WE MUST CHANGE destroyed floor!!!
	
		
		pop	de
		ld	hl,floorcol
		add	hl,de
		ld	de,3000h+30*8
		call	SetPtr_VRAM
		ld	b,2*8
		ld	c,98h
		otir

	
		ld	de,3000h+62*8
		call	SetPtr_VRAM
		ld	b,4*8
		ld	c,98h
		otir		; TODO: WE MUST CHANGE color of destroyed floor!!!
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
	
		
	
section rdata		

time:		rb	1	
NumLevel:	rb	1
NumLives:	rb	1
PatternMap:	rb	32*24
spratt:		rb	4*32	



	
section code	
