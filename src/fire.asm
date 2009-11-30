

MAXFIRE:	equ	5
MAXFIRE_1:      equ     MAXFIRE-1
SPRFIRE_A:	equ	SPRBOOM8+1
FIRECOLOR0:	equ	7
FIRECOLOR1:	equ	8
FIRE_STATE0:	equ	13
FIRE_ATTR:      equ     13
FIRE_HIDEY:     equ     224
PATTERN_FLOOR1: equ     30
PATTERN_FLOOR2: equ     31




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



;;; bc -> Pointer to map
;;; de -> pointer to end of the row
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
        call    Rand
	ld	hl,probFire
	cp	(hl)
        ret     nc
	ld	a,5*8
	ld	(FireY),a
        call    NewFire
        ret



;; 	ld	bc,PatternMap+4*32
;; 	ld	de,PatternMap+5*32
;; 	ld	a,5*8
;; 	ld	(FireY),a


;; .1ndRow:
;;         ld      a,(NumFire)
;;         cp      MAXFIRE-1
;;         ret     z
;;         call    searchEnemy
;;         jr      z,.2ndRow
;; 	call	NewFire
;;         jr      .1ndRow


;; ;;; ***************************************************

;; .2ndRow:
;;         ret
;; 	ld	bc,PatternMap+6*32
;; 	ld	de,PatternMap+7*32
;; 	ld	a,7*8
;; 	ld	(FireY),a

;; .2ndRow_1:
;;         ld      a,(NumFire)
;;         cp      MAXFIRE-1
;;         ret     z
;;         call    searchEnemy
;;         ret     z
;; 	call	NewFire
;;         jr      .2ndRow_1
;; 	ret









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

	ld	a,(hl)          ;Test if there is something i the pattern map
	cp	PATTERN_FLOOR1
	jr	z,.n1
	cp	PATTERN_FLOOR2
	jr	z,.n1

	pop	hl
	ret



.n1:
        pop     hl              ;Sprite collision with a pattern!!!!
        push    hl
        ld      (hl),FIRE_HIDEY          ;Y sprite = FIRE_HIDEY
        ld      hl,NumFire
        dec     (hl)

	ld	a,64
	ld	hl,01a00h
	add	hl,de
	ld	de,32*8*2
	or	a
	sbc	hl,de

.vpoke:
	ex	af,af'
	ex	de,hl
	call	SetPtr_VRAM
	ei
	ex	af,af'
	out	(98h),a
        pop     hl
	ret



savePJ:
	ld	b,MAXFIRE
	ld	de,spriteFire
	ld	hl,NumFire
.loop:
	ld	a,(de)
	cp	FIRE_HIDEY
	jr	z,.next

	ld	a,(de)
	cp	96
	jr	c,.next

	ld	a,(rocketx)
	sub	10
	ld	c,a

	inc	de
	ld	a,(de)
	dec	de
	cp	c
	jr	c,.next

	ld	a,c
	add	a,30
	ld	c,a

	inc	de
	ld	a,(de)
	dec	de
	cp	c
	jr	nc,.next

	ld	a,FIRE_HIDEY
	ld	(de),a
	dec	(hl)

.next:	inc	de
	inc	de
	inc	de
	inc	de
	djnz	.loop
	ret



;;; bc -> pointer to the block where fire is launched
;;; de -> pointer to last coordenate of the row
;;; (FireY) -> y coordinate


NewFire:
	push	bc
	push 	de
        call    .newFire1
        pop     de
        pop     bc
        ret

.newFire1:
        ;; ld      hl,-256         ;one row less
        ;; add     hl,de
        ;; ex      de,hl
        ;; ld      l,c
        ;; ld      h,b
        ;; or      a
        ;; sbc     hl,de
        ;; ld      a,l
	;; ld	(.pos),a
	ld	a,(NumEnemy)
	inc	a
	sra	a
;	dec	a
	ld	c,a
	ld	a,(NumFire)
	cp 	c
	ret	z

	ld	hl,spriteFire
.searchsprite:
        dec     c
        ret     z               ;We will never return, it's only secure
                                ;development
        ld      a,(hl)
        cp      FIRE_HIDEY
        jr      z,.foundSprite

        inc     hl
        inc     hl
        inc     hl
        inc     hl
        jr      .searchsprite

.foundSprite:
	ld	a,(FireY)
	ld	(hl),a
	inc	hl
	ld	a,(.pos)
        call    Rand
        ld      (hl),a


	ld	hl,NumFire
	inc	(hl)
	ret





section rdata
.pos:	rb	1

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
	call	.rotate

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


.rotate:	ld	b,4
.loop:		push	bc
		ld	bc,MAXFIRE_1*4-1
		ld	de,spriteFire
		ld	hl,spriteFire+1
		ld	a,(de)
		ldir
		ld	(de),a
		pop	bc
		djnz	.loop
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
