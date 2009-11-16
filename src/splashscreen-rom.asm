		%include "z80r800.inc"
		%include "z80().inc"
		%include "tniasm.inc"

		fname	"splash.rom"

		org	$8000
;
;
;
		dw	"AB",start,0,0,0,0,0,0

start:		ld	hl,0
		ld	($f3ea),hl
		call	$72
		xor	a

.init:		ld	hl,table
		add	a,a
		add	a,a
		ld	e,a
		ld	d,0
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		inc	hl
		ld	a,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,a
		call	splashscreen

.loop:		halt
		ld	bc,2 +256* 7
		call	$47
		halt
		ld	bc,2 +256* 6
		call	$47
		call	$9c
		jr	z,.loop
		call	$9f
		sub	"0"
		jr	c,.loop
		cp	4
		jr	nc,.loop
		jr	.init
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
		call	$56

		xor	a
		ld	bc,768
		ld	hl,name2
		call	$56

		ld	a,$ff		; background char for pattern set 2
		ld	bc,256
		ld	hl,name1+256
		call	$56

		ld	a,$ff
		ld	bc,256
		ld	hl,name2+256
		call	$56

		xor	a		; clear pattern tables
		ld	bc,$1800
		ld	hl,pattern
		call	$56

		xor	a		; clear color tables
		ld	bc,$1800
		ld	hl,color
		call	$56

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
		call	$4d
		inc	hl
		xor	$10
		ex	de,hl
		call	$4d
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
;
;
;
		include	"untcfv_msx1.asm"
;
table:		dw	end01.col,end01.pat
		dw	intro01.col,intro01.pat
		dw	intro02.col,intro02.pat
		dw	intro03.col,intro03.pat
;
end01:
.pat:		incbin	"end01.pat.tcf",8
.col:		incbin	"end01.col.tcf",8
intro01:
.pat:		incbin	"intro01.pat.tcf",8
.col:		incbin	"intro01.col.tcf",8
intro02:
.pat:		incbin	"intro02.pat.tcf",8
.col:		incbin	"intro02.col.tcf",8
intro03:
.pat:		incbin	"intro03.pat.tcf",8
.col:		incbin	"intro03.col.tcf",8
;
		ds	$a000-$,$ff
