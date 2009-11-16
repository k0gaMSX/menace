

MAXFIRE:	equ	8
MAXFIRE_1:	equ	MAXFIRE-1
SPRFIRE_A:	equ	25
FIRECOLOR0:	equ	7
FIRECOLOR1:	equ	8	
FIRE_STATE0:	equ	13





;;; TODO: Test fire state by 4 byte of spriteFire


	
InitFire:
	ld	(probFire),a
	xor	a	
	ld	(NumFire),a
	ld	(OffsetFire),a
	ld	(FireColor),a	
	ret




	
TestFire:
	ret
	ld	bc,PatternMap+4*32
	ld	de,PatternMap+5*32
	xor	a
	ld	(.state),a
	ld	a,4*8
	ld	(FireY),a
	
.1ndRowl:	
	ld	l,c
	ld	h,b
	or	a
	sbc	hl,de
	jr	z,.2ndRow

	ld	hl,.state
	ld	a,(bc)
	cp	(hl)
	jr	z,.1ndRowi

	ld	(hl),a
	or	a
	push	bc
	push 	de
	call	nz,NewFire
	pop	de
	pop	bc

.1ndRowi:
	inc	bc
	jr	.1ndRowl



;;; ***************************************************
	
.2ndRow:
	ret
	ld	bc,PatternMap+8*32
	ld	de,PatternMap+9*32
	xor	a
	ld	(.state),a
	ld	a,8*8
	ld	(FireY),a
	
	
.2ndRowl:	
	ld	l,c
	ld	h,b
	or	a
	sbc	hl,de
	ret	z

	ld	hl,.state
	ld	a,(bc)
	cp	(hl)
	jr	z,.2ndRowi

	ld	(hl),a
	or	a
	push	bc
	push	de
	call	nz,NewFire
	pop	de
	pop	bc
	

.2ndRowi:
	inc	bc
	jr	.2ndRowl
	ret
	



section rdata
.state:	rb	1
section code	






moveFire:
	ret
	ld	a,(NumFire)
	or	a
	ret	z

	ld	b,a
	ld	hl,spriteFire

.loop:	
	ld	a,(hl)
	inc	a
	ld	(hl),a	
	push	af
	call    .chktile
	pop	af
	inc	hl
	inc	hl
	inc	hl
	djnz	.loop
	

	ret
	


.chktile:
	push	hl
	push	af
	
 	inc	hl
  	ld	e,(hl)
  	add	a,8
  	and	0f8h
 	ld	l,a
 	ld	h,0
 	ld	d,h
	ld	a,e
	and	0f8h
	rrca
	rrca
	rrca	
	ld	e,a
 	add	hl,hl
 	add	hl,hl
 	add	hl,de
	ex	de,hl
	ld	hl,PatternMap
	add	hl,de
	
	ld	a,(hl)
	cp	30
	jr	nz,.n1

	ld	a,94
	ld	hl,01a00h
	add	hl,de
	ld	de,32*8*2
	or	a
	sbc	hl,de
	call	.vpoke
	
.n1:
	pop	af
	pop	hl
	ret
	



.vpoke:
	ex	af,af'
	ex	de,hl
	call	SetPtr_VRAM
	ei
	ex	af,af'	
	out	(98h),a
	ret
	
;;; hl -> pointer to the block where fire is launched
;;; (FireY) -> y coordinate

	
NewFire:
	ret
	ld	(.pos),bc
	call	Rand
	ld	hl,probFire
	cp	(hl)
	ret	c

	
	ld	a,(NumFire)
	cp 	MAXFIRE_1
	ret	z

	cp	1
	ret	z

	
	ld	hl,spriteFire
	add	a,a
	add	a,a
	ld	e,a
	ld	d,0
	add	hl,de

	ld	a,(FireY)
	ld	(hl),a
	
	ld	de,(.pos)
	ld	a,e
	
;; 	ld	a,(contframeEnemy)
;; 	ld	e,a
	and	0e0h
	rlca
	rlca
	rlca
	rlca
	rlca
;;; add	a,8
;;  	sub	a,e

	inc	hl	
	ld	(hl),a
	inc	hl
	ld	a,FIRE_STATE0
	ld	(hl),a
	ld	hl,NumFire
	inc	(hl)
	ret


section rdata
.pos:	rw	1
section code	
	

RenderFire:
	ret
 	xor	a
 	ld	hl,spratt+SPRFIRE_A*4
 	ld	(hl),a
 	ld	de,spratt+SPRFIRE_A*4+1
 	ld	bc,MAXFIRE_1*4-1
  	ldir
	

	ld	hl,FireColor
	ld	a,FIRECOLOR1
	cp	(hl)
	jr	z,.01
	ld	(hl),a
	jr	.0
	
.01:	ld	a,FIRECOLOR0
	ld	(hl),a
	
.0:	ld	a,(NumFire)
	or	a
	ret 	z


	ld	b,a
	ld	de,spriteFire
.1:	call	.writeSprite
	djnz	.1
	
	
	ld	a,(OffsetFire)
	inc	a
	cp	MAXFIRE-1
	jr	nz,.2
	xor	a
	
.2:	ld	(OffsetFire),a
	ret

	
	

;;; b -> Number of sprite
	
.writeSprite:
	push	bc
	ld	c,b
	dec	c
	ld	a,(OffsetFire)
	add	a,c
	and	MAXFIRE-1
	
 	add	a,a
 	add	a,a
 	ld	ix,spratt+SPRFIRE_A*4
 	ld	c,a
 	ld	b,0
 	add	ix,bc

 	ld	a,(de)
	inc	de	
	ld	(ix+0),a
 	ld	a,(de)
	inc	de		
	ld	(ix+1),a
	ld	a,(de)
	ld	(ix+2),a
	ld	a,(FireColor)
	ld	(ix+3),a
	pop 	bc
	ret
	

	
section rdata
FireColor:	rb	1
NumFire:	rb	1
probFire:	rb	1
spriteFire:	rb	MAXFIRE*4
FireY:		rb	1
OffsetFire:	rb	1
section code	
