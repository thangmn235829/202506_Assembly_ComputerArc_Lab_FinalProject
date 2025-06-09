.eqv MONITOR_SCREEN 0x10010000 	# starting address of the memory portion that is
					# outputted to Bitmap Display.
.eqv RED            0x00FF0000		# common colors
.eqv GREEN          0x0000FF00 
.eqv BLUE           0x0000AAFF 
.eqv WHITE          0x00FFFFFF 
.eqv YELLOW         0x00FFFF00 
.eqv ORANGE         0x00FF8F00
# registers used
# s0: MONITOR_SCREEN
# s1: color
# s2: pixel position
# s3: limit of the function value limit
# s4: number of cols
# s5: a
# s6: b
# s7: c
# s8: position of the origin point O
# s9: min X
# s10: max X
# s11: temp
.data
	question: 	.asciz 	"Continue"
	mess_a: 	.asciz 	"Enter a:"
	mess_b: 	.asciz 	"Enter b:"
	mess_c: 	.asciz 	"Enter c:"
	mess_color:	.asciz 	"Color code:\n1->5: red, orange, yellow, green, blue;\nothers: white\n"
.text 
	li  	s0, MONITOR_SCREEN
	li  	s1, WHITE	# your default color
	li	s2, 0
	li	s3, 65536
	li	s4, 256
	li	s8, 32896
	li	s9, -128
	li  	s10, 127
	
	li 	s5, 128		# first point of the Y-axis
DRAW_Y_AXIS:
# temporarily use s5 as the pointer to draw the Y-axis on
	bge	s5, s3, END_DRAW_Y_AXIS
	li	s11, 4
	mul	s11, s5, s11
	add	s11, s0, s11
	jal 	PRINT_COLOR
	add 	s5, s5, s4
	j 	DRAW_Y_AXIS
# reset s5 for its original use
END_DRAW_Y_AXIS:	
	li  	s5, 0
	j 	DRAW_FUNCTION
	
END_DRAW_FUNCTION:
	li 	a7, 50		# makes a confirm dialog
	la 	a0, question
	ecall
	bgt 	a0, zero, DONE
	
	li 	a7, 4 
	la 	a0, mess_a
	ecall 
	li 	a7, 5
	ecall
	addi 	s5, a0, 0
	
	li 	a7, 4 
	la 	a0, mess_b
	ecall 
	li 	a7, 5
	ecall
	addi 	s6, a0, 0
	
	li 	a7, 4 
	la 	a0, mess_c
	ecall 
	li 	a7, 5
	ecall
	addi 	s7, a0, 0
	
	li 	a7, 4 
	la 	a0, mess_color
	ecall 
	li 	a7, 5
	ecall
	addi 	s11, a0, 0
	li 	t0, 1
	beq 	s11, t0, Red
	li 	t0, 2
	beq 	s11, t0, Orange
	li 	t0, 3
	beq 	s11, t0, Yellow
	li 	t0, 4
	beq 	s11, t0, Green
	li 	t0, 5
	beq 	s11, t0, Blue
	li 	s1, WHITE
	j	START_DRAWING 
Red:
	li	s1, RED
	j	START_DRAWING 
Orange:
	li	s1, ORANGE
	j	START_DRAWING 
Yellow:
	li	s1, YELLOW
	j	START_DRAWING 
Green:
	li	s1, GREEN
	j	START_DRAWING 
Blue:
	li	s1, BLUE
START_DRAWING:	
	j	DRAW_FUNCTION
	#---------
	j	DONE
#--------------------------------
DRAW_FUNCTION:
	addi	t0, s9, 0
Loop:
	bgt	t0, s10, EndLoop
	jal	CALCULATE_FUNCTION_VALUES # output:t6
	bge	t6, s3, OutsideGraph
	blt	t6, zero, OutsideGraph
	li 	s11, 4
	mul	s11, t6, s11
	add 	s11, s0, s11
	jal 	PRINT_COLOR
OutsideGraph:
	addi	t0,t0,1
	j	Loop
EndLoop:
	j 	END_DRAW_FUNCTION
#----------------------
# additional register used
# s11: pixel to print [input]
# s1: color [input]
# return none
PRINT_COLOR:
	sw	s1, 0(s11)
#	addi s0,s0,4
	jr	ra
#----------------------
# additional register used
# t0: current x, s5(a), s6(b), s7(c) [input]
# t6: [output]
CALCULATE_FUNCTION_VALUES:
	mul	t6, t0, t0
	mul	t6, t6, s5
	mul	s11, t0, s6
	add	t6, t6, s11
	add	t6, t6, s7
	# Scale y
	srli 	t6, t6, 8
	
	mul 	t6, t6, s4
	li 	s11, -1
	mul	t6, t6, s11
	add	t6, t6, s8
	add	t6, t6, t0
	jr	ra
DONE:
	li	a7, 10
	ecall
