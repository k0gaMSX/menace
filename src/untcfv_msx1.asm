; decompresses to VRAM
; in: hl = source
;     de = destination
; changes: af,af',bc,de,hl,ix


UnTCFV::
	ld	ix,-1		; last_m_off
	ld	a,[VDP.DW]
	inc	a
	ld	c,a


	ld	a,d
	or	01000000b
	di
	out	[c],e		; set destination VRAM address
	ei
	out	[c],a
	dec	c


	ld	a,[hl]		; read first byte
	inc	hl
	rlca


.litlp:	outi
	inc	de


.loop:	call	GetBit
	jp	c,.litlp
.endlit:


	push	de		; save dst
	ld	de,1
.moff:	call	GetBit
	rl	e
	rl	d
	call	GetBit
	jr	c,.gotmoff
	dec	de
	call	GetBit
	rl	e
	rl	d
	jp	nc,.moff
	pop	de		; end of compression
	ret


.gotmoff:
	ex	af,af'
	ld	bc,0		; m_len
	dec	de
	dec	de
	ld	a,e
	or	d
	jr	z,.prevdist
	dec	de
	ld	a,e
	cpl
	srl	d
	ccf
	ld	d,a
	ld	e,[hl]
	inc	hl
	rr	d
	rr	e
	ld	ixl,e
	ld	ixh,d
	jr	c,.mlena
	ex	af,af'
	inc	bc
	call	GetBit
	jr	c,.mlenx


.mlen:	call	GetBit
	rl	c
	rl	b
	call	GetBit
	jp	nc,.mlen
	inc	bc
	inc	bc
.gotmlen:
	ex	af,af'
	ld	a,d
	cp	-5
	jp	nc,.nc
	inc	bc
.nc:	inc	bc
	inc	bc


	ex	[sp],hl		; save src, and	get dst	in hl, de = offset
	ex	de,hl		; de = dst, hl = offset
	add	hl,de		; new src = dst+offset


	push	hl
	inc	hl
	sbc	hl,de
	pop	hl
	jp	z,.unbuffer


.matchlp:
	push	bc
	ld	bc,[VDP.DR]
	ld	a,b
	inc	a
	ld	b,c
	ld	c,a


	di
	out	[c],l
	ei
	out	[c],h
	ld	c,b
	in	b,[c]		      ;	read byte
	ld	c,a


	ld	a,d
	or	01000000b
	di
	out	[c],e
	ei
	out	[c],a
	inc	de
	dec	c
	out	[c],b		      ;	write byte


	pop	bc
	cpi
	jp	pe,.matchlp


	ld	a,[VDP.DW]
	ld	c,a
	ex	af,af'
	pop	hl			; get src back
	jp	.loop


.prevdist:
	ex	af,af'
	ld	e,ixl
	ld	d,ixh
	call	GetBit
	jr	c,.mlenx
	inc	bc
	call	GetBit
	jr	nc,.mlen
	ex	af,af'


.mlena:	ex	af,af'
.mlenx:	call	GetBit
	rl	c
	jp	.gotmlen


.unbuffer:
	push	bc
	ld	bc,[VDP.DR]
	ld	a,b
	inc	a
	ld	b,c
	ld	c,a


	di
	out	[c],l
	ei
	out	[c],h
	ld	c,b
	in	b,[c]		      ;	read byte
	ld	c,a


	ld	a,d
	or	01000000b
	di
	out	[c],e
	ei
	out	[c],a
	pop	hl


	ex	de,hl
	add	hl,de
	ex	de,hl


	dec	c
.bufmatch:
	out	[c],b			; write	byte
	dec	hl
	ld	a,l
	or	h
	jp	nz,.bufmatch


	ex	af,af'
	pop	hl			; get src back
	jp	.loop


GetBit:	add	a,a
	ret	nz
	ld	a,[hl]		; read new byte
	inc	hl
	adc	a,a		; cf = 1, last bit shifted is always 1
	ret
