NUMENEMIES:	equ	8
NUMROWS:	equ	2
ENEMYPATW:	equ	2
ENEMYPATH:	equ	2
ENEMYSIZE:	equ     (ENEMYPATW+1)*ENEMYPATH*8
ENEMYLEVELSIZE:	equ     ENEMYPATW*ENEMYPATH*8*2

ENEMYVOFF:	equ	96*8
ENEMY3SPEED:	equ	19
ENEMY2SPEED:	equ	22
ENEMY1SPEED:	equ	26
FRAMETIME:	equ	50
ANIMETIME:	equ	40

ENEMY_PAT1:	equ	96
ENEMY_PAT2:	equ	97
ENEMY_PAT3:	equ	98
ENEMY_PAT4:	equ	99
ENEMY_PAT5:	equ	100
ENEMY_PAT6:	equ	101

ENEMY2_PAT1:	equ	102
ENEMY2_PAT2:	equ	103
ENEMY2_PAT3:	equ	104
ENEMY2_PAT4:	equ	105
ENEMY2_PAT5:	equ	106
ENEMY2_PAT6:	equ	107

ENEMY3_PAT1:	equ	108
ENEMY3_PAT2:	equ	109
ENEMY3_PAT3:	equ	110
ENEMY3_PAT4:	equ	111
ENEMY3_PAT5:	equ	112
ENEMY3_PAT6:	equ	113

ENEMY4_PAT1:	equ	114
ENEMY4_PAT2:	equ	115
ENEMY4_PAT3:	equ	116
ENEMY4_PAT4:	equ	117
ENEMY4_PAT5:	equ	118
ENEMY4_PAT6:	equ	119



%include "fire.asm"


InitEnemy:
	ld	hl,BufferColor1
	ld	(BuffColorPtr1),hl
	ld	hl,BufferColor2
	ld	(BuffColorPtr2),hl
	ld	a,NUMENEMIES
	ld	(NumEnemy),a
	ld	(renderEnemyF),a

	ld	a,(NumLevel)
	dec	a
	ld	de,.LevelData
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,de
	ld	a,(hl)
	ld	(speedEnemy),a
	inc	hl
	ld	a,(hl)
	call	InitFire


	ld	b,2
	ld	hl,coordEnemy
	ld	e,0

.2:	push	bc
	xor	a
	ld	c,256/4
	ld	b,4

.1:	ld	(hl),a
	add	a,c
	inc	hl
	ld	(hl),e
	inc	hl
	djnz	.1

	inc	e
	pop	bc
	djnz	.2

	ld	a,ANIMETIME
	ld	(animationEnemy),a

	ld	a,FRAMETIME
	ld	(contSpeed),a
	ld	a,NUMENEMIES
	ld	(UpdateCont),a
	ld	(contPoint),a
	ld	(pointCont),a
	ld	hl,stateEnemy
	ld	b,NUMENEMIES
.3:	ld	(hl),a
	djnz	.3


	ld	(frameEnemy),a
	ld	(contframeEnemy),a
	xor	a
	ld	bc,ENEMYSIZE*4-1
	ld	hl,BufferEnUp1
	ld	de,BufferEnUp1+1
	ld	(hl),a
	ldir

	ld	a,(NumLevel)
	dec	a
	ld	l,a
	ld	h,0
	ld	de,ENEMYLEVELSIZE
	call	multhlde
	push	hl
	ld	de,enemycol
	add	hl,de
	ld	(.colour),hl
	call	.initColour

	pop	hl
	call	.initAtt
	call	initFPointer

	call	paintAllEnemy

	ret


.LevelData:
	db	1,5*255/255
	db	3,10*255/100
	db	5,20*255/100
	db	7,25*255/100
	db	9,30*255/100
	db	11,40*255/100
	db	13,50*255/100
	db	15,60*255/100
	db      17,70*255/100
	db	19,80*255/100



.initAtt:
	push	hl
	xor	a
	ld	hl,BufferEnUp1
	ld	(hl),a
	ld	de,BufferEnUp1+1
	ld	bc,ENEMYSIZE*4-1
 	ldir

	pop	hl
	ld	de,enemybin
	add	hl,de
	ld	de,BufferEnUp1
	ld	bc,16
	ldir
	ld	de,BufferEnUp1+24
	ld	bc,16
	ldir

	ld	de,BufferEnUp2
	ld	bc,16
	ldir
	ld	de,BufferEnUp2+24
	ld	bc,16
	ldir

	ld	hl,BufferEnUp1
	ld	de,BufferEnDw1+8
	ld	bc,16
	ldir

	ld	hl,BufferEnUp1+24
	ld	de,BufferEnDw1+32
	ld	bc,16
	ldir

	ld	hl,BufferEnUp2
	ld	de,BufferEnDw2+8
	ld	bc,16
	ldir

	ld	hl,BufferEnUp2+24
	ld	de,BufferEnDw2+32
	ld	bc,16
	ldir

        ld	hl,BufferEnUp1
	ld	(bufferPtrUp1),hl

        ld	hl,BufferEnUp2
        ld	(bufferPtrUp2),hl

	ld	hl,BufferEnDw1
        ld	(bufferPtrDw1),hl

	ld	hl,BufferEnDw2
        ld	(bufferPtrDw2),hl
	ret





.initColour:
	ld	hl,(.colour)
	ld	de,BufferColor1
	ld	bc,8
	ldir

	ld	hl,(.colour)
	ld	de,16
	add	hl,de
	ld	de,BufferColor1+8
	ld	bc,8
	ldir

	ld	hl,(.colour)
	ld	de,16*2
	add	hl,de
	ld	de,BufferColor2
	ld	bc,8
	ldir

	ld	hl,(.colour)
	ld	de,16*3
	add	hl,de
	ld	de,BufferColor2+8
	ld	bc,8
	ldir

	ld	hl,BufferColor1
	ld	de,2000h+ENEMYVOFF ;First character
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor1
	ld	de,2000h+ENEMYVOFF+8
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor1
	ld	de,2000h+ENEMYVOFF+16
	ld	bc,8
	call	LDIRVM

	ld	hl,BufferColor1+8
	ld	de,2000h+ENEMYVOFF+24
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor1+8
	ld	de,2000h+ENEMYVOFF+32
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor1+8
	ld	de,2000h+ENEMYVOFF+40
	ld	bc,8
	call	LDIRVM


	;Second character

	ld	hl,BufferColor2
	ld	de,2000h+ENEMYVOFF+48
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor2
	ld	de,2000h+ENEMYVOFF+56
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor2
	ld	de,2000h+ENEMYVOFF+64
	ld	bc,8
	call	LDIRVM

	ld	hl,BufferColor2+8
	ld	de,2000h+ENEMYVOFF+72
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor2+8
	ld	de,2000h+ENEMYVOFF+80
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor2+8
	ld	de,2000h+ENEMYVOFF+88
	ld	bc,8
	call	LDIRVM

;;; **************************************************


	;Third character

	ld	hl,BufferColor1
	ld	de,2000h+ENEMYVOFF+96
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor1
	ld	de,2000h+ENEMYVOFF+104
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor1
	ld	de,2000h+ENEMYVOFF+112
	ld	bc,8
	call	LDIRVM

	ld	hl,BufferColor1+8
	ld	de,2000h+ENEMYVOFF+120
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor1+8
	ld	de,2000h+ENEMYVOFF+128
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor1+8
	ld	de,2000h+ENEMYVOFF+136
	ld	bc,8
	call	LDIRVM

	;Four character

	ld	hl,BufferColor2
	ld	de,2000h+ENEMYVOFF+144
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor2
	ld	de,2000h+ENEMYVOFF+152
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor2
	ld	de,2000h+ENEMYVOFF+160
	ld	bc,8
	call	LDIRVM

	ld	hl,BufferColor2+8
	ld	de,2000h+ENEMYVOFF+168
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor2+8
	ld	de,2000h+ENEMYVOFF+176
	ld	bc,8
	call	LDIRVM
	ld	hl,BufferColor2+8
	ld	de,2000h+ENEMYVOFF+184
	ld	bc,8
	call	LDIRVM		; Here is initializiled colour table
	ret




section rdata
.colour:	rw	1
section code



;;; d -> y
;;; e -> x


DestroyEnemy:
	ld	a,(rocketx)
	ld	e,a
	ld	a,(rockety)
	ld	d,a
	call	.findCorner
	ld	c,3

	xor	a
.loopy:
	ld	b,3
.loopx:
	ld	(hl),a
	inc	hl
	djnz	.loopx

	ld	de,32-3
	add	hl,de
	dec	c
	jr	nz,.loopy

	call	enemyexp

	xor	a
	ret


;;; d -> y
;;; e -> x

.findCorner:
	ld	a,d
	and	0f8h

	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	ld	a,e
	and	0f8h
	rrca
	rrca
	rrca
	ld	e,a
	ld	d,0
	add	hl,de
	ld	de,PatternMap
	add	hl,de


	call	.findEnemy
.findloopL:
        ex      de,hl
        ld      hl,PatternMap+128
        or      a
        sbc     hl,de
        jr      c,.noskip_marquee
        ld      hl,32
        add     hl,de
        jr      .findloopL

.noskip_marquee:
        ex      de,hl
	ld	a,(hl)
	or	a
	jr	z,.findl
	dec	hl
	jr	.findloopL


.findl:	inc	hl
	ld	de,-32

.findloopU:
	ld	a,(hl)
	or	a
	jr	z,.findU
	add	hl,de

.findU:
	ret






.findEnemy:
	ld	b,3
	ld	de,32

.findEnemyl:
	ld	a,(hl)
	or	a
	ret	nz

	dec	hl
	ld	a,(hl)
	or	a
	ret	nz

	inc	hl
	inc	hl
	ld	a,(hl)
	or	a
	ret	nz

	dec	hl
	add	hl,de

	ld	a,e
	add	a,32
	ld	e,a
	djnz	.findEnemyl

	ret			;if we are here, we have a problem!!






enemy_col:
	ld	hl,0
	ld	(BankPattern),hl
	call	TestRocketCol
 	or	a
	ret	z

	call	DestroyEnemy
	call	toBoom
	call	ToBase
	call	savePJ
	ld	hl,NumEnemy
	dec	(hl)
	xor	a
	ld	(fired),a
	call	addScore
 	ret





paintAllEnemy:
	ld	hl,PatternMap+100 ;PatternMap+96 is initial position

.paintAllEne1:
	ld	a,(NumEnemy)		;Paint Enemies
	sra	a
	sra	a
	ld	b,a

.paintAllEne2:
	call	paintEnemy1
	call	paintEnemy2
	djnz	.paintAllEne2

	ld	de,64
	add	hl,de
	ld	a,(NumEnemy)		;Paint Enemies
	sra	a
	sra	a
	ld	b,a

.paintAllEne3:
	call	paintEnemy1_2
	call	paintEnemy2_2
	djnz	.paintAllEne3
	ret



paintEnemy1_2:
	ld	a,108
	jr 	paintEnemy

paintEnemy2_2:
	ld	a,114
	jr 	paintEnemy

paintEnemy1:
	ld	a,96
	jr	paintEnemy

paintEnemy2:
	ld	a,102

paintEnemy:
	ld	de,30
	ld	(hl),a
	inc	a
	inc	hl
	ld	(hl),a
	inc	a
	inc	hl
	ld	(hl),a
	inc	a
	add	hl,de
	ld	(hl),a
	inc	a
	inc	hl
	ld	(hl),a
	inc	a
	inc	hl
	ld	(hl),a

	or	a
	sbc	hl,de		;Insert 3 pattern between each enemy
	inc	hl
	inc	hl
	inc	hl
	ret




DoEnemy:
	call	moveEnemy
	call	renderEnemy
	call	renderFire
	ret






moveEnemy:
	call	.checkPoint
	ret	nz
	call	.setSpeed
	call	moveFire
;;; TODO: HERE WE MUST CHEK FIRE !!!!!!!!!!!!
	ret





.setSpeed:
	ld	a,(NumEnemy)
	cp	3
	jr	nz,.sp1
	ld	a,ENEMY3SPEED
	jr	.sp3

.sp1:	cp	2
	jr	nz,.sp2
	ld	a,ENEMY2SPEED
	jr	.sp3

.sp2:	cp	1
	jr	nz,.sp4
	ld	a,ENEMY1SPEED
.sp3:	ld	(speedEnemy),a

.sp4:


	ret






.checkPoint:	xor	a
		ld	hl,contPoint
		cp	(hl)
		ret	z
		dec	(hl)
		jr	nz,.cp1

;;; TODO: HERE WE HAVE TO CLEAN THE POINT MARK SHOWED IN THE SCREEN

.cp1:		inc	a
		ret





renderEnemy:
	ld	hl,animationEnemy
	dec	(hl)
	jr	nz,.renderEnemy2
	ld	a,ANIMETIME
	ld	(hl),a
	call	SwapEnemy


.renderEnemy2:
	ld	a,(speedEnemy)
	ld	c,a
	ld	a,(contSpeed)
	add	a,c
	cp	FRAMETIME
	jr	c,.endtime
	sub	FRAMETIME
	ld	(contSpeed),a


	call	UpdateChars
	jr	renderEnemy

.endtime:
	ld	(contSpeed),a
        call	TestFire
	ret










UpdateChars:
	ld	a,1
	ld	(renderEnemyF),a
	ld	hl,(redchar_right1)
	call	PointerCall
	ld	hl,(redchar_right2)
	call	PointerCall
	ld	hl,(redchar_left1)
	call	PointerCall
	ld	hl,(redchar_left2)
	call	PointerCall



.updatechar1:
	ld	hl,UpdateCont
	dec	(hl)
	ret	nz
	ld	a,8
	ld	(hl),a

	call	CleanEnemy


	ld	a,(PatternMap+96+31)
	ld 	hl,PatternMap+96+30
	ld	de,PatternMap+96+31
	ld	bc,31
	lddr
	ld	(PatternMap+96+0),a

	ld	a,(PatternMap+128+31)
	ld 	hl,PatternMap+128+30
	ld	de,PatternMap+128+31
	ld	bc,31
	lddr
	ld	(PatternMap+128+0),a

	ld	a,(PatternMap+192+0)
	ld 	hl,PatternMap+192+1
	ld	de,PatternMap+192+0
	ld	bc,31
	ldir
 	ld	(PatternMap+192+31),a

	ld	a,(PatternMap+224+0)
	ld 	hl,PatternMap+224+1
	ld	de,PatternMap+224+0
	ld	bc,31
	ldir
	ld	(PatternMap+224+31),a
	ret



SwapEnemy:
	ld	a,1
	ld	(swapEnemyF),a
        ld	hl,(bufferPtrUp1)
	ld	de,(bufferPtrUp2)
        ld	(bufferPtrUp1),de
	ld	(bufferPtrUp2),hl

	ld	hl,(BuffColorPtr1)
	ld	de,(BuffColorPtr2)
	ld	(BuffColorPtr1),de
	ld	(BuffColorPtr2),hl

        ld	hl,(bufferPtrDw1)
	ld	de,(bufferPtrDw2)
        ld	(bufferPtrDw1),de
	ld	(bufferPtrDw2),hl

	ret





CleanEnemy:
	ld	hl,BufferEnUp1+8
	ld	de,BufferEnUp1
	ld	bc,16
	ldir

	ld	hl,BufferEnUp1+32
	ld	de,BufferEnUp1+24
	ld	bc,16
	ldir

	xor	a
	ld	b,8
	ld	hl,BufferEnUp1+16
.CleanEnUp1_1:
	ld	(hl),a
	inc	hl
	djnz	.CleanEnUp1_1

	xor	a
	ld	b,8
	ld	hl,BufferEnUp1+40
.CleanEnUp1_2:
	ld	(hl),a
	inc	hl
	djnz	.CleanEnUp1_2


	ld	hl,BufferEnUp2+8
	ld	de,BufferEnUp2
	ld	bc,16
	ldir
	ld	hl,BufferEnUp2+32
	ld	de,BufferEnUp2+24
	ld	bc,16
	ldir

	xor	a
	ld	b,8
	ld	hl,BufferEnUp2+16
.CleanEnUp2_1:
	ld	(hl),a
	inc	hl
	djnz	.CleanEnUp2_1


	xor	a
	ld	b,8
	ld	hl,BufferEnUp2+40
.CleanEnUp2_2:
	ld	(hl),a
	inc	hl
	djnz	.CleanEnUp2_2


	ld	hl,BufferEnDw1+15
	ld	de,BufferEnDw1+23
	ld	bc,16
	lddr

	ld	hl,BufferEnDw1+39
	ld	de,BufferEnDw1+47
	ld	bc,16
	lddr

	xor	a
	ld	b,8
	ld	hl,BufferEnDw1
.CleanEnDw1_1:
	ld	(hl),a
	inc	hl
	djnz	.CleanEnDw1_1

	xor	a
	ld	b,8
	ld	hl,BufferEnDw1+24
.CleanEnDw1_2:
	ld	(hl),a
	inc	hl
	djnz	.CleanEnDw1_2

	ld	hl,BufferEnDw2+15
	ld	de,BufferEnDw2+23
	ld	bc,16
	lddr

	ld	hl,BufferEnDw2+39
	ld	de,BufferEnDw2+47
	ld	bc,16
	lddr

	xor	a
	ld	b,8
	ld	hl,BufferEnDw2
.CleanEnDw2_1:
	ld	(hl),a
	inc	hl
	djnz	.CleanEnDw2_1

	xor	a
	ld	b,8
	ld	hl,BufferEnDw2+24
.CleanEnDw2_2:
	ld	(hl),a
	inc	hl
	djnz	.CleanEnDw2_2
	ret










initFPointer:
	ld	hl,.fvec
	ld	a,(NumLevel)
	add	a,a
	add	a,a
	add	a,a
	ld	e,a
	ld	d,0
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(redchar_right1),de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(redchar_right2),de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(redchar_left1),de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(redchar_left2),de
	ret





.flevel1_null:
	ret


.flevel1_right3:
	ld	hl,bufferEnUp1
	ld	de,bufferEnUp2
	ld	bc,ENEMYSIZE
	ldir
	ret



.flevel1_left3:
	ld	hl,bufferEnDw2
	ld	de,bufferEnDw1
	ld	bc,ENEMYSIZE
	ldir
	ret


.flevel1_right1:
	ld	ix,bufferEnUp1
	ld	b,8


.fl_right1_1:
	or 	a
	rr	(ix+0)
	rr	(ix+8)
	rr	(ix+16)
	or 	a
	rr	(ix+24)
	rr	(ix+32)
	rr	(ix+40)
	inc 	ix
	djnz 	.fl_right1_1
	ret





.flevel1_right2:
	ld	ix,bufferEnUp2
	ld	b,8


.fl_right2_1:
	or 	a
	rr	(ix+0)
	rr	(ix+8)
	rr	(ix+16)
	or 	a
	rr	(ix+24)
	rr	(ix+32)
	rr	(ix+40)
	inc 	ix
	djnz 	.fl_right2_1
	ret





.flevel1_left1:
	ld	ix,bufferEnDw1
	ld	b,8


.fl_left1_1:
	or 	a
	rl	(ix+16)
	rl	(ix+8)
	rl	(ix+0)
	or 	a
	rl	(ix+40)
	rl	(ix+32)
	rl	(ix+24)
	inc 	ix
	djnz 	.fl_left1_1
	ret




.flevel1_left2:
	ld	ix,bufferEnDw2
	ld	b,8


.fl_left2_1:
	or 	a
	rl	(ix+16)
	rl	(ix+8)
	rl	(ix+0)
	or 	a
	rl	(ix+40)
	rl	(ix+32)
	rl	(ix+24)
	inc 	ix
	djnz 	.fl_left2_1
	ret







.fvec:		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2

		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2

		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2

		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2

		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2

		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2

		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2


		dw	.flevel1_right1
		dw      .flevel1_right3
		dw	.flevel1_left2
		dw	.flevel1_left3


		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2

		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2


		dw	.flevel1_right1
		dw      .flevel1_right2
		dw	.flevel1_left1
		dw	.flevel1_left2




PointerCall:	jp	(hl)





multhlde:
	ld      a,16
        ld      c,l
        ld      b,h
        ld      hl,0
multhldel:
	bit     0,e
        jr      z,multhldena
        add     hl,bc
multhldena:
	sla     c
        rl      b
        rr      d
        rr      e
        dec     a
        jr      nz,multhldel
        ret




section rdata

redchar_right1:	rb	2
redchar_right2:	rb	2
redchar_left1:	rb	2
redchar_left2:	rb	2


bufferPtrUp1:	rb	2
bufferPtrUp2:	rb	2
bufferPtrDw1:	rb	2
bufferPtrDw2:	rb	2


bufferEnUp1:	rb	ENEMYSIZE
bufferEnUp2:	rb	ENEMYSIZE
bufferEnDw1:	rb	ENEMYSIZE
bufferEnDw2:	rb	ENEMYSIZE


BufferColor1:	rb	16
BufferColor2:	rb	16
BuffColorPtr1:	rw	1
BuffColorPtr2:	rw	1




swapEnemyF:	rb	1
renderEnemyF:	rb	1
contPoint:	rb	1
contframeEnemy:	rb	1
NumEnemy:	rb	1
speedEnemy:	rb	1
animationEnemy:	rb	1
frameEnemy:	rb	1
stateEnemy:	rb	NUMENEMIES
coordEnemy:	rb	NUMENEMIES*2
pointCont:	rb	1
contSpeed:	rb	1
UpdateCont:	rb	1
section code
