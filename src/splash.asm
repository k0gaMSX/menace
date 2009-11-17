introdemo:	ld	ix,.script
		ld	b,3
.loop:		push	bc

		call	DISSCR
		di
		ld	a,$c9
		ld	($fd9a),a
		ei

		call	showdemo

		di
		ld	a,$c3
		ld	hl,mainIntro
		ld	($fd9a),a
		ld	($fd9b),hl
		ei
		call	ENASCR

		ld	c,1
		call	showtext
		jr	nz,.skip

		ld	b,160
.wait:		push	bc
		xor	a
		call	GTTRIG
		jr	nz,.fire
		ld	a,1
		call	GTTRIG
.fire:		pop	bc
		jr	nz,.skip
		halt
		halt
		djnz	.wait
		pop	bc
		djnz	.loop
		ret

.skip:		pop	bc
		call	initsound
		ret

.script:	dw	splash.intro01.pat,splash.intro01.col,$1a41,.text.1
		dw	splash.intro02.pat,splash.intro02.col,$1a41,.text.2
		dw	splash.intro03.pat,splash.intro03.col,$1a41,.text.3

.text.1:	db	$2e,$34,$31,$47,$32,$20,$33,$24,$2b,$2b,$28,$33,$24,$32,$47,$31,$24,$2f,$2e,$31,$33,$47,$33,$27,$20,$33,$47,$2e,$34,$31,-2
		db	$22,$2e,$2b,$2e,$2d,$38,$47,$2e,$2d,$47,$2c,$20,$31,$32,$47,$36,$20,$32,$47,$20,$33,$33,$20,$22,$2a,$24,$23,$47,$21,$38,-2
		db	$20,$2d,$47,$34,$2d,$2a,$2d,$2e,$36,$2d,$47,$25,$2e,$31,$22,$24,$44,-1

.text.2:	db	$33,$27,$24,$47,$23,$24,$25,$24,$2d,$32,$24,$47,$32,$38,$32,$33,$24,$2c,$32,$47,$20,$31,$24,$47,$31,$24,$20,$23,$38,$45,-2
		db	$33,$27,$24,$38,$47,$20,$31,$24,$47,$2b,$2e,$22,$20,$33,$24,$23,$47,$2e,$2d,$47,$32,$33,$31,$20,$33,$24,$26,$28,$22,-2
		db	$2b,$2e,$22,$20,$33,$28,$2e,$2d,$32,$47,$20,$31,$2e,$34,$2d,$23,$47,$33,$27,$24,$47,$36,$2e,$31,$2b,$23,$44,-1

.text.3:	db	$27,$2e,$32,$33,$28,$2b,$24,$47,$20,$2b,$28,$24,$2d,$32,$47,$21,$24,$26,$28,$2d,$47,$33,$27,$24,-2
		db	$28,$2d,$35,$20,$32,$28,$2e,$2d,$45,$47,$33,$27,$24,$47,$26,$2e,$35,$24,$31,$2d,$2c,$24,$2d,$33,$47,$26,$28,$35,$24,-2
		db	$38,$2e,$34,$47,$33,$27,$24,$47,$21,$24,$32,$33,$47,$36,$24,$20,$2f,$2e,$2d,$47,$33,$27,$24,$38,$47,$27,$20,$35,$24,$44,-1
;
enddemo:	ld	ix,.script
		ld	b,2
.loop:		push	bc

		call	DISSCR
		di
		ld	a,$c9
		ld	($fd9a),a
		ei

		pop	bc
		ld	a,b
		push	bc
		dec	a
		jr	nz,.first

		ld	de,pattern+$e0*8
		ld	hl,splash.end02.pat
		call	UnTCFV
		ld	de,color+$e0*8
		ld	hl,splash.end02.col
		call	UnTCFV
		jr	.second

.first:		call	showdemo
		ld	bc,8		; change "." into "!" for the ending
		ld	de,$1000 +8* $44
		ld	hl,font.exclamation
		call	LDIRVM

.second:	di
		ld	a,$c3
		ld	hl,mainIntro
		ld	($fd9a),a
		ld	($fd9b),hl
		ei
		call	ENASCR

		pop	bc
		ld	a,b
		push	bc
		dec	a
		ld	c,0
		call	nz,showtext

		ld	b,0
.wait:		halt
		halt
		djnz	.wait

.skip:		pop	bc
		djnz	.loop
		ret


.script:	dw	splash.end01.pat,splash.end01.col,$1a25,.text

.text:		db	$22,$2e,$2d,$26,$31,$20,$33,$34,$2b,$20,$33,$28,$2e,$2d,$32,$44,$44,$44,-2
		db	$38,$2e,$34,$47,$32,$20,$35,$24,$23,$47,$33,$27,$24,$47,$36,$2e,$31,$2b,$23,$44,$44,$44,-2,-2
		db	$33,$27,$20,$2d,$2a,$32,$47,$25,$2e,$31,$47,$2f,$2b,$20,$38,$28,$2d,$26,$44,-1
;
showdemo:	ld	l,(ix+0)
		ld	h,(ix+1)
		ld	e,(ix+2)
		ld	d,(ix+3)
		push	ix
		call	splashscreen
		call	demofont
		pop	ix
		ret

showtext:	ld	l,(ix+4)
		ld	h,(ix+5)
		ld	e,(ix+6)
		ld	d,(ix+7)
		push	bc
		call	.print
		ld	bc,8
		add	ix,bc
		pop	bc
		ret

.print:		push	hl
.loop:          ld	a,(de)
		cp	-1
		jr	z,.end
		inc	de
		cp	-2
		jr	z,.crlf
		call	WRTVRM
		set	2,h
		call	WRTVRM
		res	2,h
                cp      47h
                push	bc
                call    nz,letter_sfx
                pop	bc

		ld	b,5
.wait:		inc	c
		dec	c
		jr	z,.skipinput
		push	bc
		xor	a
		call	GTTRIG
		jr	nz,.fire
		ld	a,1
		call	GTTRIG
.fire:		pop	bc
		jr	nz,.end
.skipinput:     halt
                halt
		djnz	.wait

		inc	hl
		jr	.loop

.crlf:		pop	hl
		push	bc
		ld	bc,64
		add	hl,bc
		pop	bc
		jr	.print

.end:		pop	hl
		ret

demofont:	ld	de,16*8		; starting from $47
		ld	hl,font.pat
		push	hl
		;push	hl
		call	UnTCFV
		;pop	hl
		;ld	de,$800+32*8
		;call	UnTCFV
		pop	hl
		ld	de,$1000+32*8
		call	UnTCFV

		ld	de,$2000+16*8
		ld	hl,font.col
		push	hl
		;push	hl
		call	UnTCFV
		;pop	hl
		;ld	de,$2800+32*8
		;call	UnTCFV
		pop	hl
		ld	de,$3000+32*8
		call	UnTCFV
		ret
;
;
;
pattern:	equ	$0000
color:		equ	$2000
name1:		equ	$1800
name2:		equ	$1c00
;
; In:	DE = pointer to color table
;	HL = pointer to pattern table
;
splashscreen:	push	de
		push	hl

		xor	a		; background char for pattern sets 1 and 3
		ld	bc,768
		ld	hl,name1
		call	FILVRM

		xor	a
		ld	bc,768
		ld	hl,name2
		call	FILVRM

		ld	a,$ff		; background char for pattern set 2
		ld	bc,256
		ld	hl,name1+256
		call	FILVRM

		ld	a,$ff
		ld	bc,256
		ld	hl,name2+256
		call	FILVRM

		xor	a		; clear pattern tables
		ld	bc,$1800
		ld	hl,pattern
		call	FILVRM

		xor	a		; clear color tables
		ld	bc,$1800
		ld	hl,color
		call	FILVRM

		ld	de,pattern+$e0*8
		pop	hl
		call	UnTCFV
		ld	de,color+$e0*8
		pop	hl
		call	UnTCFV


		ld	bc,8 *256+ $e0	; $e0-$ff, $00-$df
		ld	de,name2 +232
		ld	hl,name1 +232
.line:		push	bc
		ld	b,16
.char:		ld	a,c
		call	WRTVRM
		inc	hl
		xor	$10
		ex	de,hl
		call	WRTVRM
		ex	de,hl
		inc	de
		inc	c
		djnz	.char
		ld	a,c
		add	a,16
		ld	bc,16
		add	hl,bc
		ex	de,hl
		add	hl,bc
		ex	de,hl
		pop	bc
		ld	c,a
		djnz	.line
		ret
