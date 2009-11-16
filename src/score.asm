		
	
	
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
	djnz	.iscorel
	ret
	
.ihiscore:	db	0,0,8,0,0	



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


PrintScore:
	ld	hl,score
	ld	d,1
	ld	e,2
	call	.PrintBCD
	
	ld	hl,hiscore
	ld	d,1
	ld	e,13

.PrintBCD:
	ld	b,5
.pbcdl:	ld	a,(hl)
	call	.PrintDigit
	inc	hl
	djnz	.pbcdl	
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
	