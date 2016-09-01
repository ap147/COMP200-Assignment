

.text
.global main



main:
	#------------------Setting Up Handler-----------------------
	movsg $1, $evec	    		#Store Default Handler Address in register 
	sw    $1, default_handler($0)	#Store Default Handler Adress in memory 
	la    $1, handler		#Store our handler add in default handler adress
	movgs $evec, $1
	
	#----------------   Setting Up CPU   -----------------------
	#IRQ2, kernal mode, interrupts enabled 1001010
	addi  $1 , $0, 0x4a
	movgs $cctrl, $1

	#----------------  Setting Up Timer   ----------------------
	#load into timer
	addi $1, $0, 24		
	sw   $1, 0x72001($0)	
	#Enable Timer & Auto start
	addi $1, $0, 0x3  
	sw   $1, 0x72000($0)
	j mainline

mainline:
	jal serial_main		
	j mainline


incrementCounter: 
	#Incrementing Counter 
	lw   $13, counter($0)
	addi $13, $13, 1
	sw   $13, counter($0)
	
	#Achnowledge TIMER intrupt
	sw   $0, 0x72003($0)
	rfe
handler:
 
	#Checking what exception occured
	movsg $13, $estat
	andi  $13, $13, 0xffb0 #1111111110110000 TIMER
	#If other then call default handler
	bnez  $13, default_handler

	#IF Timer exception 
	movsg $13, $estat
	andi  $13, $13, 0x40 #0000000010000000 TIMER
	#If other then call default handler
	bnez  $13, incrementCounter

.bss 	
	default_handler: .word	#Default Handler address is stored here
