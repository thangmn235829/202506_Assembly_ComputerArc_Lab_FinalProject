.eqv MONITOR_SCREEN	0x10010000		# starting address of the memory portion that is
						# outputted to Bitmap Display.
.data
# special lines
	NEWLINE: 			.asciz	"\n"
	SEPARATOR:			.asciz	"------------------------------------------------\n"
# menu interface
	MENU_SCREEN_LINE_1: 		.asciz	"THE MOVING BALL ON BITMAP DISPLAY\n"
	MENU_SCREEN_LINE_2: 		.asciz	"Author: Ma Ngoc Thang - 20235829\n"
	MENU_SCREEN_LINE_3: 		.asciz	"HUST - SOICT - HEDSPI - K68\n"
	MENU_SCREEN_LINE_4:		.asciz	"For Assembly Language & Computer Architecture Lab"
	MENU_SCREEN_LINE_5:		.asciz	"Version: 2025 Summer"
	MENU_SCREEN_LINE_6: 		.asciz	"S: Start\n"
	MENU_SCREEN_LINE_7:		.asciz	"T: Tutorial\n"
	MENU_SCREEN_LINE_8:		.asciz	"Q: Quit\n"
	MENU_SCREEN_LINE_SCR: 		.asciz	"(enter a secret cheat code to customize your game...)\n"
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
	PLAY_SCREEN_LINE_8:		.asciz	"Q: quit the game\n"
	PLAY_SCREEN_LINE_9:		.asciz	"R: return to Menu\n"
	PLAY_SCREEN_ERROR_SPEED_DOWN:	.asciz	"ERROR: can't reduce speed beyond the limit (60px/s)\n"
	PLAY_SCREEN_ERROR_SPEED_UP:	.asciz	"ERROR: can't increase speed beyond the limit (1500px/frame)\n"
# setting interface
	SETTING_SCREEN_LINE_1:		.asciz	"GAME CONFIGURATION\n"
	SETTING_SCREEN_LINE_2:		.asciz	"Ball RGB color (red, 0-255): "
	SETTING_SCREEN_LINE_3:		.asciz	"Ball RGB color (green, 0-255): "
	SETTING_SCREEN_LINE_4:		.asciz	"Ball RGB color (blue, 0-255): "
	SETTING_SCREEN_LINE_5:		.asciz	"Initial ball speed (60-1500): "
	SETTING_SCREEN_LINE_6:		.asciz	"Speed increment (1-100): "
	SETTING_SCREEN_ERROR:		.asciz	"ERROR: Invalid value. Please try again.\n"
# quit interface
	QUIT_SCREEN_LINE_1:		.asciz	"THANK YOU FOR PLAYING"
	QUIT_SCREEN_LINE_2:		.asciz	"From HEDSPI with love <3"
	QUIT_SCREEN_LINE_3: 		.asciz	"THE MOVING BALL ON BITMAP DISPLAY\n"
	QUIT_SCREEN_LINE_4: 		.asciz	"Author: Ma Ngoc Thang - 20235829\n"
	QUIT_SCREEN_LINE_5: 		.asciz	"HUST - SOICT - HEDSPI - K68\n"
	QUIT_SCREEN_LINE_6:		.asciz	"For Assembly Language & Computer Architecture Lab"
	QUIT_SCREEN_LINE_7:		.asciz	"Version: 2025 Summer"
.text
