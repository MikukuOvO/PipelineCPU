# Test File for 42 Instruction, include:
# 1. Subset 1:
# ADD/SUB/SLL/SRL/SRA/SLT/SLTU/AND/OR/XOR/ 
#SLLI/SRLI/SRAI/ 						13				
# 2. Subset 2:
# ADDI/ANDI/ORI/XORI/LUI/SLTI/SLTIU/AUIPC			8
# 3. Subset 3:
# LB/LBU/LH/LHU/LW/SB/SH/SW 		                                8
# 4. Subset 4:
# BEQ/BNE/BGE/BGEU/BLT/BLTU				6
# 5. Subset 5:
# JAL/JALR						2
#							37
##################################################################
### Make sure following Settings :
# Settings -> Memory Configuration -> Compact, Data at address 0


	##################
	# Test Subset 2  #
	ori x5, x0, 0x234
    lui x6, 0x1
    or x5,x5,x6                         #x5=0x00001234
	lui x6, 0x98765                     #x6=0x98765000
	addi x7, x5, 0x345					#x7=0x00001579
	addi x8, x6, -1024        			#x8=0x98764C00     
	xori x9, x5, 0x7bc					
	sltiu x3, x7, 0x34
	sltiu x4, x5, -1
	andi x18, x9, 0x765
	slti x20, x6, 0x123
	
	
	##################
	# Test Subset 1  #
	sub x19, x6, x5                #x19=0x98763DCC
	xor x21, x20, x6                #x21=0x98765001
	add x22, x21, x20
	add x22, x22, x5
	sub x23, x22, x6                  #x23=0x00001236
	or  x25, x23, x22                 #x25=0x98767236
	and x26, x23, x22               #x26=0x00000236
	slt x27, x25, x26                 #x27=1
	sltu x28, x25, x26               #x28=0
	
	### Test for shift
    addi x3, x3, 4   # pay attention to register shift
	sll x27, x26, x3
	srl x28, x25, x3
	sra x29, x25, x3
	slli  x27, x19, 16
	srli x28, x19, 4
	srai x29, x19, 4
	
	
	##################
	# Test Subset 3  #
	addi x3, x0, 0
    addi x5,x0, 0xFF
	
	
	### Test for store
	sw x19, 0(x3)
	sw x21, 4(x3)
	sw x23, 8(x3)
	sh x26, 4(x3)
	sh x19, 10(x3)
	sb x5, 7(x3)
	sb x5, 9(x3)
	sb x5, 8(x3)
	
	### Test for load
    lw  x5, 0(x3)           #x5=0x98763DCC
	sw x5, 12(x3)
	lh x7, 2(x3)             #x7=0xFFFF9876
	sw x7, 16(x3)
	lhu x7, 2(x3)           #x7=0x00009876
	sw x7, 20(x3)
	lb x8, 3(x3)              #x8=0xFFFFFF98
	sw x8, 24(x3)
	lbu x8, 3(x3)            #x8=0x00000098
	sw x8, 28(x3)
	lbu x8, 1(x3)            #x8=0x0000003D
	sw x8, 32(x3)

	
	##################
	# Test Subset 4  #
	sw x0, 0(x3)
	and x9, x0, x9			# x9 = 0
	bne x5, x7,  _lb1 		# go to _lb1
	addi x9, x9, 1

	_lb1:
	bge x5, x7, _lb2 		
	addi x9, x9, 1			# x9 = 1

	_lb2:
	bgeu x5, x7, _lb3		# go to _lb3
	addi x9, x9, 1

	_lb3:
	blt x5, x7, _lb4		# go to _lb4
	addi x9, x9, 1

	_lb4:
	bltu x5, x7, _lb4		
	addi x9, x9, 1			# x9 = 2

	_lb5:
	beq x7, x8, _lb6		
	addi x9, x9, 1			# x9 = 3

	_lb6:
	sw x9, 0(x3)        #x9 = 3

	
	##################
	# Test Subset 5  #
	lw x10, 0(x3)
	jal x1, F_Test_JAL
	addi x10, x10, 5
	sw x10, 0(x3)

	F_Test_JAL:
	ori x10, x10, 0x550
	sw x10, 0(x3)
	jalr x0, x1, 0


