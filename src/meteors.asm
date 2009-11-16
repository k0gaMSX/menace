METEOR_PROB:	equ     5*255/100

METEOR_PAT1:	equ 	127
METEOR_PAT2:	equ	126
METEOR_PAT3:	equ	125

METEOR2_PAT1:	equ 	127+32
METEOR2_PAT2:	equ	126+32
METEOR2_PAT3:	equ	125+32

	
METEOR_SIZE:	equ	3*8
METEOR_VSIZE:	equ	2*8
	
METEOR_PATOFF1:	equ	(32*4)-2
METEOR_PATOFF2:	equ	(32*5)-2

METEOR_COLOFF:	equ	METEOR_PATOFF1*8
METEOR_COLOFF2:	equ	METEOR_PATOFF2*8	
		
METEOR_VOFF1:	equ 	((32*4)-3)*8
METEOR_VOFF2:	equ 	((32*5)-3)*8

	

	

InitMeteors:
	ld	hl,0d431h
	ld	(RandomSeed),hl
	ld 	a,4
	ld	(MeteorFrame),a

	xor	a
	ld	hl,MeteorBufferR
	ld	(hl),a
	ld	de,MeteorBufferR+1
	ld	bc,METEOR_SIZE*2-1
 	ldir			


	ld	hl,METEOR_PATOFF1*8
	ld	de,MeteorBufferRt
	ld	bc,METEOR_VSIZE
	call	LDIRMV


	ld	hl,METEOR_PATOFF2*8
	ld	de,MeteorBufferLt
	ld	bc,METEOR_VSIZE
	call	LDIRMV




	ld	hl,scrcol+METEOR_COLOFF
	ld	de,2800h+METEOR_VOFF1
	ld	bc,8
	call	LDIRVM

 	ld	hl,scrcol+METEOR_COLOFF
	ld	de,2800h+METEOR_VOFF1+8
	ld	bc,8
	call	LDIRVM

 	ld	hl,scrcol+METEOR_COLOFF
	ld	de,2800h+METEOR_VOFF1+16
	ld	bc,8
	call	LDIRVM
	

	ld	hl,scrcol+METEOR_COLOFF2
	ld	de,2800h+METEOR_VOFF2
	ld	bc,8
	call	LDIRVM

 	ld	hl,scrcol+METEOR_COLOFF2
	ld	de,2800h+METEOR_VOFF2+8
	ld	bc,8
	call	LDIRVM

 	ld	hl,scrcol+METEOR_COLOFF2
	ld	de,2800h+METEOR_VOFF2+16
	ld	bc,8
	call	LDIRVM
	ret






	
	

	
meteor_col:
	call	TestRocketCol
 	or	a
	ret	z

	call	pjexp
	call	toBoom
	call	Death
	ret
	


	

doMeteors:
	call	moveMeteors
	call	renderMeteors
	ret	




	


moveMeteors:
	ld	a,(MeteorFrame)
	inc	a
	bit 	3,a
	ld	(MeteorFrame),a
	ret 	z
	
	xor	a
	ld	(MeteorFrame),a


	ld 	hl,PatternMap+32*9+1
	ld	de,PatternMap+32*9+0
	ld	bc,31
	ldir
 	ld	(PatternMap+32*9+31),a		
	
	
	ld 	hl,PatternMap+32*10+30
	ld	de,PatternMap+32*10+31
	ld	bc,31
	lddr
	ld	(PatternMap+32*10),a


	ld 	hl,PatternMap+32*11+1
	ld	de,PatternMap+32*11+0
	ld	bc,31
	ldir
 	ld	(PatternMap+32*11+31),a	

	
	ld 	hl,PatternMap+32*12+30
	ld	de,PatternMap+32*12+31
	ld	bc,31
	lddr
	ld	(PatternMap+32*12),a	


	ld	hl,PatternMap+32*9+29
	ld	a,(hl)
	inc	hl
	or	(hl)
	inc	hl
	or	(hl)
	call	z,newMeteor2
	
	
	ld	hl,PatternMap+32*10
	ld	a,(hl)
	inc	hl
	or	(hl)
	inc	hl
	or	(hl)
	call	z,newMeteor


	ld	hl,PatternMap+32*11+29
	ld	a,(hl)
	inc	hl
	or	(hl)
	inc	hl
	or	(hl)
	call	z,newMeteor2

	
	ld	hl,PatternMap+32*12
	ld	a,(hl)
	inc	hl
	or	(hl)
	inc	hl
	or	(hl)
	call	z,newMeteor

	
	ret







	
	
	
newMeteor:
	call	Rand
	cp	METEOR_PROB
	ret	nc

	ld	(hl),METEOR_PAT1
	dec	hl
	ld	(hl),METEOR_PAT2
	dec	hl
	ld	(hl),METEOR_PAT3
	inc	hl
	inc	hl
	ret



newMeteor2:
	call	Rand
	cp	METEOR_PROB
	ret	nc

	ld	(hl),METEOR2_PAT1
	dec	hl
	ld	(hl),METEOR2_PAT2
	dec	hl
	ld	(hl),METEOR2_PAT3
	inc	hl
	inc	hl
	ret
	




	


renderMeteors:
	di
	ld	a,(MeteorFrame)	
	or	a
	jr	z,.restore


	ld	ix,MeteorBufferR
	ld	b,8		
.right:
	or 	a
	rr	(ix+0)
	rr	(ix+8)
	rr	(ix+16)
	inc 	ix
	djnz 	.right

	
	ld	ix,MeteorBufferL
	ld	b,8		
.left:
	or 	a
	rl	(ix+16)
	rl	(ix+8)
	rl	(ix+0)
	inc 	ix
	djnz 	.left
	ei
	ret



.restore:
	xor	a
	ld	hl,MeteorBufferR
	ld	(hl),a
	ld	de,MeteorBufferR+1
	ld	bc,METEOR_SIZE*2-1
 	ldir			
	

	ld	hl,MeteorBufferRt
	ld	de,MeteorBufferR
	ld	bc,METEOR_VSIZE
	ldir


	ld	hl,MeteorBufferLt
	ld	de,MeteorBufferL+8
	ld	bc,METEOR_VSIZE
	ldir
	ei
	ret

	

	


Rand:
	push	hl	
        ld      hl,(RandomSeed)        
        dec     hl                     
	ld	d,l
	dec	l
	ld	a,h
	add	a,l
	ld	e,a
	sbc	hl,de
        ld      (RandomSeed),hl      
	ld	a,r
	sub	l
	pop	hl
	ret




section rdata

RandomSeed:	rb	2
MeteorFrame:	rb	1

MeteorBufferR:	rb	METEOR_SIZE
MeteorBufferL:	rb	METEOR_SIZE

MeteorBufferRt:	rb 	METEOR_SIZE
MeteorBufferLt:	rb	METEOR_SIZE
section code	
	
	
