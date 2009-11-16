



initIntro:
		ld	hl,0
		ld	(BAKCLR),hl
		xor	a
		ld	(CLIKSW),a
		call	INIGRP
		call	DISSCR

		ld	hl,intro.palette
		call	setplt

		xor	a
		ld	bc,$4000
		ld	hl,0
		call	FILVRM

		ld	de,64*8		; starting from "@"
		ld	hl,intro.pat
		push	hl
		call	UnTCFV
		ld	de,$800+64*8
		pop	hl
		call	UnTCFV

		ld	de,$2000+64*8
		ld	hl,intro.col
		push	hl
		call	UnTCFV
		ld	de,$2800+64*8
		pop	hl
		call	UnTCFV

		ld	bc,6*32
		ld	de,$1880
		ld	hl,intro.even
		call	LDIRVM

		ld	bc,6*32
		ld	de,$1c80
		ld	hl,intro.odd
		call	LDIRVM



		di
		ld	a,$c3
		ld	hl,mainIntro
		ld	($fd9a),a
		ld	($fd9b),hl
		ei

		call	ENASCR
		ld	b,60*2
.wait:
		ei
		halt
		djnz	.wait

		ld	a,0c9h
		ld	(0fd9ah),a
		ret



;
mainIntro:
		call	RDVDP

		; $1800 = 0001 1000 0000 0000
		; $1C00 = 0001 1100 0000 0000

		ld	a,($f3e1)
		xor	1
		ld	b,a
		ld	c,2
		call	WRTVDP
		ret



;
setplt:
		ld	a,($2d)
		or	a
		ret	z
		ld	a,(7)
		inc	a
		ld	c,a
		xor	a
		di
		out	(c),a
		ld	a,128+16
		out	(c),a
		ei
		inc	c
		ld	b,32
		otir
		ret
;
; data
;




intro:
.palette:	dw	$000,$000,$612,$723,$227,$337,$262,$637
		dw	$271,$373,$562,$663,$512,$255,$666,$777


.pat:		incbin	"intro.pat.tcf",8
.col:		incbin	"intro.col.tcf",8
.even:		include	"intro0.asm"
.odd:		include "intro1.asm"


