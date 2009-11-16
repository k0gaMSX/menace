


SPRCHAIN1:	equ	8
SPRCHAIN2:	equ	SPRCHAIN1+1	
SPRCHAIN3:	equ	SPRCHAIN2+1
			
SPRRCK1:	equ	SPRCHAIN3+1
SPRRCK2:	equ	SPRRCK1+1
SPRRCK3:	equ	SPRRCK2+1
SPRRCK4:	equ	SPRRCK3+1
		
SPRFIRE1:	equ	SPRRCK4+1
SPRFIRE2:	equ	SPRFIRE1+1

	
	
INITIALPOS:	equ	(256/2-16)/8
INITIALFRAME:	equ	8



	
InitPJ:	
	ld	a,INITIALPOS
	ld	(pos),a
	ld	a,INITIALFRAME
	ld	(frame),a
	ld	(countchain),a	
	xor	a
	ld	(fired),a
	ld	(boom),a
	
	ld	hl,scrpat+120*8
	ld	bc,5*8
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
boom:		rb	1
keyleft:	rb	1
keyright:	rb	1
keyfire:	rb	1		
basegfx:	rb	40
countchain:	rb	1
section	code							
	


testcol:	
	ret	

	
doPj:
	call	move_pj	
	call	testcol
	call	renderPJ
	ret
	
			
	
move_pj:		
	xor	a
	ld	hl,PatternMap+20*32
	ld	de,PatternMap+20*32+1
	ld	(hl),a
	ld	bc,31
	ldir
	
	ld	(keyleft),a
	ld	(keyright),a
	ld	(keyfire),a
	ld	a,8
	call	SNSMAT
	ld	b,a
	ld	a,1
	bit	0,b
	jr	nz,.1
	ld	(keyfire),a
	
.1:	bit	7,b
	jr	nz,.2
	ld	(keyright),a
	
		
.2:	bit	4,b
	jr	nz,.3
	ld	(keyleft),a

	
.3:	ld	a,(fired)
	cp	1
	jp	z,.move_rocket
	jp	.move_base


	
	
.move_base:
	ld	a,(fired)
	cp	2
	jr	nz,.mvb1
	ld	a,(keyfire)	
	or	a
	ret	nz
	ld	(fired),a
	
.mvb1:		
	ld	a,(keyfire)
	or	a
	jr	z,.move_baseN
	ld	(fired),a
	ld	a,4
	ld	(contRocket),a
	call	cleanBase
	ret

.move_baseN:
	ld	a,(keyleft)
	or	a
	jr	z,.baseright
	
	ld	hl,pos		; CHECK LIMITS!!!!
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
	ld	hl,scrpat+120*8
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
	ret


	

.baseright:
	ld	a,(keyright)
	or	a
	ret	z

	
	ld	hl,pos		; CHECK LIMITS!!!!
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
	ld	hl,scrpat+120*8
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
	
	ld	a,2
	ld	(fired),a
	ld	a,(pos)
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





renderPJ:
	call	renderBase
	ld	a,(boom)
	or	a
	jr	z,.renderocket
	




	
	
.renderocket:
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
section code	
				