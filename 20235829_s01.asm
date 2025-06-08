# THE MOVING BALL ON BITMAP DISPLAY
# Author: Ma Ngoc Thang - 20235829
# HUST - SOICT - HEDSPI - K68
# For Assembly Language & Computer Architecture Lab
# Version: 2025 Summer
# ---------------------------------------------------------------------------
# OVERVIEW
# this RISC-V program draws a moving ball on the Bitmap Display.
# the player uses key to navigate through modes on the Menu,
# and control the ball's speed and directions.
# the ball can move in one out of four directions: up, down, left, right,
# and once it touches the wall, it bounces back.
# you can run it on the RARS RISC-V simulator:
# https://github.com/TheThirdOne/rars
# ---------------------------------------------------------------------------
# TOOLS FOR THIS PROGRAM
# 1) Keyboard and Display MMIO Simulator
# simply open the tool and connect it to the program.
# during menu or gameplay, always make sure the tool
# reads the input keys from your keyboard.
# (during configuration, input through the Run I/O window instead)
# 2) Bitmap Display
# please set both Unit Width and Unit Height to 1 (px),
# and set both Display Width and Display Height to 512 (px),
# before connecting the tool to the program.

.eqv	MONITOR_SCREEN	0x10010000		# starting address of the memory portion that is
						# outputted to Bitmap Display.
						
.eqv	KEY_CODE   0xFFFF0004      		# ASCII code from keyboard, 1 byte 
.eqv	KEY_READY  0xFFFF0000     		# = 1 if keyboard input is ready
                                 		# Auto clear after lw 
 
.eqv	DISPLAY_CODE   0xFFFF000C   		# ASCII code of the letter to show, 1 byte 
.eqv	DISPLAY_READY  0xFFFF0008   		# = 1 if the display output is ready
                                 		# Auto clear after sw
                                 		
.data
# special lines
	NEWLINE: 			.asciz	"\n"
	SEPARATOR:			.asciz	"------------------------------------------------\n"
# menu interface
	MENU_SCREEN_LINE_1: 		.asciz	"THE MOVING BALL ON BITMAP DISPLAY\n"
	MENU_SCREEN_LINE_2: 		.asciz	"Author: Ma Ngoc Thang - 20235829\n"
	MENU_SCREEN_LINE_3: 		.asciz	"HUST - SOICT - HEDSPI - K68\n"
	MENU_SCREEN_LINE_4:		.asciz	"For Assembly Language & Computer Architecture Lab\n"
	MENU_SCREEN_LINE_5:		.asciz	"Version: 2025 Summer\n"
	MENU_SCREEN_LINE_6: 		.asciz	"S: Start\n"
	MENU_SCREEN_LINE_7:		.asciz	"Q: Quit\n"
# setting display on menu and play interface
	MENU_SETTING_PART_1:		.asciz	"Current settings: ball color "
	MENU_SETTING_PART_2:		.asciz	", initial speed "
	MENU_SETTING_PART_3:		.asciz	"px/frame, speed increment "
	MENU_SETTING_SPEED_UNIT:	.asciz	"px/frame\n"
# play interface
	PLAY_SCREEN_LINE_1:		.asciz	"CURRENTLY PLAYING...\n"
	PLAY_SCREEN_LINE_2:		.asciz	"W: move upward\n"
	PLAY_SCREEN_LINE_3:		.asciz	"A: move leftward\n"
	PLAY_SCREEN_LINE_4:		.asciz	"S: move downward\n"
	PLAY_SCREEN_LINE_5:		.asciz	"D: move rightward\n"
	PLAY_SCREEN_LINE_6:		.asciz	"Z: increase speed\n"
	PLAY_SCREEN_LINE_7:		.asciz	"X: decrease speed\n"
	PLAY_SCREEN_LINE_8:		.asciz	"Q: quit\n"
	PLAY_SCREEN_LINE_9:		.asciz	"R: return to Menu\n"
	PLAY_SCREEN_ERROR_SPEED_DOWN:	.asciz	"ERROR: can't reduce speed beyond the limit (60px/s)\n"
	PLAY_SCREEN_ERROR_SPEED_UP:	.asciz	"ERROR: can't increase speed beyond the limit (1500px/s)\n"
# setting interface
	SETTING_SCREEN_LINE_1:		.asciz	"GAME SETTINGS\n"
	SETTING_SCREEN_LINE_2:		.asciz	"Ball RGB color (red, 0-255): "
	SETTING_SCREEN_LINE_3:		.asciz	"Ball RGB color (green, 0-255): "
	SETTING_SCREEN_LINE_4:		.asciz	"Ball RGB color (blue, 0-255): "
	SETTING_SCREEN_LINE_5:		.asciz	"Initial ball speed (60-1500): "
	SETTING_SCREEN_LINE_6:		.asciz	"Speed increment (1-100): "
	SETTING_SCREEN_SAVE:		.asciz	"Settings saved\n"
# quit interface
	QUIT_SCREEN_LINE_1:		.asciz	"THANK YOU FOR PLAYING\n"
	QUIT_SCREEN_LINE_2:		.asciz	"From HEDSPI with love <3\n"
	QUIT_SCREEN_LINE_3: 		.asciz	"THE MOVING BALL ON BITMAP DISPLAY\n"
	QUIT_SCREEN_LINE_4: 		.asciz	"Author: Ma Ngoc Thang - 20235829\n"
	QUIT_SCREEN_LINE_5: 		.asciz	"HUST - SOICT - HEDSPI - K68\n"
	QUIT_SCREEN_LINE_6:		.asciz	"For Assembly Language & Computer Architecture Lab\n"
	QUIT_SCREEN_LINE_7:		.asciz	"Version: 2025 Summer\n"
.text
# ---the CODE for "the moving ball on Bitmap Display" program----

# ------------------------registers used:------------------------
# t0: RGB value for ball color
# t1: ball speed in px/s
# t2: speed increment in px/s

# s0: coordinates of the center of the ball,
# with the lowest 9 bits representing the column,
# and the 9 bits above them representing the row,
# suppose the screen's rows and columns of pixels are numbered
# from 0 (000_000_000) to 511 (111_111_111).
# since the diameter of the ball is 60 pixels,
# this means that the x and y coordinates of the center
# must both lie in the closed interval [30, 481].

# s1: the moving direction of the ball.
# it can have one of the following values:
# 0x00000001: rightwards
# 0xFFFFFFFF: leftwards
# 0x00000200: downwards
# 0xFFFFFE00: upwards
# as this value gets added to a0,
# unless it makes the ball meets the wall,
# it will move the ball to the specific direction.
# multiply one of the above values by an integer
# to make the ball move multiple pixels at once.

# ------------------------INIT subprogram------------------------
# this subprogram initialize configuration values:
# ball color (t0) = #FFFFFF (pure white),
# initial speed (t1) = 200 px/s,
# speed increment (t2) = 20 px/s,
# ball center position (s0) = (255, 255),
# moving direction (s1) = upwards,
# and the registers s2, s3, s4, s5.
INIT:
	li	t0, 0xFFFFFF
	li	t1, 200
	li	t2, 20
	li	s0, 0x0001FEFF
	li	s1, 0xFFFFFE00

# ---------------------PRINT_MENU subprogram---------------------
# this subprogram prints the menu.
PRINT_MENU:
	li	a7, 4
	la	a0, SEPARATOR
	ecall
	
	la	a0, MENU_SCREEN_LINE_1
	ecall
	
	la	a0, MENU_SCREEN_LINE_2
	ecall
	
	la	a0, MENU_SCREEN_LINE_3
	ecall
	
	la	a0, MENU_SCREEN_LINE_4
	ecall
	
	la	a0, MENU_SCREEN_LINE_5
	ecall
	
	la	a0, MENU_SCREEN_LINE_6
	ecall
	
	la	a0, MENU_SCREEN_LINE_7
	ecall
	
	jal	PRINT_SETTINGS

# ---------------------READ_ENTRY subprogram---------------------
# this subprogram reads the player's entry.
# there are several cases depending on the key pressed:
# S: Start
# Q: Quit
# Any other key: the system waits for the player to type a key
# that directs to one of the modes, unless the player successfully
# types a cheat code (for this program, 727).
# in that case, the system directs to Settings screen.
# while in this subprogram, make sure the program is ran
# at a speed of 30 instructions per second or below.

# additional registers used:
# s2: saves the KEY_CODE address
# s3: saves the KEY_READY address
# s4: saves the DISPLAY_CODE address
# s5: saves the DISPLAY_READY address
# s6: saves the character "S" in ASCII
# s7: saves the character "Q" in ASCII
# s8: saves the character "7" in ASCII
# s9: saves the character "2" in ASCII
# s10: number of characters in the cheat code, "727", input correctly
# t3, t4, t5: saves the result of polling
# and whether the inputs and outputs are ready
# t6: the number of characters in the cheat code to input correctly
# to show the settings
# a3: temporary saves 2 as the modulo for the s11 % 2 operation below
READ_ENTRY:
	ReadEntry_Init:
		li  	s2, KEY_CODE
		li  	s3, KEY_READY 
    		li  	s4, DISPLAY_CODE 
    		li  	s5, DISPLAY_READY 
    		li	s6, 83
    		li	s7, 81
	WaitForKey:
		lw      t4, 0(s3)		# t4 = [s3] = KEY_READY 
		beq     t4, zero, WaitForKey	# if t4 == 0 then poll 
	ReadKey:      
		lw      t3, 0(s2)		# t3 = [s2] = KEY_CODE 
	WaitForDis:   
		lw      t5, 0(s5)		# t5 = [s5] = DISPLAY_READY 
		beq     t5, zero, WaitForDis	# if t5 == 0 then poll
	ShowKey:
		sw	t3, 0(s4)
	# directs the player to the specific mode based on the entered character
	Direct:  
		beq	t3, s6, START
		beq	t3, s7, QUIT
		j	WaitForKey

# -----------------------START subprogram------------------------
# additional registers used:
# s2 and s3 now saves the x and y coordinates of the pixel iterated through.
# s4 and s5 now saves the x and y coordinates of the center of the circle,
# and calculated and called only when needed.
# s6, s9, s10, t6, t5 saves the temporary 512, 870, 930, 4, 20 respectively
START:
	Start_Init:
		li	s6, 512
		li	s9, 870
		li	s10, 930
		li	t6, 4
		li	t5, 20
		
		li	a7, 4
		la	a0, PLAY_SCREEN_LINE_1
		ecall
	
		la	a0, PLAY_SCREEN_LINE_2
		ecall
	
		la	a0, PLAY_SCREEN_LINE_3
		ecall
	
		la	a0, PLAY_SCREEN_LINE_4
		ecall
	
		la	a0, PLAY_SCREEN_LINE_5
		ecall
	
		la	a0, PLAY_SCREEN_LINE_6
		ecall
	
		la	a0, PLAY_SCREEN_LINE_7
		ecall
		
		la	a0, PLAY_SCREEN_LINE_8
		ecall
	
		la	a0, PLAY_SCREEN_LINE_9
		ecall
		
		li	t5, MONITOR_SCREEN
	Start_Loop:
		srli	s4, s0, 9
		andi	s5, s0, 0x1FF
		li	s2, -30
		li	s3, -30
		li	t2, 30
		li	t3, 30
		add	s2, s2, s4
		add	t2, t2, s4
		add	s3, s3, s5
		add	t3, t3, t5
		jal	DrawCircle
		
		li	s2, -30
		li	s3, -30
		li	t2, 30
		li	t3, 30
		add	s2, s2, s4
		add	t2, t2, s4
		add	s3, s3, s5
		add	t3, t3, t5
		jal	DeleteCircle
		
		div	t1, t1, t5
		mul	s1, s1, t1
		mul	t1, t1, t5
		add	s0, s0, s1
		j	Start_Loop
	DrawCircle:
		sub	s2, s2, s4
		sub	s3, s3, s5
		mul	s7, s2, s2
		mul	s8, s3, s3
		add	s7, s7, s8
		add	s2, s2, s4
		add	s3, s3, s5
		mul	s11, s2, s6
		add	s11, s11, s3
		mul	s11, s11, t6
		add	s11, s11, t5
		blt	s7, s9, cont
		blt	s10, s7, cont
		sw	t0, 0(s11)
	cont:
		addi	s3, s3, 1
		bne	s3, s5, DrawCircle
		addi	s2, s2, 1
		li	s3, -60
		add	s3, s3, s5
		bne	s2, s4, DrawCircle
		jr	ra
	DeleteCircle:
		mul	s11, s2, s6
		add	s11, s11, s3
		mul	s11, s11, t6
		add	s11, s11, t5
		sw	zero, 0(s11)
		addi	s3, s3, 1
		bne	s3, s6, DeleteCircle
		addi	s2, s2, 1
		li	s3, 0
		bne	s2, s6, DeleteCircle
		jr	ra
		
# ----------------------SETTINGS subprogram----------------------
# additional registers used:
# s6 to s10: now saves the value 255, 60, 1500, 1, 100 for comparison
SETTINGS:
	li	s6, 255
    	li	s7, 60
    	li	s8, 1500
    	li	s9, 1
	li	s10, 100
	
	li	a7, 4
	la	a0, SEPARATOR
	ecall
	
	la	a0, SETTING_SCREEN_LINE_1
	ecall
	
	jal	PRINT_SETTINGS
	
	Try1:
		la	a0, SETTING_SCREEN_LINE_2
		ecall
	
		li	a7, 5
		ecall
	
		blt	a0, zero, Try1
		blt	s6, a0, Try1
		
		slli	a0, a0, 16
		and	t0, t0, a0
	
	Try2:
		li	a7, 4
		la	a0, SETTING_SCREEN_LINE_3
		ecall
	
		li	a7, 5
		ecall
	
		blt	a0, zero, Try2
		blt	s6, a0, Try2
				
		slli	a0, a0, 8
		or	t0, t0, a0
		
	Try3:
		li	a7, 4
		la	a0, SETTING_SCREEN_LINE_4
		ecall
	
		li	a7, 5
		ecall
	
		blt	a0, zero, Try3
		blt	s6, a0, Try3
		
		or	t0, t0, a0
		
	Try4:
		li	a7, 4
		la	a0, SETTING_SCREEN_LINE_5
		ecall
		
		li	a7, 5
		ecall
		
		blt	a0, s7, Try4
		blt	s8, a0, Try4
		
		add	t1, zero, a0
		
	Try5:
		li	a7, 4
		la	a0, SETTING_SCREEN_LINE_6
		ecall
		
		li	a7, 5
		ecall
		
		blt	a0, s9, Try5
		blt	s10, a0, Try5
		
		add	t2, zero, a0
	
	li	a7, 4
	la	a0, SETTING_SCREEN_SAVE
	ecall
	
	j	PRINT_MENU

# ------------------------QUIT subprogram------------------------
# this subprogram prints the quit screen and exits the program.
QUIT:
	li	a7, 4
	la	a0, SEPARATOR
	ecall
	
	la	a0, QUIT_SCREEN_LINE_1
	ecall
	
	la	a0, QUIT_SCREEN_LINE_2
	ecall
	
	la	a0, QUIT_SCREEN_LINE_3
	ecall
	
	la	a0, QUIT_SCREEN_LINE_4
	ecall
	
	la	a0, QUIT_SCREEN_LINE_5
	ecall
	
	la	a0, QUIT_SCREEN_LINE_6
	ecall
	
	la	a0, QUIT_SCREEN_LINE_7
	ecall
	
	li	a7, 10
	ecall

# -------------------PRINT_SETTINGS subprogram-------------------
# this subprogram prints the settings.
PRINT_SETTINGS:
	la	a0, MENU_SETTING_PART_1
	ecall
	
	li	a7, 34
	add	a0, zero, t0
	ecall
	
	li	a7, 4
	la	a0, MENU_SETTING_PART_2
	ecall
	
	li	a7, 1
	add	a0, zero, t1
	ecall

	li	a7, 4
	la	a0, MENU_SETTING_PART_3
	ecall
	
	li	a7, 1
	add	a0, zero, t2
	ecall
		
	li	a7, 4	
	la	a0, MENU_SETTING_SPEED_UNIT
	ecall
	
	jr	ra