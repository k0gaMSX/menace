%include "tniasm.inc"
%include "z80r800.inc"
%include "z80().inc"
%include "msx.inc"



        fname   "menace.rom"



orgcode 4000h
orgrdata 0E000h

pagsize equ	32*1024	
p1size  equ     p1end-p1load
p1padd  equ     pagsize-p1size
p1sizeT equ     p1endf-p1load

	
section code

p1load:	equ	$
	db      'AB'
        dw      main
        dw      0,0,0,0,0,0,0,0

	


main:	call	SaveSlotC
	call	RomSlotPage2
	call	InitScore
	
game:
	call	showLogo
	call	initIntro
	call	InitLevel
nextl:	call	PlayLevel
	call	c,showEnding
	jr	nextl


	
showEnding:
	pop	hl
	ld	hl,game
	push	hl
	
	ret



	
section	code			

	

%include "sys.asm"
%include "tnimsx1.asm"	
%include "intro.asm"
%include "levels.asm"
%include "pj.asm"
%include "score.asm"

		
scrpat:	
%incbin  "patterns.pat"
scrcol:		
%incbin  "patterns.col"
sprdata:		
%incbin  "sprites.spr"
floorpat:
%incbin  "floor.flr"
floorcol:	
%incbin  "floor.col"
enemybin:		
%incbin  "enemy.ene"
enemycol:		
%incbin  "enemy.col"				
	
		
p1end:  ds      p1padd,0
p1endf: equ $
	
%if p1size > pagsize
   %warn "Page 0 boundary broken"
%endif
		
