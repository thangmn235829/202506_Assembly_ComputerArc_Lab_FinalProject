.eqv MONITOR_SCREEN 0x10010000 	# starting address of the memory portion that is
					# outputted to Bitmap Display.
.eqv RED            0x00FF0000		# common colors
.eqv GREEN          0x0000FF00 
.eqv BLUE           0x000000FF 
.eqv WHITE          0x00FFFFFF 
.eqv YELLOW         0x00FFFF00 
.eqv ORANGE         0x00FF8F00
# registers used
# s0: MONITOR_SCREEN, always +4 (word)
# s1: color
# s2: pixel position
# s3: limit (number of pxs)
# s4: number of cols
# s5: a
# s6: b
# s7: c
# s8: position of the origin point O
# s9: min X
# s10: max X
# s11: temp
.data
	question: 	.asciz "Continue"
	mess_a: 	.asciz "Enter a:"
	mess_b: 	.asciz "Enter b:"
	mess_c: 	.asciz "Enter c:"
	mess_color:	.asciz "Color code:\n1->5: red, orange, yellow, green, blue;\nothers:white\n"
.text 
	li  	s0, MONITOR_SCREEN
	li  	s1, WHITE	# your default color
	li	s2, 0
	li	s3, 65536
	li	s4, 256
	li	s8, 32896
	li	s9, -128
	li  	s10, 127
	
	li 	s5, 128
DrawY:
	bge s5,s3,EndDrawY
	li  s11,4
	mul	s11,s5,s11
	add s11,s0,s11
	jal PrintColor
	add s5,s5,s4
	j DrawY
EndDrawY:	
	li  s5,0
	li  s6,0
	li  s7,0
	#j Done
	j DrawF
	
EndDrawF:
	li a7, 50		# makes a confirm dialog
	la a0,question
	ecall
	bgt a0,zero,Done
	
	li a7, 4 
	la a0, mess_a
	ecall 
	li a7, 5
	ecall
	addi s5,a0,0
	
	li a7, 4 
	la a0, mess_b
	ecall 
	li a7, 5
	ecall
	addi s6,a0,0
	
	li a7, 4 
	la a0, mess_c
	ecall 
	li a7, 5
	ecall
	addi s7,a0,0
	
	li a7, 4 
	la a0, mess_color
	ecall 
	li a7, 5
	ecall
	addi s11,a0,0
	li t0,1
	beq s11,t0,Red
	li t0,2
	beq s11,t0,Orange
	li t0,3
	beq s11,t0,Yellow
	li t0,4
	beq s11,t0,Green
	li t0,5
	beq s11,t0,Blue
	li s1,WHITE
	j StartDraw 
Red:
	li s1,RED
	j StartDraw 
Orange:
	li s1,ORANGE
	j StartDraw 
Yellow:
	li s1,YELLOW
	j StartDraw 
Green:
	li s1,GREEN
	j StartDraw 
Blue:
	li s1,BLUE
StartDraw:	
	j DrawF
	#---------
	j Done
#--------------------------------
DrawF:
	addi	t0,	s9,0
Loop:
	bgt	t0, s10,EndLoop
	jal CalF # output:t6
	bge t6,s3,OutLimit
	blt t6,zero,OutLimit
	li  s11,4
	mul	s11,t6,s11
	add s11,s0,s11
	jal PrintColor
OutLimit:
	addi t0,t0,1
	j Loop
EndLoop:
	j EndDrawF
#----------------------
# VAR
# s11:pixel to print [input]
# s1: color [input]
PrintColor:
	sw  s1, 0(s11)
#	addi s0,s0,4
	jr	ra
#----------------------
# VAR
# t0: current x ,s5(a),s6(b),s7(c)[input]
# t6: [output]
CalF:
	mul t6,t0,t0 #x^2
	mul t6,t6,s5 # a*x^2
	mul s11,t0,s6# b*x
	add t6,t6,s11# a*x^2+b*x
	add t6,t6,s7# a*x^2+b*x+c
	# Scale y
	li s11,5
	div t6,t6,s11
	
	mul t6,t6,s4
	li s11,-1
	#addi s11,zero,-1
	mul t6,t6,s11
	add t6,t6,s8
	add t6,t6,t0
	jr ra
Done:
