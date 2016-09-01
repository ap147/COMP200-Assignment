#Amarjot Parmar 
#1255668	

.text
.global main
# ADD to your code a dispatcher & a single PCB
# You do not need to working about initialising $ra in this question 
# Assume that 200 words is sufficient for the stack size ( unless recursion ) 
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

	
	jal PCB_Setup


	# Set first task as current task
	la  $1, task1_pcb
	sw  $1, current_task($0)

	#Jumping into dispatcher that loads context
	j load_context

task1_main:
	jal serial_main		
	j task1_main


	task1_Counter_Increment: 
		#Incrementing Counter 
		lw   $13, counter($0)
		addi $13, $13, 1
		sw   $13, counter($0)
	
		rfe

handle_timer:
	#Achnowledge TIMER intrupt
	sw   $0, 0x72003($0)
	#Add 1 from timeslice 
	lw   $13, timerSlice($0)
	addi $13, $13, 1
	sw   $13, timerSlice($0) 
	
	xori $13, $13, 2	#Checking if Time slice = 200
	beqz $13, dispatcher	#IF 200

	j task1_Counter_Increment #Other wise

handler:
 
	#Check what exception occured
	movsg $13, $estat
	andi  $13, $13, 0xffb0 #1111111110110000 TIMER
	#If other
 	bnez  $13, default_handler
	

	#Check Timer exception 
	movsg $13, $estat
	andi  $13, $13, 0x40 #0000000010000000 TIMER
	#If timer 
	bnez  $13, handle_timer


dispatcher:
	
#----------------SAVE CONTEXT-------------------
	save_context:
		lw $13, current_task($0)

		# Save the registers
		sw $1, pcb_reg1($13)
		sw $2, pcb_reg2($13)
		sw $3, pcb_reg3($13)
		sw $4, pcb_reg4($13)
		sw $5, pcb_reg5($13)
		sw $6, pcb_reg6($13)
		sw $7, pcb_reg7($13)
		sw $8, pcb_reg8($13)
		sw $9, pcb_reg9($13)
		sw $10, pcb_reg10($13)
		sw $11, pcb_reg11($13)
		sw $12, pcb_reg12($13)

		#Save $ers
		movsg $1, $ers
		sw $1, pcb_reg13($13)

		# Save $ear
		movsg $1, $ear	
		sw $1, pcb_ear($13)

		# Save $cctrl
		movsg $1, $cctrl
		sw $1, pcb_cctrl($13)

		#Save $sp
		sw $sp, pcb_sp($13)

		#Retore  $ra
		sw $ra, pcb_ra($13)


#----------------SCHEDULE--------------------
	schedule:
		lw $13, current_task($0)  #Get current task
		lw $13, pcb_link($13)     #Get next task from 
		sw $13, current_task($0)  #Set next task as current task
	     
#-------------LOAD CONTEXT-----------------
	load_context:
		lw $13, current_task($0)
		#Get PCB of current task
		# Get the PCB value for $13 back into $

		lw $1, pcb_reg13($13)
		movgs $ers, $1
		# Restore $ear
		lw $1, pcb_ear($13)
		movgs $ear, $1
		# Restore $cctrl
		lw $1, pcb_cctrl($13)
		movgs $cctrl, $1

		#Restore StackPointer
		lw $sp, pcb_sp($13)

		#Retore  Return Address
		lw $ra, pcb_ra($13)

		# Restore the other registers
		lw $1, pcb_reg1($13)
		lw $2, pcb_reg2($13)
		lw $3, pcb_reg3($13)
		lw $4, pcb_reg4($13)
		lw $5, pcb_reg5($13)
		lw $6, pcb_reg6($13)
		lw $7, pcb_reg7($13)
		lw $8, pcb_reg8($13)
		lw $9, pcb_reg9($13)
		lw $10, pcb_reg10($13)
		lw $11, pcb_reg11($13)
		lw $12, pcb_reg12($13)

	#Reseting Time Slice
	addi $13, $0, 0
	sw   $13, timerSlice($0)

		# Return to the new task
		rfe

PCB_Setup:
	j PCB_Task1_Setup

PCB_Task1_Setup:
	#Setup PCB for task 1
	la $1, task1_pcb
	sw $1, current_task($0)
	#Setup link field
	la $2, task1_pcb
	sw $2, pcb_link($1)
	#Setup stack pointer
	la $2, task1_stack
	sw $2, pcb_sp($1)
	#Setup $ear feild
	la $2, task1_main
	sw $2, pcb_ear($1)

.equ left_SSD_Add, 0x73002

.equ     pcb_link, 0
.equ     pcb_reg1, 1
.equ     pcb_reg2, 2
.equ     pcb_reg3, 3
.equ     pcb_reg4, 4
.equ     pcb_reg5, 5
.equ     pcb_reg6, 6
.equ     pcb_reg7, 7
.equ     pcb_reg8, 8
.equ     pcb_reg9, 9
.equ     pcb_reg10, 10
.equ     pcb_reg11, 11
.equ     pcb_reg12, 12
.equ     pcb_reg13, 13

.equ     pcb_sp, 14
.equ     pcb_ra, 15
.equ     pcb_ear, 16
.equ     pcb_cctrl, 17

.bss 	
	current_task:	 .word
	default_handler: .word	#Default Handler address is stored here

	#TimeSLice
	timerSlice: .space 1

	#Serial 
	task1_pcb:   .space 18

		.space 200
	task1_stack: 


