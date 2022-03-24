.include "m328pdef.inc"

	.def	mask 	= r16		; mask register
	.def	disp    = r17
	.def	ledR 	= r18		; led register
	.def	seg	= r19
	.def	decima	= r20
	.def	min	= r21
	.def	flag	= r22
	.def	setf	= r23
	.def	oLoopRl	= r24		; outer loop register
	.def	oLoopRh	= r25		; outer loop register
	.def	iLoopRl = r26		; inner loop register low
	.def	iLoopRh = r27		; inner loop register high
	

	.equ	oVal 	= 1000		; outer loop value
	.equ	S1_mask	= 4000		; inner loop value  1 seg
	.equ	S2_mask	= 10		; inner loop value  10 seg
	.equ	S3_mask	= 6		; inner loop value 1 min

	.cseg
	.org	0x00
	clr	ledR			; clear led register
	ldi	mask,0xFF
	out     DDRD,mask
	ldi	mask,0x1F
        out     DDRC,mask
	ldi	mask,0x00
        out     DDRB,mask
	ldi	seg,0x00
	ldi	decima,0x00
	ldi	min,0x03
	ldi	flag,0x01
	ldi	setf,0x00
	
loop:	ldi	mask,0x10
	and	LedR,mask
	ldi	mask, (1<<PINC4)
	eor	LedR, mask
	ldi	mask,0x0F
	add	LedR,mask
	ldi	mask,0xF0
	add	min,mask
	and	LedR,min
	out	PORTC,LedR
	ldi	disp,0xFF
	and	disp,seg
	ldi	mask,0xF0
	add	disp,mask
	ldi	mask,0xFF
	and	mask,decima
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	and	disp,mask
	out	PORTD, disp
	
	sbic	PINC,5
	rjmp	set_m
	
	cpi	flag,0x01
	brne	count
	sbic	PINB,5
	ldi	flag,0x00
	
	cpi	flag,0x00
	brne	loop
	rjmp	count
	
set_m:	out	PORTC,min
	in	min,PINB
	ldi	mask,0x0F
	and	min,mask
	sbic	PINB,4
	rjmp	set_d
	rjmp	set_m
	
set_d:	ldi	disp,0xFF
	and	disp,seg
	ldi	mask,0xF0
	add	disp,mask
	ldi	mask,0xFF
	and	mask,decima
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	and	disp,mask
	out	PORTD, disp
	in	decima,PINB
	ldi	mask,0x0F
	and	decima,mask
	sbic	PINB,5
	rjmp	set_s
	rjmp	set_d
	
set_s:	ldi	disp,0xFF
	and	disp,seg
	ldi	mask,0xF0
	add	disp,mask
	ldi	mask,0xFF
	and	mask,decima
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	lsl	mask
	inc	mask
	and	disp,mask
	out	PORTD, disp
	in	seg,PINB
	ldi	mask,0x0F
	and	seg,mask
	sbic	PINB,4
	rjmp	loop
	rjmp	set_s
	
loop_l: rjmp    loop	
    
count:	ldi	oLoopRl,LOW(oVal)
	ldi	oLoopRh,HIGH(oVal)	
    
oLoop:	ldi	iLoopRl,LOW(S1_mask)
	ldi	iLoopRh,HIGH(S1_mask)
	
iLoop:	sbiw	iLoopRl,1
	brne	iLoop
	
	sbic	PINB,4
	ldi	flag,0x01
	sbic	PINC,5
	ldi	flag,0x02
	
	sbiw	oLoopRl,1
	brne	oLoop	
	
	dec	seg
	ldi	mask,0x0F
	and	seg,mask
	cpi	seg,0x0F
	brne	loop_l
	
	ldi	seg,0x09
	dec	decima
	ldi	mask,0x0F
	and	decima,mask
	cpi	decima,0xF
	brne	loop_l
	
	ldi	decima,0x05
	dec	min
	ldi	mask,0x0F
	and	min,mask
	cpi	min,0xF
	brne	loop_l
	
finish:	rjmp	finish
	
	
