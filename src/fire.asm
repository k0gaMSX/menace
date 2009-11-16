

MAXFIRE:	equ	5
MAXFIRE_1:      equ     MAXFIRE-1
SPRFIRE_A:	equ	SPRBOOM8+1
FIRECOLOR0:	equ	7
FIRECOLOR1:	equ	8
FIRE_STATE0:	equ	13
FIRE_ATTR:      equ     13
FIRE_HIDEY:     equ     254



;;; TODO: Test fire state by 4 byte of spriteFire <- Someone can explain
;;;                                                  this to me? (k0ga)


InitFire:
	ld	(probFire),a
	xor	a
	ld	(NumFire),a
	ld	(OffsetFire),a
	ld	(FireColor),a
        ld      hl,spriteFire

        ld      a,FIRE_HIDEY
        ld      (hl),a
        ld      de,spriteFire+1
        ld      bc,MAXFIRE*4-1
        ldir
	ret


;;; TODO: Test if searchEnemy is working well, or due to misworking of it,
;;; the funcion newFire result always in the same X <- done, so problem is
;;; due to newFire

;;; bc -> Pointer to map
;;; de -> pointer to end of the map
;;; Return Z = 0 if not found
;;;        Z = 1 if found
;;;        de -> last position in the map looked

searchEnemy:
        ld      a,(bc)
        or      a
        jr      z,.noEnemy

        ld      l,e           ;We are searching here for a 0 zone
        ld      h,d
        or      a
        sbc     hl,bc
        ret     z
        inc     bc
        jr      searchEnemy

.noEnemy:
        ld      a,(bc)         ;We continue searching while we don't found
        or      a              ;a enemy or bc != de
        ret     nz

        ld      l,e
        ld      h,d
        or      a
        sbc     hl,bc
        ret     z
        inc     bc
        jr      .noEnemy






TestFire:
	ld	bc,PatternMap+4*32
	ld	de,PatternMap+5*32
	ld	a,5*8
	ld	(FireY),a


.1ndRow:
        ld      a,(NumFire)
        cp      MAXFIRE
        ret     z
        call    searchEnemy
        jr      z,.2ndRow
	call	NewFire
        jr      .1ndRow


;;; ***************************************************

.2ndRow:
        ret
	ld	bc,PatternMap+6*32
	ld	de,PatternMap+7*32

.2ndRow_1:
        ld      a,(NumFire)
        cp      MAXFIRE
        ret     z
        call    searchEnemy
        ret     z
	call	NewFire
        jr      .2ndRow_1
	ret



moveFire:
    	ld	a,(NumFire)
	or	a
	ret	z

	ld	b,MAXFIRE
	ld	hl,spriteFire

.loop:
	ld	a,(hl)
        cp      FIRE_HIDEY
        jr      z,.endloop
	inc	a
	ld	(hl),a
	call    .chktile

.endloop:
        inc     hl
        inc     hl
        inc	hl
	inc	hl
	djnz	.loop


	ret



.chktile:
	push	hl
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
	cp	0
	jr	z,.n1

        pop     hl              ;Sprite collision with a pattern!!!!
        push    hl
        ld      (hl),FIRE_HIDEY          ;Y sprite = FIRE_HIDEY
        ld      hl,NumFire
        dec     (hl)

	ld	a,94            ;TODO: I must redraw destroyed floor to!!!
	ld	hl,01a00h
	add	hl,de
	ld	de,32*8*2
	or	a
	sbc	hl,de
	call	.vpoke

.n1:
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

;;; bc -> pointer to the block where fire is launched
;;; de -> pointer to last coordenate of the row
;;; (FireY) -> y coordinate

HANG:   di
        halt

NewFire:
	push	bc
	push 	de

        ex      de,hl
        or      a
        sbc     hl,bc
	ld	(.pos),hl
	;; call	Rand
	;; ld	hl,probFire
	;; cp	(hl)
	;; ret	c

	ld	a,(NumFire)
	cp 	MAXFIRE
	ret	z

        cp     2
        ret    z

        pop     de              ;FIXME: This 3 opcodes are here to help debugging
        pop     bc              ;routine is hanging MSX in the next loop
        ret


        ld      c,MAXFIRE
	ld	hl,spriteFire
.searchsprite:
        ld      a,(hl)
        cp      FIRE_HIDEY
        jr      z,.foundSprite
        dec     c
        call    z,HANG

        inc     hl
        inc     hl
        inc     hl
        inc     hl
        jr      .searchsprite

.foundSprite:
	ld	a,(FireY)
	ld	(hl),a
	inc	hl



	ld	de,(.pos)
        ld      b,5
.1:     srl     d
        rl      e
        djnz    .1


	ld	hl,NumFire
	inc	(hl)

 	ld	a,(contframeEnemy) ;d must be always 0 due to there is only
        add     a,e                ;255 x pos (.pos == initialDE - initialBC)
	ld	(hl),a


	pop	de
	pop	bc
	ret





section rdata
.pos:	rw	1
section code


renderFire:
 	;; xor	a
 	;; ld	hl,spratt+SPRFIRE_A*4
 	;; ld	(hl),a
 	;; ld	de,spratt+SPRFIRE_A*4+1
 	;; ld	bc,(MAXFIRE-1)*4-1
  	;; ldir

	ld	hl,FireColor
	ld	a,FIRECOLOR1
	cp	(hl)
	jr	z,.01
	ld	(hl),a
	jr	.0

.01:	ld	a,FIRECOLOR0
	ld	(hl),a

.0:
	ld	b,MAXFIRE
	ld	de,spriteFire
 	ld	ix,spratt+SPRFIRE_A*4
.1:	call	.writeSprite
	djnz	.1


	;; ld	a,(OffsetFire)
	;; inc	a
	;; cp	MAXFIRE-1
	;; jr	nz,.2
	;; xor	a

.2:	ld	(OffsetFire),a
	ret




;;; b -> Number of sprite



.writeSprite:
        push    bc
 	ld	a,(de)
	inc	de
	ld	(ix+0),a
 	ld	a,(de)
	inc	de
	ld	(ix+1),a
        ld      a,FIRE_ATTR
	ld	(ix+2),a
	ld	a,(FireColor)
	ld	(ix+3),a
        inc     ix
        inc     ix
        inc     ix
        inc     ix
        inc     de
        inc     de
        pop     bc
	ret

;; .writeSprite:
	;; push	bc
	;; ld	c,b
	;; dec	c
	;; ld	a,(OffsetFire)
	;; add	a,c
	;; and	MAXFIRE-1

 	;; add	a,a
 	;; add	a,a
 	;; ld	ix,spratt+SPRFIRE_A*4
 	;; ld	c,a
 	;; ld	b,0
 	;; add	ix,bc

 	;; ld	a,(de)
	;; inc	de
	;; ld	(ix+0),a
 	;; ld	a,(de)
	;; inc	de
	;; ld	(ix+1),a
	;; ld	a,(de)
	;; ld	(ix+2),a
	;; ld	a,(FireColor)
	;; ld	(ix+3),a
	;; pop 	bc
	;; ret



section rdata
FireColor:	rb	1
NumFire:	rb	1
probFire:	rb	1
spriteFire:	rb	MAXFIRE*4
FireY:		rb	1
OffsetFire:	rb	1
section code
