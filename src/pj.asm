


SPRCHAIN1:	equ	8
SPRCHAIN2:	equ	SPRCHAIN1+1
SPRCHAIN3:	equ	SPRCHAIN2+1

SPRRCK1:	equ	SPRCHAIN3+1
SPRRCK2:	equ	SPRRCK1+1
SPRRCK3:	equ	SPRRCK2+1
SPRRCK4:	equ	SPRRCK3+1

SPRFIRE1:	equ	SPRRCK4+1
SPRFIRE2:	equ	SPRFIRE1+1


SPRBOOM1:	equ 	SPRFIRE2+1
SPRBOOM2:	equ	SPRBOOM1+1
SPRBOOM3:	equ	SPRBOOM2+1
SPRBOOM4:	equ	SPRBOOM3+1
SPRBOOM5:	equ 	SPRBOOM4+1
SPRBOOM6:	equ	SPRBOOM5+1
SPRBOOM7:	equ	SPRBOOM6+1
SPRBOOM8:	equ	SPRBOOM7+1





INITIALPOS:	equ	(256/2-16)/8
INITIALFRAME:	equ	8
INITIALHURRY:	equ	240




%include 	"boom.asm"


InitPJ:
	call	CleanBoom
	ld	a,INITIALPOS
	ld	(pos),a
	ld	a,INITIALFRAME
	ld	(frame),a
	ld	(countchain),a
	xor	a
	ld	(fired),a
	ld	(boom),a
	ld	a,INITIALHURRY
	ld	(hurryup),a

	ld	hl,basegfxt
 	ld	bc,6*8
 	ld	de,basegfx
 	ldir

	ld	a,129
	ld	(rocketx),a
	ld	a,144
	ld	(rockety),a

	ld	hl,.sprdatapj
	ld	de,spratt
	ld	bc,15*4
	ldir
	ret


.sprdatapj:
	db	1,200,250,0
	db	1,208,250,0
	db	1,216,250,0
	db	1,224,250,0
	db	9,200,250,0
	db	9,208,250,0
	db	9,216,250,0
	db	9,224,250,0
	db	159,0,56,14
	db	159,0,57,14
	db	159,0,58,14
	db	144,129,0,14
	db	152,129,1,14
	db	144,129,2,8
	db	152,129,3,8


section rdata
pos:		rb	1
frame:		rb	1
fired:		rb	1
rocketx:	rb	1
rockety:	rb	1
keyleft:	rb	1
keyright:	rb	1
keyfire:	rb	1
keyfirenew:	rb	1
basegfx:	rb	40
basegfxt:	rb	48
countchain:	rb	1
section	code



Death:
	ld	hl,NumLives
	dec	(hl)

	ld	a,1
	ld	(DeathF),a

	ld	a,3
	ld	(fired),a
	call	cleanBase
	call	cleanRocket
	ld	a,230
	ld	(rocketx),a
	ld	(rockety),a
	ret




testcol:	ld	b,4
		ld	de,4
		ld	hl,spriteFire
.loop:		push	hl
		call	.check
		pop	hl
		jr	c,.hit
		ld	a,(fired)
		or	a
		jr	nz,.no.pj
		push	hl
		call	.check.pj
		pop	hl
		jr	c,.hit
.no.pj:		add	hl,de
		djnz	.loop
		ret

.hit:		call	TestDeath
		ret	nz

		call	pjexp
		call	toBoom
		jr	Death

.check:		ld	a,(rockety)
		add	a,2
		sub	(hl)
		jr	c,.yswap
		cp	8		; bullet height
		jr	c,.checkx
		ret
.yswap:		neg
		cp	12		; rocket height
		ret	nc
.checkx:	inc	hl
		ld	a,(rocketx)
		add	a,2
		sub	(hl)
		jr	nc,.noxswap
		neg
		cp	5		; rocket width
		ret
.noxswap:	cp	2		; bullet width
		ret

.check.pj:	ld	a,(rockety)
		add	a,19
		sub	(hl)
		jr	c,.yswap.pj
		cp	8		; bullet height
		jr	c,.checkx.pj
		ret
.yswap.pj:	neg
		cp	1		; platform height
		ret	nc
.checkx.pj:	inc	hl
		ld	a,(rocketx)
		sub	8
		sub	(hl)
		jr	nc,.noxswap.pj
		neg
		cp	24		; platform width
		ret
.noxswap.pj:	cp	2		; bullet width
		ret



doPj:
	call	move_pj
	call	testcol
	call	renderPJ
	ret



move_pj:
	ld	a,(fired)
	cp	3
	ret	z

	ld	hl,PatternMap+20*32
	ld	de,PatternMap+20*32+1
	ld	bc,31
	ld	(hl),b
	ldir

	ld	a,15
	ld	e,8fh
	call	WRTPSG
	ld	a,14
	call	RDPSG
	cpl
	rra		; skip up
	rra		; skip down
	and	7
	ld	b,a
	ld	a,8
	call	SNSMAT
	cpl
	rlca
	and	23h	; =NC
	bit	5,a
	jr	z,.nc
	scf		; =C
.nc:	rla
	or	b
	ld	b,a
	rr	b
	sbc	a,a
	ld	(keyleft),a
	rr	b
	sbc	a,a
	ld	(keyright),a
	rr	b
	sbc	a,a
	ld	b,a
	ld	hl,keyfire
	ld	a,[hl]
	xor	b
	ld	[keyfirenew],a
	ld	[hl],b

	ld	a,(fired)
	cp	1
	call	nz,.move_base
	jp	.move_rocket



.move_base:
	ld	a,[hurryup]
	or	a
	jr	z,.hurryup
	dec	a
	ld	[hurryup],a
.hurryup:

	ld	a,(fired)
	cp	2
	jr	nz,.mvb1
	xor	a
	ld	(fired),a

.mvb1:
	ld	hl,keyfirenew
	ld	a,(keyfire)
	and	[hl]
	and	1
	jr	z,.move_baseN
	ld	(fired),a
	ld	a,INITIALHURRY
	ld	(hurryup),a
	ld	a,4
	ld	(contRocket),a
	call	cleanBase
	ret

.move_baseN:
	ld	a,(keyleft)
	or	a
	jr	z,.baseright

	ld	hl,pos
	xor	a
	cp	(hl)
	ret	z


	ld	hl,rocketx
	dec	(hl)

	ld	hl,frame
	ld	a,1
	cp	(hl)
	jr	nz,.noincposl

	ld	a,INITIALFRAME
	ld	(hl),a
	ld	hl,pos
	dec	(hl)

 	ld	hl,basegfxt
 	ld	bc,5*8
 	ld	de,basegfx
 	ldir
	ret


.noincposl:
	dec	(hl)
	ld	ix,basegfx
	ld	b,8
.shiftleft:
	or	a
	rl	(ix+32)
	rl	(ix+24)
	rl	(ix+16)
	rl	(ix+8)
	rl	(ix)
	inc	ix
	djnz	.shiftleft
	call	base_motor
	ret




.baseright:
	ld	a,(keyright)
	or	a
	ret	z


	ld	hl,pos
	ld	a,27
	cp	(hl)
	ret	z

	ld	hl,rocketx
	inc	(hl)


	ld	hl,frame
	ld	a,15
	cp	(hl)
	jr	nz,.noincposr

	ld	a,INITIALFRAME
	ld	(hl),a
	ld	hl,pos
	inc	(hl)
 	ld	hl,basegfxt
 	ld	bc,5*8
 	ld	de,basegfx
 	ldir
	ret


.noincposr:
	inc	(hl)
	ld	ix,basegfx
	ld	b,8
.shiftright:
	or	a
	rr	(ix+0)
	rr	(ix+8)
	rr	(ix+16)
	rr	(ix+24)
	rr	(ix+32)
	inc	ix
	djnz	.shiftright
	call	base_motor
	ret






.mvrck_side:
	ld	a,(rocketx)
	ld	b,a
	ld	a,(keyright)
	or	a
	jr	z,.mvrck1
	ld	a,247
	cp	b
	jr	z,.mvrck2
	inc	b


.mvrck1:
	ld	a,(keyleft)
	or	a
	jr	z,.mvrck2
	xor	a
	cp	b
	jr	z,.mvrck2
	dec	b


.mvrck2:
	ld	a,b
	ld	(rocketx),a
	ret









.move_rocket:
	ld	a,(rockety)
	cp	16
	jp	c,.nocol_rock


	and	0f8h
	ld	l,a
	ld	h,0
	ld	d,h
	add	hl,hl
	add	hl,hl
	ld	a,(rocketx)
	srl	a
	srl	a
	srl	a
	ld	e,a
	add	hl,de
	ld	de,PatternMap
	add	hl,de
	ld	de,32

	ld	a,(rockety)
	and	7
	jr	z,.no3ch_1
	ld	a,(hl)
	or	a
	jp	nz,.col_rock

	add	hl,de
.no3ch_1:
	ld	a,(hl)
	or	a
	jp	nz,.col_rock
	add	hl,de
	ld	a,(hl)
	or	a
	jp	nz,.col_rock


;;; We begin here with the second pattern when it is necessary
	ld	a,(rocketx)
	and	7
	jp	z,.nocol_rock

	ld	de,-32
	inc	hl
	ld	a,(rockety)
	and	7
	jr	z,.no3ch_2


	ld	a,(hl)
	or	a
	jp	nz,.col_rock
	add	hl,de

.no3ch_2:
	ld	a,(hl)
	or	a
	jp	nz,.col_rock
	add	hl,de
	ld	a,(hl)
	or	a
	jp	nz,.col_rock
	jp	.nocol_rock


.col_rock:
	cp 	METEOR_PAT1
	call	z,meteor_col
	cp 	METEOR_PAT2
	call	z,meteor_col
	cp 	METEOR_PAT3
	call	z,meteor_col
	cp 	METEOR2_PAT1
	call	z,meteor_col
	cp 	METEOR2_PAT2
	call	z,meteor_col
	cp 	METEOR2_PAT3
	call	z,meteor_col

	cp 	ENEMY_PAT1
	call	z,enemy_col
	cp 	ENEMY_PAT2
	call	z,enemy_col
	cp 	ENEMY_PAT3
	call	z,enemy_col
	cp 	ENEMY_PAT4
	call	z,enemy_col
	cp 	ENEMY_PAT5
	call	z,enemy_col
	cp 	ENEMY_PAT6
	call	z,enemy_col

	cp 	ENEMY2_PAT1
	call	z,enemy_col
	cp 	ENEMY2_PAT2
	call	z,enemy_col
	cp 	ENEMY2_PAT3
	call	z,enemy_col
	cp 	ENEMY2_PAT4
	call	z,enemy_col
	cp 	ENEMY2_PAT5
	call	z,enemy_col
	cp 	ENEMY2_PAT6
	call	z,enemy_col

	cp 	ENEMY3_PAT1
	call	z,enemy_col
	cp 	ENEMY3_PAT2
	call	z,enemy_col
	cp 	ENEMY3_PAT3
	call	z,enemy_col
	cp 	ENEMY3_PAT4
	call	z,enemy_col
	cp 	ENEMY3_PAT5
	call	z,enemy_col
	cp 	ENEMY3_PAT6
	call	z,enemy_col

	cp 	ENEMY4_PAT1
	call	z,enemy_col
	cp 	ENEMY4_PAT2
	call	z,enemy_col
	cp 	ENEMY4_PAT3
	call	z,enemy_col
	cp 	ENEMY4_PAT4
	call	z,enemy_col
	cp 	ENEMY4_PAT5
	call	z,enemy_col
	cp 	ENEMY4_PAT6
	call	z,enemy_col




.nocol_rock:
	ld	a,(fired)		; don't move unless it's flying
	cp	1
	ret	nz

	ld	a,(keyfire)
	or	a
	jr	nz,.mvrocket_sp

	ld	hl,contRocket
	dec	(hl)
	ret	nz
	ld	a,6
	ld	(hl),a

.mvrocket_sp:
	call	.mvrck_side
	ld	hl,rockety
	dec	(hl)
	ret	nz


ToBase:
	ld	a,2
 	ld	(fired),a
	ld	a,INITIALPOS
	ld	(pos),a
	add	a,a
	add	a,a
	add	a,a
	ld	b,a
	ld	a,(frame)
	add	a,b
	add	a,9
	ld	(rocketx),a
	ld	a,144
	ld	(rockety),a
	ret



section rdata
contRocket:	rb	1
section code






;;; *****************************************************


TestRocketCol:
	ld	a,(rockety)
	and	7
	ld	(.Yoff),a
	ld	c,a
	ld	a,7
	sub	c		;a = 7 - Y%8
	ld	(.YoffC),a

	ld	a,(rocketx)
	and	7
	ld	(.Xoff),a
	or	a
	jr	z,.noright
	ld	c,a
	ld	b,a
	ld	a,80h
.1:	sra	a
	djnz	.1
.noright:
	ld	(.maskr),a
	ld	a,7
	sub	c		;a = 7 - X%8
	ld	(.XoffC),a
	or	a
	jr	z,.noleft

	ld	b,a
	ld	a,1
.2:	sll	a
	djnz	.2
.noleft:
	ld	(.maskl),a


	ld	a,(rockety)
	and	0f8h
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	ld	de,PatternMap
	add	hl,de

	ld	a,(rocketx)
	and	0f8h
	rrca
	rrca
	rrca
	ld	e,a
	ld	d,0
	add	hl,de		; hl = rockety/8*32 + rocketx/8

	ld	(.maptr),hl
   	call	.1stPart
   	call	z,.2ndPart
  	call	z,.3rdPart
 	ld	a,0
  	ret	z

 	ld	a,1
	ret




;;;*******************************************************



.1stPart:
	ld	a,(.Yoff)
	or	a
	ret	z
	ld	e,a
	ld	d,0
	ld	(.offsetY),de

	ld	a,(.YoffC)
	inc	a
	ld	(.NumberY),a

	ld	a,(.maskl)
	ld	(.mask),a
	call	.Test1b
	ret	nz

	ld	a,(.maskr)
	ld	(.mask),a
	call	z,.Test1b
	ret	nz

	ld	hl,(.maptr)
	ld	de,30
	add	hl,de
	ld	(.maptr),hl
	xor	a
	ret





.2ndPart:
	ld	a,8
	ld	(.NumberY),a

	ld	de,0
	ld	(.offsetY),de

	ld	a,(.maskl)
	ld	(.mask),a
	call	.Test1b
	ret	nz

	ld	a,(.maskr)
	ld	(.mask),a
	call	z,.Test1b
	ret	nz

	ld	hl,(.maptr)
	ld	de,30
	add	hl,de
	ld	(.maptr),hl
	xor	a
	ret





.3rdPart:
	ld	a,(.Yoff)
	inc	a
	ld	(.NumberY),a

	ld	de,0
	ld	(.offsetY),de

	ld	a,(.maskl)
	ld	(.mask),a
	call	.Test1b
	ret	nz

	ld	a,(.maskr)
	ld	(.mask),a
	call	z,.Test1b
	ret	nz

	xor	a
	ret






;;; (.maptr) -> pointer to pattern map
;;; (.offsetY) -> offset in Y
;;; (.NumberY) -> number of pixels in Y
;;; (.mask) -> Mask

.Test1b:
	ld	hl,(.maptr)
	ld	a,(hl)
	inc	hl
	ld	(.maptr),hl
	call	.GetByteDef

	ld	bc,(.offsetY)
	ld	hl,.def
	add	hl,bc

	ld	a,(.numberY)
	ld	b,a

.Test1bLoop:
	ld	c,(hl)
	ld	a,(.mask)
	and	c
 	ret	nz
	inc	hl
	djnz	.Test1bLoop


	xor	a
	ret






;;; a -> Number of pattern

.GetByteDef:
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	de,(BankPattern)
	add	hl,de
 	ex	de,hl
 	call	ReadPTR_VRAM
	ei
	ld	b,8
	ld	hl,.def

.getdefloop:
	in	a,(c)
	ld	(hl),a
	inc	hl
	djnz	.getdefloop
 	ret



section rdata
.offsetY: rw 1
.numberY: rb 1
.maptr:	  rw 2
.maskl:	  rb 1
.maskr:	  rb 1
.mask:	  rb 1
.def:	  rb 8
.Xoff:	  rb 1
.XoffC:	  rb 1
.Yoff:	  rb 1
.YoffC:	  rb 1
BankPattern:	rw 1
section code




;;; *************************************************************





renderPJ:
	ld	a,(fired)
	cp	2
	jp	nz,.noState2

	call	cleanRocket
	call	renderBoom
	ret



.noState2:
	call	renderBase
	call	renderBoom



.renderocket:
	ld	a,(fired)
	cp	3
	jr	nz,.renderocket0
	call	cleanRocket
	ret


.renderocket0:
	ld	a,(rocketx)
	ld	(spratt+SPRRCK1*4+1),a
	ld	(spratt+SPRRCK2*4+1),a
	ld	(spratt+SPRRCK3*4+1),a
	ld	(spratt+SPRRCK4*4+1),a

	ld	a,(rockety)
	ld	(spratt+SPRRCK1*4+0),a
	ld	(spratt+SPRRCK3*4+0),a
	add	a,8
	ld	(spratt+SPRRCK2*4+0),a
	ld	(spratt+SPRRCK4*4+0),a

	ld	a,(spratt+SPRRCK1*4+2)
	or	a
	xor	4

.renderocket1:
	ld	(spratt+SPRRCK1*4+2),a
	inc	a
	ld	(spratt+SPRRCK2*4+2),a
	inc	a
	ld	(spratt+SPRRCK3*4+2),a
	inc	a
	ld	(spratt+SPRRCK4*4+2),a

	ld	a,(fired)
	or	a
	jr	z,.renderrck1
	ld	a,(keyfire)
	or	a
	jr	z,.renderrck1

	ld	a,(rocketx)
	ld	(spratt+SPRFIRE1*4+1),a
	ld	(spratt+SPRFIRE2*4+1),a
	ld	a,(rockety)
	add	a,16
	ld	(spratt+SPRFIRE1*4+0),a
	ld	(spratt+SPRFIRE2*4+0),a
	ld	b,10
	ld	a,(spratt+SPRFIRE1*4+2)
	cp	8
	jr	z,.renderrck2
	ld	b,8

.renderrck2:
	ld	a,b
	ld	(spratt+SPRFIRE1*4+2),a
	inc	a
	ld	(spratt+SPRFIRE2*4+2),a
	ld	a,11
	ld	(spratt+SPRFIRE1*4+3),a
	ld	a,8
	ld	(spratt+SPRFIRE2*4+3),a
	call	rck_ignition
	ret


.renderrck1:
	ld	a,255
	ld	(spratt+SPRFIRE1*4+2),a
	ld	(spratt+SPRFIRE2*4+2),a
	ret





renderBase:
	ld	a,(fired)
	or	a
	ret	nz

	ld	hl,PatternMap+20*32
	ld	a,(pos)
	ld	e,a
	ld	d,0
	add	hl,de
	ld	a,120
	ld	b,5


.baseEnd1:
	ld	(hl),a
	inc	a
	inc	hl
	djnz	.baseEnd1


	ld	a,(frame)
	ld	b,a
	ld	a,(pos)
	add	a,a
	add	a,a
	add	a,a
	add	a,b
	ld	hl,spratt+SPRCHAIN1*4+1
	ld	b,3

.baseEnd2:
	ld	(hl),a
	add	a,8
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	djnz	.baseEnd2

	ld	hl,countchain
	dec	(hl)
	ret	nz
	ld	a,8
	ld	(hl),a

	ld	b,59
	ld	a,(spratt+SPRCHAIN1*4+2)
	cp	56
	jr	z,.baseEnd3
	ld	b,56

.baseEnd3:
	ld	a,b
	ld	(spratt+SPRCHAIN1*4+2),a
	inc	a
	ld	(spratt+SPRCHAIN2*4+2),a
	inc	a
	ld	(spratt+SPRCHAIN3*4+2),a
	ret




cleanRocket:
	ld	a,230
	ld	(spratt+SPRRCK1*4+0),a
	ld	(spratt+SPRRCK2*4+0),a
	ld	(spratt+SPRRCK3*4+0),a
	ld	(spratt+SPRRCK4*4+0),a
	ld	(spratt+SPRFIRE1*4+0),a
	ld	(spratt+SPRFIRE2*4+0),a
	ret




cleanBase:
	ld	hl,PatternMap+20*32
	ld	a,(pos)
	ld	e,a
	ld	d,0
	add	hl,de
	push	hl
	ld	de,savebase
	ld	bc,5
	ldir

	pop	hl
	ld	e,l
	ld	d,h
	inc	de
	xor	a
	ld	(hl),a
	ld	bc,4
	ldir

	ld	a,254
	ld	b,3
	ld	hl,spratt+SPRCHAIN1*4+2
	ld	de,4
.4:	ld	(hl),a
	add	hl,de
	djnz	.4
	ret


section rdata
savebase:	rb	5
GetColorPar:	rb	1
hurryup:	rb	1
section code

