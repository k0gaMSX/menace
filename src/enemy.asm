NUMENEMIES:	equ	8
NUMROWS:	equ	2	
ENEMYPATW:	equ	2
ENEMYPATH:	equ	2	
ENEMYSIZE:	equ     (ENEMYPATW+1)*ENEMYPATH*8
ENEMYLEVELSIZE:	equ     ENEMYPATW*ENEMYPATH*8*2
		
ENEMYVOFF:	equ	96*8	
ENEMY3SPEED:	equ	20
ENEMY2SPEED:	equ	20	
ENEMY1SPEED:	equ	20
FRAMETIME:	equ	10



	;; Falta por añadir el volcado de los graficos de los
	;; jugadores ya que ahora mismo no se a donde van y por eso
	;; esta comentado el volcado en el fichero levels.asm. Tambien
	;; esta comentado el tema en este fichero donde todas las
	;; rutinas de renderizacion estan incompletas (mirar linea 298)
	;; Y donde estoy escribiendo el numero de patron???
	
	
	

InitEnemy:
	ld	a,NUMENEMIES
	ld	(NumEnemy),a

	ld	a,(NumLevel)
	ld	de,.LevelData
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,de
	ld	a,(hl)
	ld	(speedEnemy),a
	inc	hl
	ld	a,(hl)
	ld	(probFire),a

	
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
		
	xor	a
	ld	(contPoint),a
	ld	(pointCont),a
	ld	(contSpeed),a
	ld	hl,stateEnemy
	ld	b,8
.3:	ld	(hl),a
	djnz	.3
	
	ld	(frameEnemy),a
	ld	(contframeEnemy),a
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
	
;;; TODO: PaintAllEnemy!
	ret


.LevelData:
	db	5,5
	db	5,5
	db	5,5
	db	5,5
	db	5,5
	db	5,5
	db	5,5
	db	5,5
	db	5,5
	db	5,5
	

	

	

.initAtt:
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
	ret

	

.initColour:		
	ld	de,2000h+ENEMYVOFF	
	ld	bc,8
	call	LDIRVM
	ld	hl,(.colour)
	ld	de,2000h+ENEMYVOFF+8	
	ld	bc,8
	call	LDIRVM
	ld	hl,(.colour)
	ld	de,2000h+ENEMYVOFF+16	
	ld	bc,8
	call	LDIRVM


	ld	hl,(.colour)
	ld	de,16
	add	hl,de
	push	hl
	push	hl
	ld	de,2000h+ENEMYVOFF+24	
	ld	bc,8
	call	LDIRVM
	pop	hl
	ld	de,2000h+ENEMYVOFF+32
	ld	bc,8
	call	LDIRVM
	pop 	hl
	ld	hl,(.colour)
	ld	de,2000h+ENEMYVOFF+40	
	ld	bc,8
	call	LDIRVM		; Here is initializiled colour table
	
	ld	hl,(.colour)
	ld	de,32
	add	hl,de
	push	hl
	push	hl
	
	ld	de,2000h+ENEMYVOFF+48	
	ld	bc,8
	call	LDIRVM
	pop	hl
	ld	de,2000h+ENEMYVOFF+56
	ld	bc,8
	call	LDIRVM
	pop	hl
	ld	de,2000h+ENEMYVOFF+64	
	ld	bc,8
	call	LDIRVM

	ld	hl,(.colour)
	ld	de,48
	add	hl,de
	push	hl
	push	hl
	ld	de,2000h+ENEMYVOFF+72	
	ld	bc,8
	call	LDIRVM
	pop	hl
	ld	de,2000h+ENEMYVOFF+80
	ld	bc,8
	call	LDIRVM
	pop 	hl
	ld	hl,(.colour)
	ld	de,2000h+ENEMYVOFF+88	
	ld	bc,8
	call	LDIRVM		; Here is initializiled colour table			
	ret



	
		
section rdata
.colour:	rw	1
section code		

;;; TODO: Insert polimorph function for paint All Enemy!!!!!




paintAllEnemy:
	ld	b,2
	ld	hl,PatternMap+100 ;PatternMap+96 is initial position

.paintAllEne1:
	push	bc
	ld	a,(NumEnemy)		;Paint Enemies
	rr	a
	rr	a
	ld	b,a
	
.paintAllEne2:	
	call	paintEnemy1
	call	paintEnemy2
	djnz	.paintAllEne2
	ld	de,64
	add	hl,de		
	pop	bc
	djnz	.paintAllEne1
	ret

	
	
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
	ret



	

	
moveEnemy:	call	.checkPoint
		ret	nz
		call	.setSpeed
;;; HERE WE MUST CHEK FIRE !!!!!!!!!!!!
		ret
		

	

	
.setSpeed:			
	ld	a,(NumEnemy)
	cp	3
	jr	nz,.sp1
	ld	a,ENEMY3SPEED
	jr	.sp3
	
.sp1:	cp	2
	jr	nz,.sp2
	ld	a,ENEMY3SPEED		
	jr	.sp3
	
.sp2:	cp	1
	jr	nz,.sp4
	ld	a,ENEMY3SPEED
.sp3:	ld	(speedEnemy),a

.sp4:		
	ret			

		
	
	
	
		
.checkPoint:	xor	a
		ld	hl,contPoint
		cp	(hl)
		ret	z
		dec	(hl)
		jr	nz,.cp1

;;; HERE WE HAVE TO CLEAN THE POINT SHOWED IN THE SCREEN
	
.cp1:		inc	a
		ret
	
	
	
		

renderEnemy:	
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
	ret
	


UpdateChars:	
	ld	hl,(redchar_right1)
	call	PointerCall
	ld	hl,(redchar_right2)
	call	PointerCall
	ld	hl,(redchar_left1)
	call	PointerCall	
	ld	hl,(redchar_left2)
	call	PointerCall
	ret	

	




initFPointer:	
	ld	hl,.flevel1_right1
	ld	(redchar_right1),hl
	ld	(redchar_right2),hl
	ld	(redchar_left1),hl
	ld	(redchar_left2),hl	
	ret

	
		
		
.flevel1_right1:
	ei
;; 	halt
;; 	halt
;; 	halt
;; 	halt
;; 	halt
;; 	halt
;; 	halt
;; 	halt
;; 	halt
;; 	halt
	
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
	
	
		
	
		ret
		
.flevel1_right2:
		ret
	
.flevel1_left1:
		ret
	
.flevel1_left2:
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


	
bufferEnUp1:	rb	ENEMYSIZE
bufferEnUp2:	rb	ENEMYSIZE
bufferEnDw1:	rb	ENEMYSIZE
bufferEnDw2:	rb	ENEMYSIZE

contPoint:	rb	1	
contframeEnemy:	rb	1	
NumEnemy:	rb	1
speedEnemy:	rb	1	
probFire:	rb	1
frameEnemy:	rb	1
stateEnemy:	rb	NUMENEMIES	
coordEnemy:	rb	NUMENEMIES*2
pointCont:	rb	1
contSpeed:	rb	1		
section code		
