
POS_HISCORE:	equ	2
POS_SCORE:	equ	13

IHISCORE_1:	equ	0
IHISCORE_2:	equ	0
IHISCORE_3:	equ	8
IHISCORE_4:	equ	0
IHISCORE_5:	equ	0



InitScore:
	ld	hl,.ihiscore
	ld	de,hiscore
	ld	bc,5
	ldir

	xor	a
	ld	hl,score
	ld	b,5

.iscorel:
	ld	(hl),a
	inc	hl
	djnz	.iscorel
	ret

.ihiscore:
	db	IHISCORE_1
	db	IHISCORE_2
	db	IHISCORE_3
	db	IHISCORE_4
	db	IHISCORE_5


;;; ********************************************


BeginScore:
	xor	a
	ld	hl,score
	ld	b,5
.becorel:
	ld	(hl),a
	inc	hl
	djnz	.becorel
	ret

;;; ********************************************


;;; a -> number of increment score

addScore:
	ld	hl,.scoreTable+4
	ld	de,5
	ld	b,a


.1:	or	a
	jr	z,.2
	add	hl,de
	jr	.1

.2:	ld	c,0
	ld	b,5
	ld	de,score+4


.loop:	ld	a,(de)
	add	a,(hl)
	add	a,c
	ld	c,0
	cp	10
	jr	c,.3
	sub	10
	inc	c
.3:	ld	(de),a
	dec	hl
	dec	de
	djnz	.loop

	call	cmdHiScore
	call	PrintScore
	ret


.scoreTable: db 0,0,1,0,0
	     db	0,0,2,0,0
	     db 0,0,3,0,0



;;;*********************************************************

cmdHiScore:
	ld	hl,score
	ld	de,hiscore
	ld	b,5

.loop:
	ld	a,(de)
	cp	(hl)
	jr	z,.1
	ret	nc

	ld	hl,score
	ld	de,hiscore
	ld	bc,5
	ldir
	ret

.1:	inc	hl
	inc	de
	djnz	.loop
	ret


;;; ********************************************


PrintScore:
	ld	hl,score
	ld	d,1
	ld	e,POS_SCORE
	call	.PrintBCD

	ld	hl,hiscore
	ld	d,1
	ld	e,POS_HISCORE

.PrintBCD:
	ld	b,5
.pbcdl:	ld	a,(hl)
	call	.PrintDigit
	inc	hl
	djnz	.pbcdl


	ld	hl,PatternMap+32
	ld	de,1800h+32
	ld	bc,32
	call	LDIRVM
	ret


;;; ********************************************

.PrintDigit:
	push	hl
	push	de
	ld	l,d
	ld	h,0
	ld	d,h
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,de
	ld	de,PatternMap
	add	hl,de
	add	a,4*32
	ld	(hl),a
	pop	de
	inc	de
	pop	hl
	ret





section rdata
hiscore:	rb	5
score:		rb	5

section code

