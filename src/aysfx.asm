		; --- ayFX REPLAYER ---

ayFX_SETUP:	ld	a,1				; Starting channel
		ld	(ayFX_CHANNEL),a		; Updated
		dec	a				; a:=0
		ld	(ayFX_PLAYING),a		; not playing ayfx stream
		dec	a				; a:=255
		ld	(ayFX_CURRENT),a		; lower ayfx stream
		ret					; Return

ayFX_INIT:	; ---     INIT A NEW ayFX STREAM     ---
		; --- INPUT: A -> sound to be played ---
		push	bc				; Store bc in stack
		push	de				; Store de in stack
		push	hl				; Store hl in stack
		ld	b,a				; b:=a (new ayFX stream)
		ld	a,(ayFX_CURRENT)		; a:=Current ayFX stream
		cp	b				; If new ayFX stream is higher than currently one...
		jp	c,.INIT_END			; ...we don't start the new ayFX stream
		; --- INITS ---
		ld	l,b				; l:=b (new ayFX stream index)
		ld	h,0				; hl:=b (new ayFX stream index)
		add	hl,hl				; hl:=hl*2
		ld	de,ayFX_STREAMS			; Pointer to the pointer list of the ayFX streams
		add	hl,de				; Pointer to the pointer of new ayFX stream to be played
		ld	e,(hl)				; e:=lower byte of new ayFX stream pointer
		inc	hl				; Increment pointer to the pointer
		ld	d,(hl)				; de:=pointer to the new ayFX stream
		ld	(ayFX_POINTER),de		; Pointer saved in RAM
		ld	a,b				; a:=b (new ayFX stream)
		ld	(ayFX_CURRENT),a		; new ayFX stream saved in RAM
		ld	a,255				; a:=255 (a non zero value)
		ld	(ayFX_PLAYING),a		; There's an ayFX stream to be played
.INIT_END:	pop	hl				; Retrieve hl from stack
		pop	de				; Retrieve de from stack
		pop	bc				; Retrieve bc from stack
		ret					; Return

ayFX_PLAY:	; --- PLAY A FRAME OF AN ayFX STREAM ---
		ld	a,(ayFX_PLAYING)		; There's an ayFX stream to be played?
		or	a				; If not...
		ret	z				; ...return
		; --- Extract control byte from stream ---
		ld	hl,(ayFX_POINTER)		; Pointer to the current ayFX stream
		ld	c,(hl)				; c:=Control byte
		inc	hl				; Increment pointer
		; --- Check if there's new tone on stream ---
		bit	5,c				; If bit 5 c is off...
		jp	z,.CHECK_NN			; ...jump to .CHECK_NN (no new tone)
		; --- Extract new tone from stream ---
		ld	e,(hl)				; e:=lower byte of new tone
		inc	hl				; Increment pointer
		ld	d,(hl)				; d:=higher byte of new tone
		inc	hl				; Increment pointer
		ld	(ayFX_TONE),de			; ayFX tone updated
.CHECK_NN:	; --- Check if there's new noise on stream ---
		bit	6,c				; if bit 6 c is off...
		jp	z,.SETPOINTER			; ...jump to .SETPOINTER (no new noise)
		; --- Extract new noise from stream ---
		ld	a,(hl)				; a:=New noise
		cp	$20				; If it's an illegal value of noise (used to mark end of stream)...
		jp	z,ayFX_END			; ...jump to ayFX_END
		ld	(ayFX_NOISE),a			; ayFX noise updated
.SETPOINTER:	; --- Update ayFX pointer ---
		ld	(ayFX_POINTER),hl		; Update ayFX stream pointer
		; --- Extract volume ---
		ld	a,c				; a:=Control byte
		and	$0F				; lower nibble
		ld	(ayFX_VOLUME),a			; ayFX volume updated
		; -------------------------------------
		; --- COPY ayFX VALUES IN TO AYREGS ---
		; -------------------------------------
		; --- Set noise channel ---
		bit	7,c				; If noise is off...
		jp	nz,.SETMASKS			; ...jump to .SETMASKS
		ld	a,(ayFX_NOISE)			; ayFX noise value
		ld	(AYREGS+6),a			; copied in to AYREGS (noise channel)
.SETMASKS:	; --- Set mixer masks ---
		ld	a,c				; a:=Control byte
		and	$90				; Only bits 7 and 4 (noise and tone mask for psg reg 7)
		cp	$90				; If no noise and no tone...
		ret	z				; ...return (don't copy ayFX values in to AYREGS)
		; --- Copy ayFX values in to ARYREGS ---
		rrc	a				; Rotate a to the right (1 TIME)
		rrc	a				; Rotate a to the right (2 TIMES) (OR mask)
		ld	d,$DB				; d:=Mask for psg mixer (AND mask)
		; --- Calculate next ayFX channel ---
		ld	hl,ayFX_CHANNEL			; Old ayFX playing channel
		dec	(hl)				; New ayFX playing channel
		jp	nz,.SETCHAN			; If not zero jump to .SETCHAN
		ld	(hl),3				; If zero -> set channel 3
.SETCHAN:	ld	b,(hl)				; Channel counter
.CHK1:		; --- Check if playing channel was 1 ---
		djnz	.CHK2				; Decrement and jump if channel was not 1
.PLAY_C:	; --- Play ayFX stream on channel C ---
		call	.SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	(AYREGS+10),a			; Volume copied in to AYREGS (channel C volume)
		bit	2,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,(ayFX_TONE)			; ayFX tone value
		ld	(AYREGS+4),hl			; copied in to AYREGS (channel C tone)
		ret					; Return
.CHK2:		; --- Check if playing channel was 2 ---
		rrc	d				; Rotate right AND mask
		rrc	a				; Rotate right OR mask
		djnz	.CHK3				; Decrement and jump if channel was not 2
.PLAY_B:	; --- Play ayFX stream on channel B ---
		call	.SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	(AYREGS+9),a			; Volume copied in to AYREGS (channel B volume)
		bit	1,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,(ayFX_TONE)			; ayFX tone value
		ld	(AYREGS+2),hl			; copied in to AYREGS (channel B tone)
		ret					; Return
.CHK3:		; --- Check if playing channel was 3 ---
		rrc	d				; Rotate right AND mask
		rrc	a				; Rotate right OR mask
.PLAY_A:	; --- Play ayFX stream on channel A ---
		call	.SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	(AYREGS+8),a			; Volume copied in to AYREGS (channel A volume)
		bit	0,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,(ayFX_TONE)			; ayFX tone value
		ld	(AYREGS+0),hl			; copied in to AYREGS (channel A tone)
		ret					; Return
.SETMIXER:	; --- Set PSG mixer value ---
		ld	c,a				; c:=OR mask
		ld	a,(AYREGS+7)			; a:=PSG mixer value
		and	d				; AND mask
		or	c				; OR mask
		ld	(AYREGS+7),a			; PSG mixer value updated
		ld	a,(ayFX_VOLUME)			; a:=ayFX volume value
		ret					; Return

ayFX_END:	; --- End of an ayFX stream ---
		xor	a				; a:=0
		ld	(ayFX_PLAYING),a		; There's no ayFX stream to be played!
		dec	a				; a:=255
		ld	(ayFX_CURRENT),a		; Lower ayFX stream
		ret					; Return



	

section rdata

;;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
ayFX_STREAMS:	rb	1     ;Temporaly!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
AYREGS:		rb 	1
;;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	
ayFX_PLAYING:	rb	1			; There's an ayFX stream to be played?
ayFX_CURRENT:	rb	1			; Current ayFX stream playing
ayFX_POINTER:	rb	2			; Pointer to the current ayFX stream
ayFX_TONE:	rb	2			; Current tone of the ayFX stream
ayFX_NOISE:	rb	1			; Current noise of the ayFX stream
ayFX_VOLUME:	rb	1			; Current volume of the ayFX stream
ayFX_CHANNEL:	rb	1			; PSG channel to play the ayFX stream	

section code		