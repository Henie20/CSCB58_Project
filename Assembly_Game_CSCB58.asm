#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Henie Patel
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
#####################################################################

############### Contstants ################
.eqv BASE_ADDRESS 0x10008000
.eqv LAST_PIXEL 16384
.eqv NEXT_ROW 256
.eqv PLATFORM_SIZE 10
############ Colours ###################
.eqv BLACK 0x00030303
.eqv GREEN 0x00ff00
.eqv SPIKE_COLOUR 0x00797979
.eqv BLUE 0x0000ff 
.eqv RED 0xff0000
.eqv YELLOW 0x00d1f542
.eqv GOLD 0x00febd25
.eqv WHITE 0x00fafafa

################ Variables ##################
.data 
Character_Position: .word 0     # stores the characters position (offset)
GameOver: .word 0		# 1 iff game is over
PickUps: .word 0		# number of pickups collected
DoubleJump: .word 0		# is 1 if you can double jump
Item1Collected: .word 0		# 1 iff item 1 is collected
Item2Collected: .word 0		# 1 iff item 2 is collected
PlatformLoc: .space 8		# platform locations (platforms: 2,3)
Platform_Directions: .space 8 	# 4 if platform moves right, -4 if platform moves left
ItemLoc: .space 8		# Item locations
Item_Directions: .space 8 	# 4 if item moves right, -4 if item moves left


.text
.globl main
	
main:
	##################### Draw Start Screen ####################
	jal ClearScreen	# clear screen
# Draw start screen
StartScreen:
	li $t0, BASE_ADDRESS
	li $t1, WHITE
	addi $t0, $t0, 6728	# load starting address of 'start'
	# draw s
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 1036($t0)
	sw $t1, 1292($t0)
	sw $t1, 1548($t0)
	sw $t1, 1544($t0)
	sw $t1, 1540($t0)
	sw $t1, 1536($t0)
	# draw t
	addi $t0, $t0, 28
	sw $t1, 0($t0) 
	sw $t1, 256($t0)
	sw $t1, 252($t0)
	sw $t1, 248($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1536($t0)
	# draw a
	addi $t0, $t0, 16
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 1552($t0)
	# draw r
	addi $t0, $t0, 24
	sw $t1, 0($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1536($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	# draw t
	addi $t0, $t0, 28
	sw $t1, 0($t0) 
	sw $t1, 256($t0)
	sw $t1, 252($t0)
	sw $t1, 248($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1536($t0)
	
# wait for user to enter p for play or q for quit.
playorquit:
	li $a0, 0xffff0000
	lw $t0, 0($a0)
	lw $t0, 4($a0)		
	beq, $t0, 0x70, StartGame
	beq, $t0, 0x71, EndProgram
	j playorquit
	

StartGame:
	jal ClearScreen
	##################### Initialization #######################
	# Set GameOver to be 0
	sw $zero, GameOver
	# Set PickUps to be 0
	sw $zero, PickUps
	# Set Item1Collected to be 0
	sw $zero, Item1Collected
	# Set Item2Collected to be 0
	sw $zero, Item2Collected
	# Set DoubleJump to 0
	sw $zero, DoubleJump
	# Set platform directions
	la $t0, Platform_Directions
	li $t1, 4
	li $t2, -4
	sw $t2, 0($t0)
	sw $t1, 4($t0)
	# Set Item directions
	la $t0, Item_Directions
	li $t1, -4
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	# Draw character
	li $t1, 524
	sw $t1, Character_Position
	lw $a0, Character_Position
	li $a1, GREEN
	li $a2, BLUE
	jal DrawCharacter
	# Draw initial (moving) platforms 
	li $a2, RED
	la $t3, PlatformLoc
	# Moving Platform 1 	
	li $a1, 5584
	sw $a1, 0($t3)
	jal DrawPlatform
	# Moving platform #2
	li $a1, 6656
	sw $a1, 4($t3)
	jal DrawPlatform
	# Draw initial Items
	li $a2, YELLOW
	la $t3, ItemLoc
	# Item 1	
	li $a1, 1400
	sw $a1, 0($t3)
	jal DrawItem
	# Item 2
	li $a1, 4572
	sw $a1, 4($t3)
	jal DrawItem
##############################################################
#			Game Loop			     #
##############################################################	
GameLoop:
	# Draw score
	jal DrawScore
	# Check if player hit spikes
	lw $t1, GameOver
	bne $t1, $zero, GameOverScreen
	# Check if player collected all pickups
	lw $t1, PickUps
	beq $t1, 2, WinScreen		# jump to winscreen
	################## Draw Static Objects ##############
	# Draw initial (static) platforms
	li $a2, RED
	la $t3, PlatformLoc
	li $a1, 2152
	jal DrawPlatform
	li $a1, 10304
	jal DrawPlatform
	li $a1, 9324
	jal DrawPlatform
	li $a1, 8600
	jal DrawPlatform
	li $a1, 7532
	jal DrawPlatform
	li $a1, 4520
	jal DrawPlatform
	li $a1, 3468
	jal DrawPlatform
	# Draw Spikes/ Ground
	li $t0, BASE_ADDRESS
	li $t1, SPIKE_COLOUR
	add $t2, $t0, LAST_PIXEL
	addi $t0, $t0, 16128		# move to the bottom left pixel

	MakeSpike: 
	bge $t0, $t2, UpdatePlatforms	# loop condition
	sw, $t1, ($t0)			# colour pixel
	addi, $t0, $t0, -256		# move up one
	sw, $t1, ($t0)			# colour pixel
	addi, $t0, $t0, -256		# move up one
	sw, $t1, ($t0)			# colour pixel
	addi, $t0, $t0, -256		# move up one
	sw, $t1, ($t0)			# colour pixel
	addi, $t0, $t0, 772		# move down two unit and move right one
	sw, $t1, ($t0)			# colour pixel
	addi, $t0, $t0, 4		# move right by one
	j MakeSpike
	
	############## Update non-static platforms ############
	UpdatePlatforms:	
		# Erase moving plaforms
		li $a2, BLACK		
		la $t3, PlatformLoc		# load platformloc into t3
		lw $a1, 0($t3)			# load start location of moving platform #1
		jal DrawPlatform
		lw $a1, 4($t3)			# load start location of moving platform #2
		jal DrawPlatform
		# Draw platforms
		jal ValidPlatformPositions	# Ensure platform positions are valid
		la $t3, PlatformLoc		# load platformloc into t3
		la $t4, Platform_Directions
		li $a2, RED
		lw $a1, 0($t3)			# load start location of moving platform #1
		lw $t5, 0($t4)			# get direction of platform
		add $a1, $a1, $t5		
		sw $a1, 0($t3)			# store new location of platform 
		jal DrawPlatform	
		lw $a1, 4($t3)			# load start location of moving platform #2
		lw $t5, 4($t4)			# get direction of platform
		add $a1, $a1, $t5		
		sw $a1, 4($t3)			# store new location of platform 
		jal DrawPlatform		# redraw platforms
	################## Update Items ###################			
		# Draw Items
		jal ValidItemPosition		# Ensure item positions are valid
		la $t3, ItemLoc			# load item locations into t3
		la $t4, Item_Directions		# load item directiosn into t4
		lw $t7, Item1Collected
		
		bne $t7, $zero, checkitem2
		# Erase item #1
		li $a2, BLACK	
		lw $a1, 0($t3)			# load start location of item 1
		jal DrawItem
		# Redraw item #2
		lw $a1, 0($t3)			# load start location of Item 1
		li $a2, YELLOW
		lw $t5, 0($t4)			# get direction of Item 1
		add $a1, $a1, $t5		
		sw $a1, 0($t3)			# store new location of Item 1
		jal DrawItem	
		checkitem2:
		lw $t7, Item2Collected
		bne $t7, $zero, drawcharacter
		# Erase item #2
		li $a2, BLACK
		lw $a1, 4($t3)			# load start location of item 2
		jal DrawItem
		# Eedraw item #2
		lw $a1, 4($t3)			# load start location of platform 3
		li $a2, YELLOW
		lw $t5, 4($t4)			# get direction of platform 3
		add $a1, $a1, $t5		
		sw $a1, 4($t3)			# store new location of platform 3
		jal DrawItem
		
	drawcharacter:
	################# Erase Character ###################
	li $a1, BLACK
	li $a2, BLACK
	jal DrawCharacter 
	############# Check for keyboard input #############
	li $a0, 0xffff0000
	lw $t0, 0($a0)
	bne $t0, 1, UpdateCharacter
	jal HandleKeyPress
	beq $v0, 1, main			# restart if keypressed was p
	################## Draw Character ##################
	UpdateCharacter:
	# Ensure Position of Character is valid
	jal ValidCharacterPosition
	lw $a0, Character_Position
	li $t0, 13834				
	blt $a0, $t0, not_hit_spike		# If offset is less than t0 then character is not on spikes
	# Set game over to be one
	li $t1, 1
	sw $t1, GameOver	
	not_hit_spike:
	li $a1, GREEN
	li $a2, BLUE
	jal DrawCharacter
	################# Check for PickUPS #################
	la $t0, ItemLoc
	lw $a0, 0($t0)
	la $a1, Item1Collected
	jal CheckPickups
	la $t0, ItemLoc
	lw $a0, 4($t0)
	la $a1, Item2Collected
	jal CheckPickups
	# Redraw character for cleaner graphics
	lw $a0, Character_Position
	li $a1, GREEN
	li $a2, BLUE
	jal DrawCharacter
	##################### Update Score ####################
	lw $t0, Item1Collected
	lw $t1, Item2Collected
	add $t0, $t0, $t1
	sw $t0, PickUps
	li $a0, GOLD
	# sleep 
	li $v0, 32
	li $a0, 100			# wait 100 milliseconds
	syscall
	j GameLoop
	
GameOverScreen:
	# Draw GameOver screen
	li $t0, BASE_ADDRESS
	li $t1, WHITE
	addi $t0, $t0, 5716	# load starting address of 'GAME OVER'
	# draw G
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 780($t0)
	# draw a
	addi $t0, $t0, 24
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 1552($t0)
	# draw m
	addi $t0, $t0, 24
	sw $t1, 260($t0)
	sw $t1, 520($t0)
	sw $t1, 268($t0)
	sw $t1, 256($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 528($t0)
	sw $t1, 768($t0)
	sw $t1, 784($t0)
	sw $t1, 1024($t0)
	sw $t1, 1040($t0)
	sw $t1, 1280($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1552($t0)
	# draw e
	addi $t0, $t0, 24
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 528($t0)
	sw $t1, 768($t0)
	sw $t1, 784($t0)
	sw $t1, 1024($t0)
	sw $t1, 1040($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1280($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	
	# draw o
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 8020
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 272($t0)
	# draw v
	addi $t0, $t0, 24
	sw $t1, 0($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1028($t0)
	sw $t1, 1288($t0)
	sw $t1, 1036($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 272($t0)
	sw $t1, 16($t0)
	# draw e
	addi $t0, $t0, -232
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 528($t0)
	sw $t1, 768($t0)
	sw $t1, 784($t0)
	sw $t1, 1024($t0)
	sw $t1, 1040($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1280($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	# draw r
	addi $t0, $t0, 28
	sw $t1, 0($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1536($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	# jump back to selection for play or quit
	j playorquit

WinScreen:
	# Draw You Won screen
	li $t0, BASE_ADDRESS
	li $t1, WHITE
	addi $t0, $t0, 5728	# load starting address of 'You Won'
	# draw Y
	sw $t1, 0($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 272($t0)
	sw $t1, 16($t0)
	sw $t1, 776($t0)
	sw $t1, 1032($t0)
	sw $t1, 1288($t0)
	# draw o
	addi $t0, $t0, 24
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 272($t0)
	# draw u
	addi $t0, $t0, 24
	sw $t1, 0($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 272($t0)
	
	# draw W
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 8032
	sw $t1, 1540($t0)
	sw $t1, 1288($t0)
	sw $t1, 1548($t0)
	sw $t1, 256($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 528($t0)
	sw $t1, 768($t0)
	sw $t1, 784($t0)
	sw $t1, 1024($t0)
	sw $t1, 1040($t0)
	sw $t1, 1280($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1552($t0)
	# draw o
	addi $t0, $t0, 280
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 272($t0)
	# draw n
	addi $t0, $t0, 24
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 272($t0)
	# jump back to selection for play or quit
	j playorquit
# END PROGRAM
EndProgram:
	jal ClearScreen
	# Draw End screen
	li $t0, BASE_ADDRESS
	li $t1, WHITE
	addi $t0, $t0, 6488	# load starting address of 'end'
	# e
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 528($t0)
	sw $t1, 768($t0)
	sw $t1, 784($t0)
	sw $t1, 1024($t0)
	sw $t1, 1040($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1280($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	# n
	addi $t0, $t0, 280
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 272($t0)
	# d
	addi $t0, $t0, 24
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1040($t0)
	sw $t1, 784($t0)
	sw $t1, 528($t0)
	sw $t1, 1552($t0)
	sw $t1, 16($t0)
	sw $t1, -240($t0)
	sw $t1, -496($t0)
	sw $t1, -752($t0)
	
	li $v0, 10 
	syscall
######################################################################
#				Functions
######################################################################
HandleKeyPress: 
	# a0 holds the keystroke address
	# check which key was pressed
	lw $t0, 4($a0)		
	lw $t2, Character_Position	# get character position
	beq, $t0, 0x61, pressed_a
	beq, $t0, 0x77, pressed_w
	beq, $t0, 0x64, pressed_d
	beq, $t0, 0x70, pressed_p
	
	pressed_a: # Shift character left
		addi $t2, $t2, -8
		sw $zero, DoubleJump
		b keypress_done
	pressed_w: 
		# Jump iff there is a platform below
		lw $t5, DoubleJump
		beq $t5, 1, doublejump
		li $t3, BASE_ADDRESS
		add $t3, $t3, $t2
		addi $t3, $t3, 1532 	# go to block below left leg
		lw $t1, 0($t3)
		beq $t1, RED, jump
		addi $t3, $t3, 8	# go to block below right leg
		lw $t1, 0($t3)
		beq $t1, RED, jump
		b keypress_done
		jump:	
			addi $t2, $t2, -1024
			li $t0, 1		# Load 1 into DoubleJump
			sw $t0, DoubleJump
			b keypress_done
		doublejump:	
			addi $t2, $t2, -1280
			sw $zero, DoubleJump	# Load 0 into DoubleJump
			b keypress_done
	pressed_d: # shift character right
		addi $t2, $t2, 8
		sw $zero, DoubleJump
		b keypress_done
	pressed_p: # restart
		li $v0, 1
		sw $zero, DoubleJump
		b keypress_done
	keypress_done:
		sw $t2, Character_Position 	# store new character position
		jr $ra   
	
#################################################################
ClearScreen: 
	li $t0, BASE_ADDRESS
	li $t1, 0		# initialize counter
	li $t3, BLACK
	clearing_screen:
		beq $t1, LAST_PIXEL, screen_cleared
		sw $t3, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 4
		j clearing_screen
	screen_cleared: jr $ra
DrawPlatform:
	# Start_position in $a1
	# Colour in $a2 (Red when drawing, Black when erasing)
	li $t0, BASE_ADDRESS	
	li $t2, 0
	add $t0, $t0, $a1
	loop: beq $t2, PLATFORM_SIZE, end
	sw $a2, 0($t0)
	addi $t0, $t0, 4		# Increment address by 4
	addi $t2, $t2, 1
	j loop		
	end: jr $ra
DrawCharacter:
	# a1 holds green when character should be drawn, black for erase
	# a2, holds blue when character should be drawn, black for erase
	
	li $t0, BASE_ADDRESS
	lw $t1, Character_Position
	add $t0, $t0, $t1		
	sw $a1, 0($t0)				
	addi $t0, $t0, NEXT_ROW		
	sw $a2, ($t0)				
	sw $a1, -4($t0)		
	sw $a1, -8($t0)	
	sw $a1, 4($t0)
	sw $a1, 8($t0)
	addi $t0, $t0, NEXT_ROW
	sw $a2, ($t0)
	addi $t0, $t0, NEXT_ROW
	sw $a2, ($t0)
	sw $a2, -4($t0)
	sw $a2, 4($t0)
	addi $t0, $t0, NEXT_ROW
	sw $a2, -4($t0)
	sw $a2, 4($t0)
	addi $t0, $t0, NEXT_ROW
	sw $a2, -4($t0)
	sw $a2, 4($t0)
	jr $ra
DrawItem:
	# Start_position in $a1
	# Colour in $a2 (Red when drawing, Black when erasing)
	li $t0, BASE_ADDRESS
	add $t0, $t0, $a1
	sw $a2, ($t0)
	sw $a2, -256($t0)
	sw $a2, -4($t0)
	sw $a2, 4($t0)
	sw $a2, 256($t0)
	jr $ra
DrawScore:
	lw $t0, PickUps
	li $t1, 0
	li $t2, BASE_ADDRESS
	addi $t2, $t2, 256		# start position for score
	li $t3, GOLD
	while:
		beq $t1, $t0, donescore
		addi $t2, $t2, 12
		sw $t3, 0($t2)
		sw $t3, 4($t2)
		sw $t3, 256($t2)
		sw $t3, 260($t2)
		addi $t1, $t1, 1	
		j while
	donescore:
		jr $ra
		
#################################################################
ValidCharacterPosition:
	# Adjusts character's positions so that it is valid.
	lw $t1, Character_Position			# position of character stored in t1
	movedown:
		bge $t1, $zero, check_off_screen
		addi $t1, $t1, NEXT_ROW
		j movedown
	check_off_screen:
	li $t3, NEXT_ROW
	div $t1, $t3					# position/256	
	mfhi $t1					# store remainder in t1
	mflo $t2					# store low into t2
	blt $t1, 8, moveright
	bgt $t1, 244, moveleft
	j updated_character
	moveright:
		sll $t1, $t2, 8
		addi $t1, $t1, 8 
		sw $t1, Character_Position
		j updated_character
	moveleft:
		sll $t1, $t2, 8
		addi $t1, $t1, 244 
		sw $t1, Character_Position
		j updated_character
	updated_character:
		# check if character is on the platform
		li $t2, RED
		lw $t0, Character_Position		# t0 holds offset for head
		addi $t0, $t0, 1532			# offset for block right below left leg
		la $t1, BASE_ADDRESS	
		add $t1, $t1, $t0			# go to address of block below left leg
		lw $t3, 0($t1)
		beq $t3, $t2, no_gravity
		addi $t1, $t1, 8			# go to address of block below right leg
		lw $t3, 0($t1)
		beq $t3, $t2, no_gravity
		j gravity
		no_gravity:
			jr $ra
		gravity:
			lw $t0, Character_Position	# load character position
			addi $t0, $t0, 256		# move down
			sw $t0, Character_Position	# store new position
			jr $ra	
ValidPlatformPositions:
	la $t0, PlatformLoc
	la $t1, Platform_Directions
	lw $t2, 0($t0)
	beq $t2, 5376, moveright_platform1	# goes off left side of screen, move right
	beq $t2, 5592, moveleft_platform1	# goes off right side, move left
	j check_platform2			# moving platform 1 location is valid, check platform 2
	moveright_platform1:
		li $t2, 4
		sw $t2, 0($t1)
		j check_platform2
	moveleft_platform1:
		li $t2, -4
		sw $t2, 0($t1)
		j check_platform2
	check_platform2:
		lw $t2, 4($t0)
		beq $t2, 6656, moveright_platform2	# goes off left side of screen, move right
		beq $t2, 6872, moveleft_platform2	# goes off right side, move left
		j updated_platforms			# moving platform 2 has valid location, return
	moveright_platform2:
		li $t2, 4
		sw $t2, 4($t1)
		j updated_platforms
	moveleft_platform2:
		li $t2, -4
		sw $t2, 4($t1)
		j updated_platforms
	updated_platforms:
		jr $ra
ValidItemPosition:
	la $t0, ItemLoc
	la $t1, Item_Directions
	lw $t2, 0($t0)
	beq $t2, 1284, moveright_Item1			# item 1 goes off left side of the screen, shift right
	beq $t2, 1528, moveleft_Item1			# item 1 goes off right side, shift left
	j check_Item2					# item 1 has a valid location, check item 2
	moveright_Item1:
		li $t2, 4
		sw $t2, 0($t1)
		j check_Item2
	moveleft_Item1:
		li $t2, -4
		sw $t2, 0($t1)
		j check_Item2
	check_Item2:
		lw $t2, 4($t0)
		beq $t2, 4356, moveright_Item2		# item 2 goes off left side of the screen, shift right
		beq $t2, 4600, moveleft_Item2		# item 2 goes off right side, shift left
		j updated_Items				# item 2 has a valid location, return
	moveright_Item2:
		li $t2, 4
		sw $t2, 4($t1)
		j updated_Items
	moveleft_Item2:
		li $t2, -4
		sw $t2, 4($t1)
		j updated_Items
	updated_Items:
		jr $ra
CheckPickups:
	# a0 holds offset for pickup location
	# a1 holds address of item_status to update
	lw $t3, 0($a1)
	bne $t3, 0, not_collected	# If it is already updated don't do anything
	li $t2, YELLOW
	li $t0, BASE_ADDRESS
	add $t0, $t0, $a0
	# checks if item is not yellow (i.e collected)
	lw $t1, 0($t0)
	bne $t1, $t2, collected		
	lw $t1, -256($t0)
	bne $t1, $t2, collected
	lw $t1, 256($t0)
	bne $t1, $t2, collected
	lw $t1, -4($t0)
	bne $t1, $t2, collected
	lw $t1, 4($t0)
	bne $t1, $t2, collected
	j not_collected
	collected:
		# erase collected item
		li $t2, BLACK
		sw $t2, 0($t0)
		sw $t2, 4($t0)
		sw $t2, -4($t0)
		sw $t2, 256($t0)
		sw $t2, -256($t0)
		# set item status to be collected
		li $t0, 1
		sw $t0, 0($a1)
		jr $ra
	not_collected:
		jr $ra
