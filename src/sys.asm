;;; Name:	SaveSlotC
;;; Function:	Save Slot in which cartridge is inserted
;;; Modify:	A,HL,DE

	
SaveSlotC:	
	call	RSLREG
	rrca
	rrca
	and	11b
	ld	e,a
	ld	d,0
	ld	hl,EXPTBL
	add	hl,de
	ld	e,a
	ld	a,(hl)
	and	80h
	or	e
	ld	e,a
	
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	
	and	00001100b
	or	e
	ld	(romslt),a
	ret


;;; Name:	RomSlotPageX
;;; Function:	Select Slot Cartridge for the page X
	

RomSlotPage0:
	ld	hl,0
	ld	a,(romslt)	
	jr	SlotChg
RomSlotPage1:
	ld	hl,1<<14
	ld	a,(romslt)	
	jr	SlotChg
			
RomSlotPage2:
	ld	hl,2<<14
	ld	a,(romslt)	
	jr	SlotChg
	
RomSlotPage3:
	ld	hl,3<<14
	ld	a,(romslt)
	
SlotChg:		
	jp	ENASLT



section	rdata
romslt:		rb	1
section code	
