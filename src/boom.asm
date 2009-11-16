
BOOM_COLOR0:	equ	15
BOOM_COLOR1:	equ	11
BOOM_COLOR2:	equ	8



TestBoom:
	ld	a,(boom)
	or	a
	ret
	
	
Boom1: 
	ld	a,(boomx)
	add	a,4
	ld	(spratt+SPRBOOM1*4+1),a
	ld	a,(boomy)
	add	a,4
	ld	(spratt+SPRBOOM1*4+0),a	
	ld	a,14
	ld	(spratt+SPRBOOM1*4+2),a
	ld	a,BOOM_COLOR0
	ld	(spratt+SPRBOOM1*4+3),a 
	ret

	
Boom2:
	ld	a,(boomx)
	add	a,4
	ld	(spratt+SPRBOOM1*4+1),a
	ld	a,(boomy)
	add	a,4
	ld	(spratt+SPRBOOM1*4+0),a	
	ld	a,15
	ld	(spratt+SPRBOOM1*4+2),a
	ld	a,BOOM_COLOR0
	ld	(spratt+SPRBOOM1*4+3),a	
	ret
	

	
Boom3:
	ld	a,(boomx)
	ld	(spratt+SPRBOOM1*4+1),a
 	ld	(spratt+SPRBOOM3*4+1),a	
 	ld	(spratt+SPRBOOM5*4+1),a
 	ld	(spratt+SPRBOOM7*4+1),a	
	add	a,8
	ld	(spratt+SPRBOOM2*4+1),a
 	ld	(spratt+SPRBOOM4*4+1),a	
 	ld	(spratt+SPRBOOM6*4+1),a
 	ld	(spratt+SPRBOOM8*4+1),a	

	ld	a,(boomy)
	ld	(spratt+SPRBOOM1*4+0),a
	ld	(spratt+SPRBOOM2*4+0),a
	
 	ld	(spratt+SPRBOOM5*4+0),a
 	ld	(spratt+SPRBOOM6*4+0),a	
	add	a,8
 	ld	(spratt+SPRBOOM3*4+0),a
 	ld	(spratt+SPRBOOM4*4+0),a
 	ld	(spratt+SPRBOOM7*4+0),a		
 	ld	(spratt+SPRBOOM8*4+0),a	

	ld	a,16
	ld	(spratt+SPRBOOM1*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM2*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM3*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM4*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM5*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM6*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM7*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM8*4+2),a		

	ld	a,BOOM_COLOR1			;;TODO: Put correct color
	ld	(spratt+SPRBOOM1*4+3),a
	ld	(spratt+SPRBOOM2*4+3),a	
	ld	(spratt+SPRBOOM3*4+3),a
	ld	(spratt+SPRBOOM4*4+3),a	

	ld	a,BOOM_COLOR2                     ;;TODO: Put correct color
	ld	(spratt+SPRBOOM5*4+3),a 
	ld	(spratt+SPRBOOM6*4+3),a	
	ld	(spratt+SPRBOOM7*4+3),a
	ld	(spratt+SPRBOOM8*4+3),a	
	ret
	


	
	
Boom4:
	ld	a,24
	ld	(spratt+SPRBOOM1*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM2*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM3*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM4*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM5*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM6*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM7*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM8*4+2),a		
	ret

	
Boom5:
	ld	a,32
	ld	(spratt+SPRBOOM1*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM2*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM3*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM4*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM5*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM6*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM7*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM8*4+2),a		
	ret

	
Boom6:
	ld	a,40
	ld	(spratt+SPRBOOM1*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM2*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM3*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM4*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM5*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM6*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM7*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM8*4+2),a		
	ret


	
Boom7:
	ld	a,48
	ld	(spratt+SPRBOOM1*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM2*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM3*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM4*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM5*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM6*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM7*4+2),a		
	inc	a
	ld	(spratt+SPRBOOM8*4+2),a		
	ret


CleanBoom:	
Boom8:
	ld	a,230
	ld	(spratt+SPRBOOM1*4+0),a
	ld	(spratt+SPRBOOM2*4+0),a	
	ld	(spratt+SPRBOOM3*4+0),a
	ld	(spratt+SPRBOOM4*4+0),a		
	ld	(spratt+SPRBOOM5*4+0),a
	ld	(spratt+SPRBOOM6*4+0),a	
	ld	(spratt+SPRBOOM7*4+0),a	
	ld	(spratt+SPRBOOM8*4+0),a		
	ret
	

	
	
toBoom:
	ld	a,1
	ld	(boom),a
	xor	a
	ld	(frameBoom),a
	ld	a,(rocketx)
	ld	(boomx),a		
	ld	a,(rockety)	
	ld	(boomy),a
	ret
	

renderBoom:	
	ld	a,(boom)
	or	a
	ret	z

	
	ld	hl,frameBoom
	inc	(hl)
	ld	a,(hl)

	cp	1
	jr	nz,.2
	call	Boom1
	ret

.2:	cp	5
	jr	nz,.3	
	call	Boom2
	ret
	
.3:	cp	10
	jr	nz,.4
	call	Boom3
	ret
	
	
.4:	cp	15
	jr	nz,.5
	call	Boom4
	ret

.5:	cp	20
	jr	nz,.6
	call	Boom5
	ret
	
	
.6:	cp	25
	jr	nz,.7	
	call	Boom6
	ret
	

.7:	cp	30
	jr	nz,.8
	call	Boom7
	ret

.8:	cp	35
	ret	nz
	call	Boom8
	xor	a
	ld	(Boom),a
	ret



section rdata
	
boom:		rb	1
frameBoom:	rb	1
boomx:		rb	1
boomy:		rb	1	
	
section code	
