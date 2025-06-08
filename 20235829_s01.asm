# THE MOVING BALL ON BITMAP DISPLAY
# Author: Ma Ngoc Thang - 20235829
# HUST - SOICT - HEDSPI - K68
# For Assembly Language & Computer Architecture Lab
# Version: 2025 Summer
# ---------------------------------------------------------------------------
# OVERVIEW
# this program draws a moving ball on the Bitmap Display.
# player uses key to navigate through modes on the Menu,
# and control the ball's speed and directions.
# the ball can move in four directions: up, down, left, right,
# and once it touches the ball, it bounces back.
# you can run it on the RARS RISC-V simulator:
# https://github.com/TheThirdOne/rars
# ---------------------------------------------------------------------------
# TOOLS FOR THIS PROGRAM
# 1) Keyboard and Display MMIO Simulator
# simply open the tool and connect it to the program.
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
	MENU_SCREEN_LINE_7:		.asciz	"T: Tutorial\n"
	MENU_SCREEN_LINE_8:		.asciz	"Q: Quit\n"
	MENU_SCREEN_LINE_SCR: 		.asciz	"(enter a secret cheat code to customize...)\n"
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
	SETTING_SCREEN_LINE_2:		.asciz	"Press Q to quit this screen without saving\n"
	SETTING_SCREEN_LINE_3:		.asciz	"Ball RGB color (red, 0-255): "
	SETTING_SCREEN_LINE_4:		.asciz	"Ball RGB color (green, 0-255): "
	SETTING_SCREEN_LINE_5:		.asciz	"Ball RGB color (blue, 0-255): "
	SETTING_SCREEN_LINE_6:		.asciz	"Initial ball speed (60-1500): "
	SETTING_SCREEN_LINE_7:		.asciz	"Speed increment (1-100): "
	SETTING_SCREEN_ERROR:		.asciz	"ERROR: Invalid value. Please try again.\n"
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
# multiply one of the above value by an integer
# to make the ball move multiple pixels at once.

# s2: saves the KEY_CODE address
# s3: saves the KEY_READY address
# s4: saves the DISPLAY_CODE address
# s5: saves the DISPLAY_READY address

# -------------------------MAIN program--------------------------
MAIN:
	jal	INIT
	jal	PRINT_MENU
	jal	READ_ENTRY
	j	QUIT

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
	li  	s2, KEY_CODE
	li  	s3, KEY_READY 
    	li  	s4, DISPLAY_CODE 
    	li  	s5, DISPLAY_READY 
	jr	ra

# ---------------------PRINT_MENU subprogram---------------------
# this subprogram prints the menu, as well as the current settings,
# before asking for the player's entry.
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
	
	la	a0, MENU_SCREEN_LINE_8
	ecall
	
	la	a0, MENU_SCREEN_LINE_SCR
	ecall
	
	jr	ra

# ---------------------READ_ENTRY subprogram---------------------
# this subprogram reads the player's entry.
# there are several cases depending on the key pressed:
# S: Start
# T: Tutorial
# Q: Quit
# Any other key: the system waits for the player to type a key
# that directs to one of the modes, unless the player successfully
# types a cheat code (for this program, 727).
# in that case, the system directs to Settings screen.
READ_ENTRY:
WaitForKey:   
	lw      t1, 0(a1)               # t1 = [a1] = KEY_READY 
	beq     t1, zero, WaitForKey    # if t1 == 0 then Polling 
ReadKey:      
	lw      t0, 0(a0)               # t0 = [a0] = KEY_CODE 
WaitForDis:   
	lw      t2, 0(s1)               # t2 = [s1] = DISPLAY_READY 
	beq     t2, zero, WaitForDis    # if t2 == 0 then polling  
Branch:      
	addi    t0, t0, 1               # change input key 
ShowKey: 
	sw      t0, 0(s0)               # show key                
	j       READ_ENTRY

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
