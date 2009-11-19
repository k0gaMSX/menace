DEBUG %set 0

%include "tniasm.inc"
%include "z80r800.inc"
%include "z80().inc"
%include "msx.inc"

%outfile "menace.rom"

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
        dw      0,0,0,0,0,0




main:	call	SaveSlotC
	call	RomSlotPage2
	call	InitScore
	;ld	a,1fh
	;out	(02eh),a

	ld	a,($2d)
	or	a
	jr	z,game

	call	setplt

	ld	a,7
	call	SNSMAT
	bit	6,a
	jr	nz,game

	ld	a,(RG9SAV)
	and	$fd
	ld	b,a
	ld	c,9
	call	WRTVDP

game:
 	call	showLogo
wasGameOver:
        call	initsound
 	call	initIntro
	call	InitLevel
nextl:	call	PlayLevel
	cp	0
	jr	z,showEnding
	cp	2
	jr	z,showGameOver
	jr	nextl


showGameOver:
	call	DISSCR
	xor	a
	ld	bc,768
	ld	hl,$1800
	call	FILVRM

	ld	de,$800+32*8	; starting from " "
	ld	hl,font.pat
	call	UnTCFV

	ld	de,$2800+32*8
	ld	hl,font.col
	call	UnTCFV

	ld	bc,64
	ld	de,$1920
	ld	hl,gameovertext
	call	LDIRVM

	call	ENASCR
	ei
	ld	b,0
.wait:	halt
	djnz	.wait

	ld	hl,wasGameOver
	push	hl
	ret



showEnding:
	ld	a,$d0
	ld	hl,$1b00
	call	WRTVRM

	ld	hl,intromode
	set	0,(hl)
	call	enddemo
	ld	hl,game
	push	hl
	ret







%include "sound.asm"
%include "sys.asm"
%include "untcfv_msx1.asm"
%include "tnimsx1.asm"
%include "intro.asm"
%include "levels.asm"
%include "pj.asm"
%include "score.asm"
%include "enemy.asm"
%include "aysfx.asm"
%include "meteors.asm"
%include "pt3.asm"
%include "splash.asm"

gameovertext:
	db	$00,$00,$00,$00,$00,$00,$00,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$00,$00,$48,$50,$51,$52,$4E,$4F,$4E,$53,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$54,$55,$56,$57,$58,$59,$5A,$5B,$00,$00,$54,$5C,$5D,$5E,$5A,$5B,$5A,$5F,$00,$00,$00,$00,$00,$00,$00

sfx:
%incbin  "../sounds/sound.afb"
scrpat:
%incbin  "patterns.pat.tcf",8
scrcol:
%incbin  "patterns.col"
sprdata:
%incbin  "sprites.spr.tcf",8
floorpat:
%incbin  "floor.flr"
floorcol:
%incbin  "floor.col"
enemybin:
%incbin  "enemy.ene"
enemycol:
%incbin  "enemy.col"
font:
.pat:
%incbin  "font.pat.tcf",8
.col:
%incbin  "font.col.tcf",8
.exclamation:
db	01110000b
db	01110000b
db	01110000b
db	01100000b
db	01100000b
db	00000000b
db	01100000b
db	01100000b

splash:
.end01.pat:
%incbin  "end01.pat.tcf",8
.end01.col:
%incbin  "end01.col.tcf",8
.end02.pat:
%incbin  "end02.pat.tcf",8
.end02.col:
%incbin  "end02.col.tcf",8
.intro01.pat:
%incbin  "intro01.pat.tcf",8
.intro01.col:
%incbin  "intro01.col.tcf",8
.intro02.pat:
%incbin  "intro02.pat.tcf",8
.intro02.col:
%incbin  "intro02.col.tcf",8
.intro03.pat:
%incbin  "intro03.pat.tcf",8
.intro03.col:
%incbin  "intro03.col.tcf",8


p1end:	equ $
	ds      p1padd,0
p1endf: equ $

%if p1size > pagsize
   %warn "Page 0 boundary broken"
%endif

