


	
NUMENEMIES:	equ	4
NUMROWS:	equ	2	
ENEMYPATW:	equ	2
ENEMYPATH:	equ	2	
ENEMYSIZE:	equ     ENEMYPATW*ENEMYPATH*8
ENEMYBUF:	equ	(ENEMYPATW+1)*ENEMYPATH*8	
ENEMYLEVELSIZE:	equ     ENEMYSIZE*2
		

	

InitEnemy:	
	ld	a,(NumLevel)
	ld	l,a
	ld	h,0
	ld	de,ENEMYLEVELSIZE
	call	multhlde
	ld	de,enemybin
	add	hl,de
	ret







	



	
multhlde:       ld      a,16
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

bufferEn1:	rb	ENEMYSIZE
bufferEn2:	rb	ENEMYSIZE
	
section code		