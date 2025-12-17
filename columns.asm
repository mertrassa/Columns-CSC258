################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Berke Basak, 1011573049
# Student 2: Mert Rassa, 1011445287
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000

copy: .space 4096
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

RED: .word 0xff0000 #HEX value for RED
GREEN: .word 0x00ff00 #HEX value for GREEN
BLUE: .word 0x0000ff #HEX value for BLUE
YELLOW: .word 0xffff00 #HEX value for YELLOW
PURPLE: .word 0xff00ff #HEX value for PURPLE
CYAN:   .word 0x00ffff #HEX value for CYAN
WHITE:  .word 0xffffff #HEX value for WHITE
BLACK: .word 0x000000 #HEX value for BLACK
BACKGROUND: .word 0x000630 #HEX value for DARK BLUE
SCORE_COLOR: .word 0xfffffe #HEX value for WHITE, but different than game area borders.
PREVIEW_COLOR: .word 0x777700 #HEX value for DARK YELLOW, for highlighting where the column will end up if dropped
FIXTIME_FOR_GRAVITY: .word 0x000030 # Fix starting value for gravity.

TIME_FOR_MUSIC: .word 0x00001E #Fix value for music timer
MUSIC_SHEET: .word 0x000039, 0x000040, 0x000048, 0x000040, 0x00003b, 0x000040, 0x000039, 0x000040, 0x000044, 0x000040, 0x00003b, 0x000040, 0x000039, 0x000040, 0x000044, 0x000040, 0x000043, 0x000040
  # https://www.youtube.com/watch?v=pRDMZmmuIQw I used this link to find the notes of first 10 seconds of column theme music, then mapped them by hand.
  # LA MI DO(upper octave) MI SI MI LA MI SOL MI
  # A E C E B E A E G# E B E A E G# E G E 
  # Used the following link to find right values of pitches https://www.studocu.vn/vn/document/ho-chi-minh-city-university-of-technology/computer-architecture/syscall-124/88486486

##############################################################################
# Mutable Data
##############################################################################

TIME_FOR_GRAVITY: .word 0x000030 #Variable value for gravity, to be changed each game depending on difficulty

MUSIC_PAUSE_COUNTER: .word 0x00000E #Makes the pause between notes
NOTE_COUNTER: .word 0x000000 #At which note are we? 
PASSED_START_SCREEN: .word 0x000000
PASSED_DIFFICULTY_SCREEN: .word 0x000000
GAME_ENDED: .word 0x000000
TIMER: .word 0x000030 #Holds time for gravityon difficulty, 10000 shift right logical by below numbers)
DIFFICULTY: .word 0x000001 #0 (NO GRAVITY), 1 is easy(LOW GRAVITY), 2 is medium(MEDIUM GRAVITY), 3 is hard(HIGH GRAVITY), 4 is INSANE (0 and 4 are easter eggs)
##############################################################################
# Code
##############################################################################
	.text
	.globl main

#####################################################################################


#####################################################################################

    # Run the game.
main:
        # Initialize the game
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    la $t6, copy            # $t6 = base address for the copy
        #Draws the top Line of the playing space by calling the draw_line_horizontal method
    jal draw_start_title
    j total_loop
    

total_loop: #controls all the game, necessary to play continuous music
    lw $t9, MUSIC_PAUSE_COUNTER
    beq $t9, $zero, music
    addi $t9, $t9, -1
    sw $t9, MUSIC_PAUSE_COUNTER
    
    lw $t9, PASSED_START_SCREEN
    beq $t9, $zero, startscreen_loop
    
    lw $t9, PASSED_DIFFICULTY_SCREEN
    beq $t9, $zero, difficulty_screen_loop
    
    lw $t9, GAME_ENDED
    beq $t9, $zero, ingame_loop

    j endgame_loop
    
music:
    li $t9, 14
    sw $t9, MUSIC_PAUSE_COUNTER
    la $t9, MUSIC_SHEET
    lw $t8, NOTE_COUNTER
    add $t9, $t9, $t8
    li $v0, 31       
    lw $a0, 0($t9)
    li $a1, 238 # duration ms
    li $a2, 0 # instrument
    li $a3, 50  # volume
    syscall
    lw $t8, NOTE_COUNTER
    li $t9, 68
    beq $t8, $t9, reset_note_counter
    addi $t9, $t8, 4
    sw $t9, NOTE_COUNTER
    jr $ra
    
reset_note_counter:
    li $t9, 0
    sw $t9, NOTE_COUNTER
    jr $ra

#Start of START SCREEN
draw_start_title: # Draws "PRESS SPACE TO START" Screen
    addi $sp, $sp, -4 
    sw $ra, 0($sp)
    jal blackout  
    jal random_column_generator_title
    lw $t2, WHITE
    addi $a1, $zero, 272
    jal wr_P
    addi $a1, $zero, 292
    jal wr_R
    addi $a1, $zero, 312
    jal wr_E
    addi $a1, $zero, 332
    jal wr_S
    addi $a1, $zero, 352
    jal wr_S

    addi $a1, $zero, 1288
    jal wr_S
    addi $a1, $zero, 1308
    jal wr_P
    addi $a1, $zero, 1200
    jal wr_AA
    addi $a1, $zero, 1364
    jal wr_C
    addi $a1, $zero, 1384
    jal wr_E


    addi $a1, $zero, 2348
    jal wr_T
    addi $a1, $zero, 2368
    jal wr_O

    addi $a1, $zero, 3216
    jal wr_S
    addi $a1, $zero, 3236
    jal wr_T
    addi $a1, $zero, 3256
    jal wr_A
    addi $a1, $zero, 3276
    jal wr_R
    addi $a1, $zero, 3296
    jal wr_T
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

startscreen_loop:
    lw $t7, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t7)                  # Load first word from keyboard
    beq $t8, 1, startscreen_controls      # If first word 1, key is pressed
    jal sleep
    j total_loop

startscreen_controls:                 
    lw $a0, 4($t7)                  # Load second word from keyboard
    beq $a0, 0x20, look_for_SPACE
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x61, collision_check_A     # Check if the key a was pressed
    beq $a0, 0x64, collision_check_D     # Check if the key d was pressed
    j total_loop

look_for_SPACE:
    addi $t1, $zero, 1
    sw $t1, PASSED_START_SCREEN
    jal draw_difficulty_screen
    j total_loop
#End of START SCREEN

#Start of DIFFICULTY SCREEN
draw_difficulty_screen:
    addi $sp, $sp, -4 
    sw $ra, 0($sp)
    jal blackout  
    lw $t2, WHITE
    addi $a1, $zero, 272
    jal wr_P
    addi $a1, $zero, 292
    jal wr_R
    addi $a1, $zero, 312
    jal wr_E
    addi $a1, $zero, 332
    jal wr_S
    addi $a1, $zero, 352
    jal wr_S

    addi $a1, $zero, 1508
    jal wr_1
    addi $a1, $zero, 1292
    jal wr_E
    addi $a1, $zero, 1312
    jal wr_A
    addi $a1, $zero, 1332
    jal wr_S
    addi $a1, $zero, 1352
    jal wr_Y

    addi $a1, $zero, 2404
    jal wr_2
    addi $a1, $zero, 2200
    jal wr_M
    addi $a1, $zero, 2224
    jal wr_I
    addi $a1, $zero, 2240
    jal wr_D

    addi $a1, $zero, 3300
    jal wr_3
    addi $a1, $zero, 3084
    jal wr_H
    addi $a1, $zero, 3104
    jal wr_A
    addi $a1, $zero, 3124
    jal wr_R
    addi $a1, $zero, 3144
    jal wr_D
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

difficulty_screen_loop:
    lw $t7, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t7)                  # Load first word from keyboard
    beq $t8, 1, difficulty_screen_controls      # If first word 1, key is pressed
    jal sleep
    j total_loop
    
difficulty_screen_controls:
    lw $a0, 4($t7)                  # Load second word from keyboard
    beq $a0, 0x30, respond_to_no_dif
    beq $a0, 0x31, respond_to_easy_dif
    beq $a0, 0x32, respond_to_mid_dif     
    beq $a0, 0x33, respond_to_hard_dif     
    beq $a0, 0x34, respond_to_insane_dif
    j total_loop

#Start of GRAVITY 
gravity:
    lw $t8, DIFFICULTY
    addi $t9, $zero, 1
    beq $t8, $t9, easy_gravity
    addi $t9, $zero, 2
    beq $t8, $t9, medium_gravity
    addi $t9, $zero, 3
    beq $t8, $t9, hard_gravity
    j insane_gravity

easy_gravity:
    lw $t9, TIME_FOR_GRAVITY
    srl $t9, $t9, 1
    sw $t9, TIMER
    j collision_check_S
    
medium_gravity:
    lw $t9, TIME_FOR_GRAVITY
    srl $t9, $t9, 2 
    sw $t9, TIMER
    j collision_check_S
  
hard_gravity:
    lw $t9, TIME_FOR_GRAVITY
    srl $t9, $t9, 3 
    sw $t9, TIMER
    j collision_check_S

insane_gravity:
    lw $t9, TIME_FOR_GRAVITY
    srl $t9, $t9, 4
    sw $t9, TIMER
    j collision_check_S
#End of GRAVITY 

#Start of DIFFICULTY SETTINGS 
respond_to_no_dif:
    add $t8, $zero, $zero
    sw $t8, DIFFICULTY
    addi $t8, $zero, 1
    sw $t8, PASSED_DIFFICULTY_SCREEN
    j draw_game
respond_to_easy_dif:
    addi $t8, $zero, 1
    sw $t8, DIFFICULTY
    sw $t8, PASSED_DIFFICULTY_SCREEN
    j draw_game
respond_to_mid_dif:
    addi $t8, $zero, 2
    sw $t8, DIFFICULTY
    sw $t8, PASSED_DIFFICULTY_SCREEN
    j draw_game
  
respond_to_hard_dif:
    addi $t8, $zero, 3
    sw $t8, DIFFICULTY
    sw $t8, PASSED_DIFFICULTY_SCREEN
    j draw_game
    
respond_to_insane_dif:
    addi $t8, $zero, 4
    sw $t8, DIFFICULTY
    sw $t8, PASSED_DIFFICULTY_SCREEN
    j draw_game
#End of DIFFICULTY SETTINGS

#End of DIFFICULTY SCREEN


#Start of INGAME SCREEN    
draw_game:
    jal blackout

    #Draws the top Line of the playing space by calling the draw_line_horizontal method
    addi $a0, $zero, 10 
    addi $a1, $zero, 10 
    addi $a2, $zero, 8 
    lw $a3, WHITE
    jal draw_line_horizontal       
    
    #Draws the bottom Line of the playing space by calling the draw_line_horizontal method
    addi $a0, $zero, 10
    addi $a1, $zero, 29
    addi $a2, $zero, 8
    lw $a3, WHITE
    jal draw_line_horizontal
    
    #Draws the left line of the playing space by calling the draw_line_vertical method
    addi $a0, $zero, 10
    addi $a1, $zero, 11
    addi $a2, $zero, 18
    lw $a3, WHITE
    jal draw_line_vertical
    
    #Draws the right line of the playing space by calling the draw_line_vertical method
    addi $a0, $zero, 17
    addi $a1, $zero, 11
    addi $a2, $zero, 18
    lw $a3, WHITE
    jal draw_line_vertical

    #Writes the initial score 00000
    addi $a1, $zero, 2
    addi $a2, $zero, 3
    jal write_0
    addi $a1, $zero, 8
    addi $a2, $zero, 3
    jal write_0
    addi $a1, $zero, 14
    addi $a2, $zero, 3
    jal write_0
    addi $a1, $zero, 20
    addi $a2, $zero, 3
    jal write_0
    addi $a1, $zero, 26
    addi $a2, $zero, 3
    jal write_0
    
    #Creates the first random column
    jal random_column_generator
    jal preview_generator #Generate the preview of the first column
    j total_loop

ingame_loop:
    # 1a. Check if key has been pressed
    lw $t7, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t7)                  # Load first word from keyboard
    beq $t8, 1, ingame_controls     # If first word 1, key is pressed
    jal sleep
    lw $t9, DIFFICULTY
    beq $t9, $zero, total_loop #So that if difficulty = 0, then no gravity (hidden feature to test)
    lw $t9, TIMER
    beq $t9, $zero, gravity
    lw $t9, TIMER
    addi $t9, $t9, -1
    sw $t9, TIMER
    j total_loop

ingame_controls:
    #Adapted from the starter code for the keyboard
    lw $a0, 4($t7)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x77, collision_check_W     # Check if the key w was pressed
    beq $a0, 0x61, collision_check_A     # Check if the key a was pressed
    beq $a0, 0x64, collision_check_D   # Check if the key d was pressed
    beq $a0, 0x73, collision_check_S   # Check if the key s was pressed
    beq $a0, 0x72, respond_to_R     # Check if the key r was pressed
    beq $a0, 0x20, respond_to_space # Check if the key space was pressed
    beq $a0, 0x70, respond_to_P # check if the key p was pressed
    j total_loop
#End of INGAME SCREEN

#Start of ENDGAME SCREEN
draw_game_over:
    jal blackout  
    lw $t2, WHITE
    addi $a1, $zero, 280
    jal wr_G
    addi $a1, $zero, 300
    jal wr_A
    addi $a1, $zero, 320
    jal wr_M
    addi $a1, $zero, 344
    jal wr_E

    addi $a1, $zero, 1048
    jal wr_O
    addi $a1, $zero, 1068
    jal wr_V
    addi $a1, $zero, 1092
    jal wr_E
    addi $a1, $zero, 1112
    jal wr_R

    addi $a1, $zero, 1936
    jal wr_S
    addi $a1, $zero, 1956
    jal wr_C
    addi $a1, $zero, 1976
    jal wr_O
    addi $a1, $zero, 1996
    jal wr_R
    addi $a1, $zero, 2016
    jal wr_E
    
    #Double dots
    addi $a1, $zero, 2164
    add $t1, $a1, $t0
    sw $t2, 0($t1)
    addi $t1, $t1, 256
    sw $t2, 0($t1)
    
            first_digit_over:
            addi $t2, $zero, 10
            div $s7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 26
            addi $a2, $zero, 23

            first_digit_0_over:
            add $t3, $zero, $zero
            bne $t3, $t5, first_digit_1_over
            jal write_0
            
            first_digit_1_over:
            addi $t3, $zero, 1
            bne $t3, $t5, first_digit_2_over
            jal write_1_bigger
            
            first_digit_2_over:
            addi $t3, $zero, 2
            bne $t3, $t5, first_digit_3_over
            jal write_2_bigger
            
            first_digit_3_over:
            addi $t3, $zero, 3
            bne $t3, $t5, first_digit_4_over
            jal write_3_bigger
            
            first_digit_4_over:
            addi $t3, $zero, 4
            bne $t3, $t5, first_digit_5_over
            jal write_4
            
            first_digit_5_over:
            addi $t3, $zero, 5
            bne $t3, $t5, first_digit_6_over
            jal write_5
            
            first_digit_6_over:
            addi $t3, $zero, 6
            bne $t3, $t5, first_digit_7_over
            jal write_6
            
            first_digit_7_over:
            addi $t3, $zero, 7
            bne $t3, $t5, first_digit_8_over
            jal write_7
            
            first_digit_8_over:
            addi $t3, $zero, 8
            bne $t3, $t5, first_digit_9_over
            jal write_8
            
            first_digit_9_over:
            addi $t3, $zero, 9
            bne $t3, $t5, second_digit_over
            jal write_9
            
            
 second_digit_over:
            addi $t2, $zero, 10
            div $t7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 20
            addi $a2, $zero, 23

            second_digit_0_over:
            add $t3, $zero, $zero
            bne $t3, $t5, second_digit_1_over
            jal write_0
            
            second_digit_1_over:
            addi $t3, $zero, 1
            bne $t3, $t5, second_digit_2_over
            jal write_1_bigger
            
            second_digit_2_over:
            addi $t3, $zero, 2
            bne $t3, $t5, second_digit_3_over
            jal write_2_bigger
            
            second_digit_3_over:
            addi $t3, $zero, 3
            bne $t3, $t5, second_digit_4_over
            jal write_3_bigger
            
            second_digit_4_over:
            addi $t3, $zero, 4
            bne $t3, $t5, second_digit_5_over
            jal write_4
            
            second_digit_5_over:
            addi $t3, $zero, 5
            bne $t3, $t5, second_digit_6_over
            jal write_5
            
            second_digit_6_over:
            addi $t3, $zero, 6
            bne $t3, $t5, second_digit_7_over
            jal write_6
            
            second_digit_7_over:
            addi $t3, $zero, 7
            bne $t3, $t5, second_digit_8_over
            jal write_7
            
            second_digit_8_over:
            addi $t3, $zero, 8
            bne $t3, $t5, second_digit_9_over
            jal write_8
            
            second_digit_9_over:
            addi $t3, $zero, 9
            bne $t3, $t5, third_digit_over
            jal write_9    
            
 third_digit_over:
            addi $t2, $zero, 10
            div $t7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 14
            addi $a2, $zero, 23

            third_digit_0_over:
            add $t3, $zero, $zero
            bne $t3, $t5, third_digit_1_over
            jal write_0
            
            third_digit_1_over:
            addi $t3, $zero, 1
            bne $t3, $t5, third_digit_2_over
            jal write_1_bigger
            
            third_digit_2_over:
            addi $t3, $zero, 2
            bne $t3, $t5, third_digit_3_over
            jal write_2_bigger
            
            third_digit_3_over:
            addi $t3, $zero, 3
            bne $t3, $t5, third_digit_4_over
            jal write_3_bigger
            
            third_digit_4_over:
            addi $t3, $zero, 4
            bne $t3, $t5, third_digit_5_over
            jal write_4
            
            third_digit_5_over:
            addi $t3, $zero, 5
            bne $t3, $t5, third_digit_6_over
            jal write_5
            
            third_digit_6_over:
            addi $t3, $zero, 6
            bne $t3, $t5, third_digit_7_over
            jal write_6
            
            third_digit_7_over:
            addi $t3, $zero, 7
            bne $t3, $t5, third_digit_8_over
            jal write_7
            
            third_digit_8_over:
            addi $t3, $zero, 8
            bne $t3, $t5, third_digit_9_over
            jal write_8
            
            third_digit_9_over:
            addi $t3, $zero, 9
            bne $t3, $t5, fourth_digit_over
            jal write_9 
            
 fourth_digit_over:
            addi $t2, $zero, 10
            div $t7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 8
            addi $a2, $zero, 23

            fourth_digit_0_over:
            add $t3, $zero, $zero
            bne $t3, $t5, fourth_digit_1_over
            jal write_0
            
            fourth_digit_1_over:
            addi $t3, $zero, 1
            bne $t3, $t5, fourth_digit_2_over
            jal write_1_bigger
            
            fourth_digit_2_over:
            addi $t3, $zero, 2
            bne $t3, $t5, fourth_digit_3_over
            jal write_2_bigger
            
            fourth_digit_3_over:
            addi $t3, $zero, 3
            bne $t3, $t5, fourth_digit_4_over
            jal write_3_bigger
            
            fourth_digit_4_over:
            addi $t3, $zero, 4
            bne $t3, $t5, fourth_digit_5_over
            jal write_4
            
            fourth_digit_5_over:
            addi $t3, $zero, 5
            bne $t3, $t5, fourth_digit_6_over
            jal write_5
            
            fourth_digit_6_over:
            addi $t3, $zero, 6
            bne $t3, $t5, fourth_digit_7_over
            jal write_6
            
            fourth_digit_7_over:
            addi $t3, $zero, 7
            bne $t3, $t5, fourth_digit_8_over
            jal write_7
            
            fourth_digit_8_over:
            addi $t3, $zero, 8
            bne $t3, $t5, fourth_digit_9_over
            jal write_8
            
            fourth_digit_9_over:
            addi $t3, $zero, 9
            bne $t3, $t5, fifth_digit_over
            jal write_9 
            
 fifth_digit_over:
            addi $t2, $zero, 10
            div $t7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 2
            addi $a2, $zero, 23

            fifth_digit_0_over:
            add $t3, $zero, $zero
            bne $t3, $t5, fifth_digit_1_over
            jal write_0
            
            fifth_digit_1_over:
            addi $t3, $zero, 1
            bne $t3, $t5, fifth_digit_2_over
            jal write_1_bigger
            
            fifth_digit_2_over:
            addi $t3, $zero, 2
            bne $t3, $t5, fifth_digit_3_over
            jal write_2_bigger
            
            fifth_digit_3_over:
            addi $t3, $zero, 3
            bne $t3, $t5, fifth_digit_4_over
            jal write_3_bigger
            
            fifth_digit_4_over:
            addi $t3, $zero, 4
            bne $t3, $t5, fifth_digit_5_over
            jal write_4
            
            fifth_digit_5_over:
            addi $t3, $zero, 5
            bne $t3, $t5, fifth_digit_6_over
            jal write_5
            
            fifth_digit_6_over:
            addi $t3, $zero, 6
            bne $t3, $t5, fifth_digit_7_over
            jal write_6
            
            fifth_digit_7_over:
            addi $t3, $zero, 7
            bne $t3, $t5, fifth_digit_8_over
            jal write_7
            
            fifth_digit_8_over:
            addi $t3, $zero, 8
            bne $t3, $t5, fifth_digit_9_over
            jal write_8
            
            fifth_digit_9_over:
            addi $t3, $zero, 9
            bne $t3, $t5, endgame_loop
            jal write_9 
    
    # 2a. Check for collisions

endgame_loop:
    # 1a. Check if key has been pressed
    lw $t7, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t7)                  # Load first word from keyboard
    beq $t8, 1, endscreen_controls     # If first word 1, key is pressed
    jal sleep
    j total_loop

endscreen_controls:                 
    lw $a0, 4($t7)                  # Load second word from keyboard
    beq $a0, 0x72, respond_to_R     # Check if the key r was pressed
    j total_loop
#End if ENDGAME SCREEN
    
collision_check_W: #Nothing to change for now
    j location_change_W
    
collision_check_A: 
    add $t1, $zero, $t0 #Store the address of the bitmap in t1
    add $t2, $zero, $s4 #Store the x offset of the current column
    sll $t2, $t2, 2 #Multiply by 4 to get the x value
    add $t1, $t1, $t2 #Add the x value to address
    add $t3, $zero, $s5 #Store the y offset of the current column
    sll $t3, $t3, 7 #Multiply by 128 to get the y value
    add $t1, $t1, $t3 #Location of the top pixel of the current column
    lw $t4, 252($t1) #Color of the pixel on the left is stored in t4
    lw $t5, BACKGROUND
    beq $t4, $t5, location_change_A
    j total_loop
    

collision_check_D: 
    add $t1, $zero, $t0 #Store the address of the bitmap in t1
    add $t2, $zero, $s4 #Store the x offset of the current column
    sll $t2, $t2, 2 #Multiply by 4 to get the x value
    add $t1, $t1, $t2 #Add the x value to address
    add $t3, $zero, $s5 #Store the y offset of the current column
    sll $t3, $t3, 7 #Multiply by 128 to get the y value
    add $t1, $t1, $t3 #Location of the top pixel of the current column
    lw $t4, 260($t1) #Color of the pixel on the right is stored in t4
    lw $t5, BACKGROUND
    beq $t4, $t5, location_change_D
    j total_loop


collision_check_S:
    add $t1, $zero, $t0 #Store the address of the bitmap in t1
    add $t2, $zero, $s4 #Store the x offset of the current column
    sll $t2, $t2, 2 #Multiply by 4 to get the x value
    add $t1, $t1, $t2 #Add the x value to address
    add $t3, $zero, $s5 #Store the y offset of the current column
    sll $t3, $t3, 7 #Multiply by 128 to get the y value
    add $t1, $t1, $t3 #Location of the top pixel of the current column
    lw $t4, 384($t1) #Color of the pixel on the bottom is stored in t4
    lw $t5, BACKGROUND
    beq $t4, $t5, location_change_S_Checker
    j preview_color_checker_s
    location_change_S_Checker:
    lw $t4, 512($t1)
    bne $t4, $t5, location_change_S_preview
    j location_change_S
    preview_color_checker_s:
    lw $t7, PREVIEW_COLOR
    lw $t4, 384($t1)
    beq $t4, $t7, location_change_S_preview
    j matching
    
	# 2c. Update locations (capsules)
location_change_W: #Location is not changed
    j respond_to_W

location_change_A:
    addi $s4, $s4, -1
    j respond_to_A

location_change_S:
    addi $s5, $s5, 1
    j respond_to_S
    
location_change_S_preview:
    addi $s5, $s5, 1
    j respond_to_S_preview
    
location_change_D:
    addi $s4, $s4, 1
    j respond_to_D
    
respond_to_space: ### We always have to check for matching if space is pressed because the column will go to last possible location
       add $t1, $zero, $t0 #Store the address of the bitmap in $t1
       add $t2, $zero, $s4 #Store the x offset of the current column
       sll $t2, $t2, 2 #Multiply by 4 to get the x value
       add $t1, $t1, $t2 #Add the x value to address
       add $t3, $zero, $s5 #Store the y offset of the current column
       sll $t3, $t3, 7 #Multiply by 128 to get the y value
       add $t1, $t1, $t3 #Location of the top pixel of the current column
       
       addi $t4, $zero, 3 #Hold 3 in t4, this will be the starting point of the loop
       lw $t3, BACKGROUND #t3 holds the color of the background
       lw $t7, PREVIEW_COLOR #t7 holds the color of the preview
       Loop_space:
       add $t5, $t1, $zero #t5 stores the starting point of the column
       sll $t9, $t4, 7 #we iterate and check the pixels under our column
       add $t5, $t5, $t9 #($t4-2)th column under ours
       lw $t2, 0($t5) #hold the color of the ($t4-2)th column
       beq $t3, $t2, increment_t4
       beq $t7, $t2, increment_t4
       sub $t5, $t5, $t9 #Get back the starting point of the column
       sw $t3, 0($t5) #Paint the old location of the column to background
       sw $t3, 128($t5) #Paint the old location of the column to background
       sw $t3, 256($t5) #Paint the old location of the column to background
       add $t5, $t5, $t9 #Get the location of the first point that is not background
       sw $s3, -128($t5)
       sw $s2, -256($t5)
       sw $s1, -384($t5)
       j matching
       increment_t4: addi $t4, $t4, 1
       j Loop_space
    
    
respond_to_R:
    add $t9, $zero, $zero
    sw $t9, PASSED_DIFFICULTY_SCREEN
    sw $t9, GAME_ENDED
    lw $t9, FIXTIME_FOR_GRAVITY
    sw $t9, TIME_FOR_GRAVITY
    move $t1, $zero
    move $t2, $zero
    move $t3, $zero
    move $t4, $zero
    move $t5, $zero
    move $t7, $zero
    move $t8, $zero
    move $t9, $zero

    move $a0, $zero
    move $a1, $zero
    move $a2, $zero
    move $a3, $zero
    
    move $s0, $zero
    move $s6, $zero
    move $s7, $zero

    
    
    jal draw_difficulty_screen
    j total_loop

respond_to_P:
    addi $a1, $zero, 23
    addi $a2, $zero, 15 
    sll $a1, $a1, 2 #x location
    sll $a2, $a2, 7 #y location
    add $t1, $a1, $t0
    add $t1, $t1, $a2 #t1 holds the starting position
    lw $t2, SCORE_COLOR
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -128
    sw $t2, 0($t1)
    addi $t1, $t1, 256
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    pause:
        lw $t7, ADDR_KBRD
        lw $t8, 0($t7)
        add $t4, $zero, $zero
	    beq $t8, $t4, pause #If there is no key pushed continue pausing
	    lw $t8, 4($t7)
	    beq $t8, 0x70, stop_pause #if p is pushed again stop pausing
	    beq $t8, 0x72, stop_pause_R     # Check if the key r was pressed
	    beq $t8, 0x71, stop_pause_Q     # Check if the key q was pressed
	    j pause
	stop_pause:
	addi $a1, $zero, 23
    addi $a2, $zero, 15 
    sll $a1, $a1, 2 #x location
    sll $a2, $a2, 7 #y location
    add $t1, $a1, $t0
    add $t1, $t1, $a2 #t1 holds the starting position
    lw $t2, BACKGROUND
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -128
    sw $t2, 0($t1)
    addi $t1, $t1, 256
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
	jr $ra
	
	stop_pause_R:
		addi $a1, $zero, 23
    addi $a2, $zero, 15 
    sll $a1, $a1, 2 #x location
    sll $a2, $a2, 7 #y location
    add $t1, $a1, $t0
    add $t1, $t1, $a2 #t1 holds the starting position
    lw $t2, BACKGROUND
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -128
    sw $t2, 0($t1)
    addi $t1, $t1, 256
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
	j respond_to_R
	
	stop_pause_Q:
	addi $a1, $zero, 23
    addi $a2, $zero, 15 
    sll $a1, $a1, 2 #x location
    sll $a2, $a2, 7 #y location
    add $t1, $a1, $t0
    add $t1, $t1, $a2 #t1 holds the starting position
    lw $t2, BACKGROUND
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -4
    sw $t2, 0($t1)
    addi $t1, $t1, -128
    sw $t2, 0($t1)
    addi $t1, $t1, 256
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
	j respond_to_Q
	
matching:
# The main logic used here is creating a copy bitmap and when there is a matching in the originial bitmap paint those points
# to white in the copy bitmap. After we check all the matching, those points are painted to black and then the pixel above those
# points are dropped. This logic was explained by Professor Engels during a lecture, we adapted that logic in our code.
    addi $v1, $zero, -1 #chain reaction 
    chain_counter: #If there is a chain reaction start here
    add $t1, $zero, $t6
    addi $t3, $zero, 4096 
    lw $t2, BACKGROUND 
    copy_background: #Makes every value of "copy" "BACKGROUND" 
        sw $t2, 0($t1)
        addi $t1, $t1, 4    
        addi $t3, $t3, -4  
        bne $t3, $zero, copy_background
        
    horizontal_match:
        jal begin_hmatch
        
    vertical_match:
        jal begin_vmatch
    
    #Paint the copy fully BACKGROUND
    
	#Check for horizontal mathcing: Start from the bottom left corner and move through all the pixels. If a mathcing happens in a row, then paint those points to white in the copy display.
	           #NEED A HORIZONTAL MATCHING CHECKER FUNCTION
	           #CALL THIS FUNCTION ON ALL ROWS
	#Check for vertical mathcing: Start from the bottom left corner and move through all the pixels. If a matching happens in a column, then paint those points to white in the copy display.
	           #NEED A VERTICAL MATCHING CHECKER FUNCTION
	           #CALL THIS FUNCTION ON ALL COLUMNS
	           
diagonal_mathcing_checking_45:
    addi $a0, $zero, 14
    addi $a1, $zero, 28
    addi $a2, $zero, 3
    jal diagonal_match_45
    addi $a0, $zero, 11
    addi $a1, $zero, 13
    addi $a2, $zero, 3
    jal diagonal_match_45
    addi $a0, $zero, 13
    addi $a1, $zero, 28
    addi $a2, $zero, 4
    jal diagonal_match_45
    addi $a0, $zero, 11
    addi $a1, $zero, 14
    addi $a2, $zero, 4
    jal diagonal_match_45
     addi $a0, $zero, 12
    addi $a1, $zero, 28
    addi $a2, $zero, 5
    jal diagonal_match_45
    addi $a0, $zero, 11
    addi $a1, $zero, 15
    addi $a2, $zero, 5
    jal diagonal_match_45
    
    
    length_6_checkings_45:
            addi $a0, $zero, 11
            addi $a1, $zero, 28
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 27
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 26
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 25
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 24
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 23
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 22
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 21
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 20
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 19
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 18
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 17
            addi $a2, $zero, 6
            jal diagonal_match_45
            addi $a0, $zero, 11
            addi $a1, $zero, 16
            addi $a2, $zero, 6
            jal diagonal_match_45        

diagonal_mathcing_checking_135:
    addi $a0, $zero, 13
    addi $a1, $zero, 28
    addi $a2, $zero, 3
    jal diagonal_match_135
    addi $a0, $zero, 16
    addi $a1, $zero, 13
    addi $a2, $zero, 3
    jal diagonal_match_135
    addi $a0, $zero, 14
    addi $a1, $zero, 28
    addi $a2, $zero, 4
    jal diagonal_match_135
    addi $a0, $zero, 16
    addi $a1, $zero, 14
    addi $a2, $zero, 4
    jal diagonal_match_135
     addi $a0, $zero, 15
    addi $a1, $zero, 28
    addi $a2, $zero, 5
    jal diagonal_match_135
    addi $a0, $zero, 16
    addi $a1, $zero, 15
    addi $a2, $zero, 5
    jal diagonal_match_135
    
    length_6_checkings_135:
            addi $a0, $zero, 16
            addi $a1, $zero, 28
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 27
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 26
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 25
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 24
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 23
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 22
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 21
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 20
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 19
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 18
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 17
            addi $a2, $zero, 6
            jal diagonal_match_135
            addi $a0, $zero, 16
            addi $a1, $zero, 16
            addi $a2, $zero, 6
            jal diagonal_match_135
        #CALL THESE FUNCTIONS FOR ALL DIAGONALS, DONE
        
        
#ITERATE THROUGH ALL THE PIXELS IN THE COPY.
    #If you find a white point, paint that location to BACKGROUND in the original bitmap
    #Count the number of white points, if this number is zero, break the loop, create a new column, NO MATCHES
    #If you have white points, then move their correspondence in the originial map to bottom.
		      #LOOP TO MATCHING AND CHECK FOR NEW MATCHES

    add $a0, $zero, $zero
    add $t1, $zero, $t6
    addi $t3, $zero, 4096
    add $t4, $zero, $t0
make_matched_background: #Makes every value of matched blocks "BACKGROUND" if that place in copy is white
    lw $t5, 0($t1)
    lw $t2, WHITE 
    bne $t5, $t2, continue_coloring
#####GRAVITY INCREASE FEAUTRE
    lw $t9, DIFFICULTY
    beq $t9, $zero, paint_background_plus_ScoreCalculation #If difficulty is 0, then there is no need to change the gravity since there is none.
    li $t8, 16 #Upper limit for gravity, fastest possible
    lw $t9, TIME_FOR_GRAVITY
    beq $t9, $t8, paint_background_plus_ScoreCalculation
    addi $t9, $t9, -1
    sw $t9, TIME_FOR_GRAVITY
##### 
    paint_background_plus_ScoreCalculation:
        lw $t5, DIFFICULTY #t5 holds the difficulty
        mult $t5, $t5, 100 #t5 holds the score coefficient
        add $s0, $s0, $t5 #s0 holds the number of pixels that are vanished so far, multiplies by the score coefficient for score calculation
        add $s7, $zero, $s0 #s7 holds the total score
        jal paint_it_bg
        j continue_coloring

continue_coloring:
    addi $t1, $t1, 4
    addi $t4, $t4, 4    
    addi $t3, $t3, -4  
    bne $t3, $zero, make_matched_background
    j lets_fall
    
lets_fall: #Blocks at the bottom fall if they are above background color
    beq $a0, $zero, endgame_cheeeeeeeeck
    jal sleep
    jal begin_iteration
    jal begin_check
    addi $v1, $v1, 1 #Count the number of chain reactions
    j chain_counter

endgame_cheeeeeeeeck:
    jal begin_endgame_condition_check
    j goto_generate_the_new_column
    

    
goto_generate_the_new_column:
    #This also writes the score
    addi $t1 $zero, -1
    beq $t1, $v1, do_not_add_the_chain_bonus
    addi $t7, $zero, 500
    lw $t2, DIFFICULTY
    mult $t7, $t7, $t2
    mult $t7, $t7, $v1
    add $s6, $s6, $t7 #s6 holds the points earned from the chain reactions
    add $s7, $s7, $s6 #Add the chain bonus
    do_not_add_the_chain_bonus: #If there is no chain bonus skip this step
    add $t1, $t0, $zero
    add $t3, $zero, $zero #Loop Variable
    addi $t2, $zero, 1156 #All of first 9 row +4, so we check whether we passed the next row or not
    lw $t4, BACKGROUND
    delete_score: #Loops through the score and paints to background and prepares it for the new score
        beq $t3, $t2, new_score
        sw $t4, 0($t1)
        addi $t1, $t1, 4
        addi $t3, $t3, 4
        j delete_score
    new_score:
        first_digit:
            addi $t2, $zero, 10
            div $s7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 26
            addi $a2, $zero, 3

            first_digit_0:
            add $t3, $zero, $zero
            bne $t3, $t5, first_digit_1
            jal write_0
            
            first_digit_1:
            addi $t3, $zero, 1
            bne $t3, $t5, first_digit_2
            jal write_1_bigger
            
            first_digit_2:
            addi $t3, $zero, 2
            bne $t3, $t5, first_digit_3
            jal write_2_bigger
            
            first_digit_3:
            addi $t3, $zero, 3
            bne $t3, $t5, first_digit_4
            jal write_3_bigger
            
            first_digit_4:
            addi $t3, $zero, 4
            bne $t3, $t5, first_digit_5
            jal write_4
            
            first_digit_5:
            addi $t3, $zero, 5
            bne $t3, $t5, first_digit_6
            jal write_5
            
            first_digit_6:
            addi $t3, $zero, 6
            bne $t3, $t5, first_digit_7
            jal write_6
            
            first_digit_7:
            addi $t3, $zero, 7
            bne $t3, $t5, first_digit_8
            jal write_7
            
            first_digit_8:
            addi $t3, $zero, 8
            bne $t3, $t5, first_digit_9
            jal write_8
            
            first_digit_9:
            addi $t3, $zero, 9
            bne $t3, $t5, second_digit
            jal write_9
            
            
 second_digit:
            addi $t2, $zero, 10
            div $t7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 20
            addi $a2, $zero, 3

            second_digit_0:
            add $t3, $zero, $zero
            bne $t3, $t5, second_digit_1
            jal write_0
            
            second_digit_1:
            addi $t3, $zero, 1
            bne $t3, $t5, second_digit_2
            jal write_1_bigger
            
            second_digit_2:
            addi $t3, $zero, 2
            bne $t3, $t5, second_digit_3
            jal write_2_bigger
            
            second_digit_3:
            addi $t3, $zero, 3
            bne $t3, $t5, second_digit_4
            jal write_3_bigger
            
            second_digit_4:
            addi $t3, $zero, 4
            bne $t3, $t5, second_digit_5
            jal write_4
            
            second_digit_5:
            addi $t3, $zero, 5
            bne $t3, $t5, second_digit_6
            jal write_5
            
            second_digit_6:
            addi $t3, $zero, 6
            bne $t3, $t5, second_digit_7
            jal write_6
            
            second_digit_7:
            addi $t3, $zero, 7
            bne $t3, $t5, second_digit_8
            jal write_7
            
            second_digit_8:
            addi $t3, $zero, 8
            bne $t3, $t5, second_digit_9
            jal write_8
            
            second_digit_9:
            addi $t3, $zero, 9
            bne $t3, $t5, third_digit
            jal write_9    
            
 third_digit:
            addi $t2, $zero, 10
            div $t7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 14
            addi $a2, $zero, 3

            third_digit_0:
            add $t3, $zero, $zero
            bne $t3, $t5, third_digit_1
            jal write_0
            
            third_digit_1:
            addi $t3, $zero, 1
            bne $t3, $t5, third_digit_2
            jal write_1_bigger
            
            third_digit_2:
            addi $t3, $zero, 2
            bne $t3, $t5, third_digit_3
            jal write_2_bigger
            
            third_digit_3:
            addi $t3, $zero, 3
            bne $t3, $t5, third_digit_4
            jal write_3_bigger
            
            third_digit_4:
            addi $t3, $zero, 4
            bne $t3, $t5, third_digit_5
            jal write_4
            
            third_digit_5:
            addi $t3, $zero, 5
            bne $t3, $t5, third_digit_6
            jal write_5
            
            third_digit_6:
            addi $t3, $zero, 6
            bne $t3, $t5, third_digit_7
            jal write_6
            
            third_digit_7:
            addi $t3, $zero, 7
            bne $t3, $t5, third_digit_8
            jal write_7
            
            third_digit_8:
            addi $t3, $zero, 8
            bne $t3, $t5, third_digit_9
            jal write_8
            
            third_digit_9:
            addi $t3, $zero, 9
            bne $t3, $t5, fourth_digit
            jal write_9 
            
 fourth_digit:
            addi $t2, $zero, 10
            div $t7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 8
            addi $a2, $zero, 3

            fourth_digit_0:
            add $t3, $zero, $zero
            bne $t3, $t5, fourth_digit_1
            jal write_0
            
            fourth_digit_1:
            addi $t3, $zero, 1
            bne $t3, $t5, fourth_digit_2
            jal write_1_bigger
            
            fourth_digit_2:
            addi $t3, $zero, 2
            bne $t3, $t5, fourth_digit_3
            jal write_2_bigger
            
            fourth_digit_3:
            addi $t3, $zero, 3
            bne $t3, $t5, fourth_digit_4
            jal write_3_bigger
            
            fourth_digit_4:
            addi $t3, $zero, 4
            bne $t3, $t5, fourth_digit_5
            jal write_4
            
            fourth_digit_5:
            addi $t3, $zero, 5
            bne $t3, $t5, fourth_digit_6
            jal write_5
            
            fourth_digit_6:
            addi $t3, $zero, 6
            bne $t3, $t5, fourth_digit_7
            jal write_6
            
            fourth_digit_7:
            addi $t3, $zero, 7
            bne $t3, $t5, fourth_digit_8
            jal write_7
            
            fourth_digit_8:
            addi $t3, $zero, 8
            bne $t3, $t5, fourth_digit_9
            jal write_8
            
            fourth_digit_9:
            addi $t3, $zero, 9
            bne $t3, $t5, fifth_digit
            jal write_9 
            
 fifth_digit:
            addi $t2, $zero, 10
            div $t7, $t2
            mfhi $t5 #Holds the first digit
            mflo $t7 #Holds the rest of the number
            addi $a1, $zero, 2
            addi $a2, $zero, 3

            fifth_digit_0:
            add $t3, $zero, $zero
            bne $t3, $t5, fifth_digit_1
            jal write_0
            
            fifth_digit_1:
            addi $t3, $zero, 1
            bne $t3, $t5, fifth_digit_2
            jal write_1_bigger
            
            fifth_digit_2:
            addi $t3, $zero, 2
            bne $t3, $t5, fifth_digit_3
            jal write_2_bigger
            
            fifth_digit_3:
            addi $t3, $zero, 3
            bne $t3, $t5, fifth_digit_4
            jal write_3_bigger
            
            fifth_digit_4:
            addi $t3, $zero, 4
            bne $t3, $t5, fifth_digit_5
            jal write_4
            
            fifth_digit_5:
            addi $t3, $zero, 5
            bne $t3, $t5, fifth_digit_6
            jal write_5
            
            fifth_digit_6:
            addi $t3, $zero, 6
            bne $t3, $t5, fifth_digit_7
            jal write_6
            
            fifth_digit_7:
            addi $t3, $zero, 7
            bne $t3, $t5, fifth_digit_8
            jal write_7
            
            fifth_digit_8:
            addi $t3, $zero, 8
            bne $t3, $t5, fifth_digit_9
            jal write_8
            
            fifth_digit_9:
            addi $t3, $zero, 9
            bne $t3, $t5, generate_it
            jal write_9 
    
    generate_it:
        j generate_the_new_column #If there is no new matching go to generate_the_new_column to generate a new capsule.

paint_it_bg:
    addi $a0, $a0, 1
    lw $t2, BACKGROUND 
    sw $t2, 0($t4)
    jr $ra
        

    
#Handles the W keyboard input
respond_to_W:
    add $t1, $t0, $zero #Holds the address of the bitmap
    add $t3, $s4, $zero #x offset
    sll $t3, $t3, 2 #x location
    add $t7, $s5, $zero #y offset
    sll $t7, $s5, 7 #y location
    add $t1, $t1, $t3
    add $t1, $t1, $t7 #t1 stores the location of the capsule
    sw $s3, 0($t1)
    sw $s1, 128($t1)
    sw $s2, 256($t1)
    add $t4, $zero, $s1
    add $t5, $zero, $s2
    add $t2, $zero, $s3
    addi $s1, $t2, 0
    addi $s2, $t4, 0
    addi $s3, $t5, 0
    j total_loop
    
#Handles the A keyboard input
respond_to_A:
    addi $t3, $s4, 1
    sll $t3, $t3, 2
    add $t1, $t0, $t3
    sll $t4, $s5, 7
    add $t1, $t1, $t4 
    lw $t2, BACKGROUND 
    sw $t2, 0($t1)
    sw $t2, 128($t1)
    sw $t2, 256($t1)
    sll $t3, $s4, 2
    add $t1, $t0, $t3
    sll $t4, $s5, 7
    add $t1, $t1, $t4
    sw $s1, 0($t1)
    sw $s2, 128($t1)
    sw $s3, 256($t1)
    jal preview_generator
    j total_loop
    
    
#IF the next pixel is BACKGROUND then move down
respond_to_S:
    addi $t3, $s4, 0
    sll $t3, $t3, 2
    add $t1, $t0, $t3
    addi $t4, $s5, -1
    sll $t4, $t4, 7
    add $t1, $t1, $t4
    lw $t2, BACKGROUND
    sw $t2, 0($t1)
    sw $t2, 128($t1)
    sw $t2, 256($t1)
    add $t3, $zero, $s4
    sll $t3, $t3, 2
    add $t1, $t0, $t3
    add $t4, $zero, $s5
    sll $t4, $t4, 7
    add $t1, $t1, $t4
    sw $s1, 0($t1)
    sw $s2, 128($t1)
    sw $s3, 256($t1)
    jal preview_generator
    j total_loop
    
respond_to_S_preview:
    addi $t3, $s4, 0
    sll $t3, $t3, 2
    add $t1, $t0, $t3
    addi $t4, $s5, -1
    sll $t4, $t4, 7
    add $t1, $t1, $t4
    lw $t2, BACKGROUND
    sw $t2, 0($t1)
    sw $t2, 128($t1)
    sw $t2, 256($t1)
    add $t3, $zero, $s4
    sll $t3, $t3, 2
    add $t1, $t0, $t3
    add $t4, $zero, $s5
    sll $t4, $t4, 7
    add $t1, $t1, $t4
    sw $s1, 0($t1)
    sw $s2, 128($t1)
    sw $s3, 256($t1)
    j total_loop

#Handles the D keyboard input
respond_to_D:
    addi $t3, $s4, -1
    sll $t3, $t3, 2
    add $t1, $t0, $t3
    sll $t4, $s5, 7
    add $t1, $t1, $t4 
    lw $t2, BACKGROUND 
    sw $t2, 0($t1)
    sw $t2, 128($t1)
    sw $t2, 256($t1)
    sll $t3, $s4, 2
    add $t1, $t0, $t3
    sll $t4, $s5, 7
    add $t1, $t1, $t4
    sw $s1, 0($t1)
    sw $s2, 128($t1)
    sw $s3, 256($t1)
    jal preview_generator
    j total_loop
#Handles the Q keyboard input    
respond_to_Q:
	li $v0, 10 
	syscall


generate_the_new_column:
    jal random_column_generator
    lw $t5, BACKGROUND
    lw $t7, PREVIEW_COLOR
    add $t1, $t0, $zero #t1 holds the address of the bitmap
    add $t2, $s4, $zero #t2 holds the x offset
    addi $t3, $zero, 14 #y offset is always 14 for the 4th row
    sll $t2, $t2, 2 #x value
    sll $t2, $t2, 7 #y value
    add $t1, $t1, $t2
    add $t1, $t1, $t3 #t1 holds the 4th pixel of the given column
    beq $t1, $t5, create_preview_new
    beq $t1, $t7 create_preview_new
    jal sleep
    j total_loop
    create_preview_new:
        jal preview_generator
    jal sleep
    j total_loop



sleep:
	# 4. Sleep
    li 		$v0, 32
	li 		$a0, 17
	syscall
    jr $ra

 

blackout:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    lw $a3, BACKGROUND
    addi $a2, $zero, 1028
    addi $a1, $zero, 0
    addi $a0, $zero, 0
    addi $t4, $zero, 32
    jal draw_line_horizontal
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_line_horizontal:
#This function is adapted from the pixel_draw and draw_rect files provided by Professor Engels
## Draw Horizontal Line Function
# a0 = x coordinate for the starting point of the line
# a1 = y coordinate for the starting point of the line
# a2 = length of the line
# a3 = color
# t0 = the address of the top left corner of the bipmap display
# t1 = the starting location of the line
    sll $a0, $a0, 2 # Multiply the x coordinate in $a0 by 4 to get the horizontal offset
    add $t1, $t0, $a0  # Add the horizontal offset to the starting location of this line 
    sll $a1, $a1, 7 # Multiply the y coordinate in $a1 by 128 to get the vertical offset
    add $t1, $t1, $a1 # Add the vertical offset to the starting location of this line
    sll $a2, $a2, 2 # Multiply the length by 4 in order to get the length in terms of bits
    add $t3, $t1, $a2
    start_loop:
    beq $t3, $t1, loop_end
    sw  $a3 0($t1)
    addi $t1, $t1, 4
    j start_loop
    loop_end:
    jr $ra          

draw_line_vertical:
#This function is adapted from the pixel_draw and draw_rect files provided by Professor Engels
## Draw Vertical Line Function
# a0 = x coordinate for the starting point of the line
# a1 = y coordinate for the starting point of the line
# a2 = length of the line
# a3 = color
# t0 = the address of the top left corner of the bipmap display
# t1 = the starting location of the line
    sll $a0, $a0, 2 # Multiply the x coordinate in $a0 by 4 to get the horizontal offset
    add $t1, $t0, $a0  # Add the horizontal offset to the starting location of this line 
    sll $a1, $a1, 7 # Multiply the y coordinate in $a1 by 128 to get the vertical offset
    add $t1, $t1, $a1 # Add the vertical offset to the starting location of this line
    sll $a2, $a2, 7 # Multiply the length by 128 in order to get the length in terms of bits
    add $t3, $t1, $a2
start_loop_vertical:
    beq $t3, $t1, loop_end_vertical
    sw  $a3 0($t1)
    addi $t1, $t1, 128
    j start_loop_vertical
loop_end_vertical:
    jr $ra          # return to the calling program


random_column_generator:
#generates 3 random colors and stores them at $s1, $s2, $s3 and prints them at the specified location with $a0 and $a1
#x and y offsets of the column are stored in $s4 and $s5 
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    addi $t2, $zero, 0
first_pixel:  
    beq $a0, $t2, first_pixel_red
    addi $t2, $t2, 1
    beq $a0, $t2, first_pixel_green
    addi $t2, $t2, 1
    beq $a0, $t2, first_pixel_blue
    addi $t2, $t2, 1
    beq $a0, $t2, first_pixel_yellow
    addi $t2, $t2, 1
    beq $a0, $t2, first_pixel_purple
    addi $t2, $t2, 1
    beq $a0, $t2, first_pixel_cyan
first_pixel_red:        
    lw $s1, RED
    j second_random_number 
first_pixel_green:        
    lw $s1, GREEN
    j second_random_number         
first_pixel_blue:        
    lw $s1, BLUE
    j second_random_number 
first_pixel_yellow:        
    lw $s1, YELLOW
    j second_random_number        
first_pixel_purple:        
    lw $s1, PURPLE
    j second_random_number         
first_pixel_cyan:        
    lw $s1, CYAN
    j second_random_number 
second_random_number:
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
addi $t2, $zero, 0
second_pixel:  
    beq $a0, $t2, second_pixel_red
    addi $t2, $t2, 1
    beq $a0, $t2, second_pixel_green
    addi $t2, $t2, 1
    beq $a0, $t2, second_pixel_blue
    addi $t2, $t2, 1
    beq $a0, $t2, second_pixel_yellow
    addi $t2, $t2, 1
    beq $a0, $t2, second_pixel_purple
    addi $t2, $t2, 1
    beq $a0, $t2, second_pixel_cyan
second_pixel_red:        
    lw $s2, RED
    j third_random_number 
second_pixel_green:        
    lw $s2, GREEN
    j third_random_number        
second_pixel_blue:        
    lw $s2, BLUE
    j third_random_number 
second_pixel_yellow:        
    lw $s2, YELLOW
    j third_random_number         
second_pixel_purple:        
    lw $s2, PURPLE
    j third_random_number         
second_pixel_cyan:        
    lw $s2, CYAN
    j third_random_number 
third_random_number:
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
addi $t2, $zero, 0
third_pixel:  
    beq $a0, $t2, third_pixel_red
    addi $t2, $t2, 1
    beq $a0, $t2, third_pixel_green
    addi $t2, $t2, 1
    beq $a0, $t2, third_pixel_blue
    addi $t2, $t2, 1
    beq $a0, $t2, third_pixel_yellow
    addi $t2, $t2, 1
    beq $a0, $t2, third_pixel_purple
    addi $t2, $t2, 1
    beq $a0, $t2, third_pixel_cyan
third_pixel_red:        
    lw $s3, RED
    j draw_column
third_pixel_green:        
    lw $s3, GREEN
    j draw_column
third_pixel_blue:        
    lw $s3, BLUE
    j draw_column
third_pixel_yellow:        
    lw $s3, YELLOW
    j draw_column         
third_pixel_purple:        
    lw $s3, PURPLE
    j draw_column         
third_pixel_cyan:        
    lw $s3, CYAN
    j draw_column
draw_column:
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    addi $a0, $a0, 11
    add $s4, $zero, $a0
    sll $a0, $a0, 2
    add $t1, $t0, $a0
    addi $a1, $zero, 11
    add $s5, $zero, $a1
    sll $a1, $a1, 7
    add $t1, $t1, $a1
    lw $t2, BACKGROUND
    lw $t3, 256($t1)
    bne $t2, $t3, random_column_generator
    sw $s1, 0($t1)
    sw $s2, 128($t1)
    sw $s3, 256($t1)
    j random_column_end

random_column_end:
    jr $ra
    
#START OF ENDGAME CONDITION
begin_endgame_condition_check: #initializes a forloop
    addi $a1, $t0, 1708 #starts from third row's leftmost block
    addi $a1, $a1, -4 #Due to debugging purposes
    add $a2, $zero, $zero #start of loop
    addi $a3, $zero, 6 #end of loop
    j endgame_condition_checking
    

endgame_condition_checking: #for loop until this row is checked
    addi $a1, $a1, 4
    beq $a2, $a3, game_ends
    addi $a2, $a2, 1
    lw $t1, 0($a1)
    lw $t2, BACKGROUND
    lw $t3, PREVIEW_COLOR
    beq $t1, $t2, game_continues
    beq $t1, $t3, game_continues
    j endgame_condition_checking

game_continues:
    jr $ra

game_ends:
    addi $t1, $zero, 1
    sw $t1, GAME_ENDED
    j draw_game_over


#END OF ENDGAME CONDITION



diagonal_match_45:
    ###Checks for the 45 degree mathcings in a diagonal length of length 3,4,5,6
    ###a0 is the x offset of the first pixel and a1 is the y offset of the first pixel
    ###a2 is the size of the diagonal path, a2 must be between 3 and 6
    sll $a0, $a0, 2 #X offset multiplied by 4
    sll $a1, $a1, 7 #Y offset multiplied by 128
    add $t4, $a0, $a1 #Total distance from the top left corner to first pixel
    add $t3, $t4, $t0 #t3 stores the address of the first pixel
    add $t9, $t4, $t6 #t9 stores the address of the first pixel in the copy
    lw $t5, WHITE #t5 stores the value for white
    lw $t7, BACKGROUND #t7 stores the value for BACKGROUND
    lw $a3, SCORE_COLOR
    check_length:
        addi $t4, $zero, 6
        beq $t4, $a2, Starts_from_the_first_pixel6
        addi $t4, $zero, 5
        beq $t4, $a2, Starts_from_the_first_pixel5
        addi $t4, $zero, 4
        beq $t4, $a2, Starts_from_the_first_pixel4
        addi $t4, $zero, 3
        bne $t4, $a2, end_of_diagonal_match_45
        j Starts_from_the_first_pixel3
    Starts_from_the_first_pixel6:
        lw $t1, 0($t3) #t1 holds the color of the first pixel
        beq $t1, $t7,  Starts_from_the_second_pixel6 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_second_pixel6 #t1 stores SCORE_COLOR, then ignore
        lw $t2, -124($t3) #t2 holds the color of the second pixel
        bne $t1, $t2, Starts_from_the_second_pixel6
        lw $t1, -248($t3) #t1 holds the color of the third pixel
        bne $t2, $t1, Starts_from_the_third_pixel6
        sw $t5, 0($t9) #Paint the first pixel to white in the copy
        sw $t5, -124($t9) #Paint the second pixel to white in the copy
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        lw $t2, -372($t3) #t2 holds the color of the fourth pixel
        bne $t2, $t1, Starts_from_the_fourth_pixel6
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
        lw $t1, -496($t3) #t1 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -496($t9) #Paint the fifth pixel to white in the copy
        lw $t2, -620($t3) #t2 holds the color of the 6th pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -620($t9)
        j end_of_diagonal_match_45
        
    Starts_from_the_second_pixel6:
        lw $t1, -124($t3) #t1 holds the color of the secon pixel
        beq $t1, $t7,  Starts_from_the_third_pixel6 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_third_pixel6 #t1 stores SCORE_COLOR, then ignore
        lw $t2, -248($t3) #t2 holds the color of the third pixel
        bne $t1, $t2, Starts_from_the_third_pixel6
        lw $t1, -372($t3) #t1 holds the color of the fourth pixel
        bne $t2, $t1, Starts_from_the_fourth_pixel6
        sw $t5, -124($t9) #Paint the second pixel to white in the copy
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
        lw $t2, -496($t3) #t2 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -496($t9) #Paint the fifth pixel to white in the copy
        lw $t1, -620($t3) #t1 holds the color of the sixth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -620($t9) #Paint the sixth pixel to white in the copy
        j end_of_diagonal_match_45
    Starts_from_the_third_pixel6:
        lw $t1, -248($t3) #t1 holds the color of the third pixel
        beq $t1, $t7,  Starts_from_the_fourth_pixel6 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_fourth_pixel6 #t1 stores SCORECOLOR, then ignore
        lw $t2, -372($t3) #t2 holds the color of the fourth pixel
        bne $t1, $t2, Starts_from_the_fourth_pixel6
        lw $t1, -496($t3) #t1 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
        sw $t5, -496($t9) #Paint the fifth pixel to white in the copy
        lw $t2, -620($t3) #t2 holds the color of the sixth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -620($t9) #Paint the sixth pixel to white in the copy
        
    Starts_from_the_fourth_pixel6:
        lw $t1, -372($t3) #t1 holds the color of the fourth pixel
        beq $t1, $t7,  end_of_diagonal_match_45 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  end_of_diagonal_match_45 #t1 stores BACKGROUND, then ignore
        lw $t2, -496($t3) #t2 holds the color of the fifth pixel
        bne $t1, $t2, end_of_diagonal_match_45
        lw $t1, -620($t3) #t1 holds the color of the sixth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
        sw $t5, -496($t9) #Paint the fifth pixel to white in the copy
        sw $t5, -620($t9) #Paint the sixth pixel to white in the copy
    
    Starts_from_the_first_pixel5:
        lw $t1, 0($t3) #t1 holds the color of the first pixel
        beq $t1, $t7,  Starts_from_the_second_pixel5 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_second_pixel5 #t1 stores BACKGROUND, then ignore
        lw $t2, -124($t3) #t2 holds the color of the second pixel
        bne $t1, $t2, Starts_from_the_second_pixel5
        lw $t1, -248($t3) #t1 holds the color of the third pixel
        bne $t2, $t1, Starts_from_the_third_pixel5
        sw $t5, 0($t9) #Paint the first pixel to white in the copy
        sw $t5, -124($t9) #Paint the second pixel to white in the copy
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        lw $t2, -372($t3) #t2 holds the color of the fourth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
        lw $t1, -496($t3) #t1 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -496($t9) #Paint the fifth pixel to white in the copy
        j end_of_diagonal_match_45
    Starts_from_the_second_pixel5:
        lw $t1, -124($t3) #t1 holds the color of the second pixel
        beq $t1, $t7,  Starts_from_the_third_pixel5 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_third_pixel5 #t1 stores BACKGROUND, then ignore
        lw $t2, -248($t3) #t2 holds the color of the third pixel
        bne $t1, $t2, Starts_from_the_third_pixel5
        lw $t1, -372($t3) #t1 holds the color of the fourth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -124($t9) #Paint the second pixel to white in the copy
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
        lw $t2, -496($t3) #t2 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -496($t9) #Paint the fifth pixel to white in the copy
    Starts_from_the_third_pixel5:
        lw $t1, -248($t3) #t1 holds the color of the third pixel
        beq $t1, $t7,  end_of_diagonal_match_45 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  end_of_diagonal_match_45 #t1 stores BACKGROUND, then ignore
        lw $t2, -372($t3) #t2 holds the color of the fourth pixel
        bne $t1, $t2, end_of_diagonal_match_45
        lw $t1, -496($t3) #t1 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
        sw $t5, -496($t9) #Paint the fifth pixel to white in the copy
        
    Starts_from_the_first_pixel4:
        lw $t1, 0($t3) #t1 holds the color of the first pixel
        beq $t1, $t7,  Starts_from_the_second_pixel4 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_second_pixel4 #t1 stores BACKGROUND, then ignore
        lw $t2, -124($t3) #t2 holds the color of the second pixel
        bne $t1, $t2, Starts_from_the_second_pixel4
        lw $t1, -248($t3) #t1 holds the color of the third pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, 0($t9) #Paint the first pixel to white in the copy
        sw $t5, -124($t9) #Paint the second pixel to white in the copy
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        lw $t2, -372($t3) #t2 holds the color of the fourth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
    Starts_from_the_second_pixel4:
        lw $t1, -124($t3) #t1 holds the color of the second pixel
        beq $t1, $t7,  end_of_diagonal_match_45 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  end_of_diagonal_match_45 #t1 stores BACKGROUND, then ignore
        lw $t2, -248($t3) #t2 holds the color of the third pixel
        bne $t1, $t2, end_of_diagonal_match_45
        lw $t1, -372($t3) #t1 holds the color of the fourth pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, -124($t9) #Paint the second pixel to white in the copy
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        sw $t5, -372($t9) #Paint the fourth pixel to white in the copy
    Starts_from_the_first_pixel3:
        lw $t1, 0($t3) #t1 holds the color of the first pixel
        beq $t1, $t7,  end_of_diagonal_match_45 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  end_of_diagonal_match_45 #t1 stores BACKGROUND, then ignore
        lw $t2, -124($t3) #t2 holds the color of the first pixel
        bne $t1, $t2, end_of_diagonal_match_45
        lw $t1, -248($t3) #t1 holds the color of the second pixel
        bne $t2, $t1, end_of_diagonal_match_45
        sw $t5, 0($t9) #Paint the first pixel to white in the copy
        sw $t5, -124($t9) #Paint the second pixel to white in the copy
        sw $t5, -248($t9) #Paint the third pixel to white in the copy
        
end_of_diagonal_match_45:
        jr $ra 
diagonal_match_135:
    ###Checks for the 135 degree mathcings in a diagonal path of length 3,4,5,6
    ###a0 is the x offset of the first pixel and a1 is the y offset of the first pixel
    ###a2 is the size of the diagonal path, a2 must be between 3 and 6
    sll $a0, $a0, 2 #X offset multiplied by 4
    sll $a1, $a1, 7 #Y offset multiplied by 128
    add $t4, $a0, $a1 #Total distance from the top left corner to first pixel
    add $t3, $t4, $t0 #t3 stores the address of the first pixel
    add $t9, $t4, $t6 #t9 stores the address of the first pixel in the copy
    lw $t5, WHITE #t5 stores the value for white
    lw $t7, BACKGROUND #t7 stores the value for BACKGROUND
    lw $a3, SCORE_COLOR
    check_length135:
        addi $t4, $zero, 6
        beq $t4, $a2, Starts_from_the_first_pixel6_135
        addi $t4, $zero, 5
        beq $t4, $a2, Starts_from_the_first_pixel5_135
        addi $t4, $zero, 4
        beq $t4, $a2, Starts_from_the_first_pixel4_135
        addi $t4, $zero, 3
        bne $t4, $a2, end_of_diagonal_match_135
        j Starts_from_the_first_pixel3_135
    Starts_from_the_first_pixel6_135:
        lw $t1, 0($t3) #t1 holds the color of the first pixel
        beq $t1, $t7,  Starts_from_the_second_pixel6_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_second_pixel6_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -132($t3) #t2 holds the color of the second pixel
        bne $t1, $t2, Starts_from_the_second_pixel6_135
        lw $t1, -264($t3) #t1 holds the color of the third pixel
        bne $t2, $t1, Starts_from_the_third_pixel6_135
        sw $t5, 0($t9) #Paint the first pixel to white in the copy
        sw $t5, -132($t9) #Paint the second pixel to white in the copy
        sw $t5, -264($t9) #Paint the third pixel to white in the copy
        lw $t2, -396($t3) #t2 holds the color of the fourth pixel
        bne $t2, $t1, Starts_from_the_fourth_pixel6_135
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
        lw $t1, -528($t3) #t1 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -528($t9) #Paint the fifth pixel to white in the copy
        lw $t2, -660($t3) #t2 holds the color of the 6th pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -660($t9)
        j end_of_diagonal_match_135
        
    Starts_from_the_second_pixel6_135:
        lw $t1, -132($t3) #t1 holds the color of the secon pixel
        beq $t1, $t7,  Starts_from_the_third_pixel6_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_third_pixel6_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -264($t3) #t2 holds the color of the third pixel
        bne $t1, $t2, Starts_from_the_third_pixel6_135
        lw $t1, -396($t3) #t1 holds the color of the fourth pixel
        bne $t2, $t1, Starts_from_the_fourth_pixel6_135
        sw $t5, -132($t9) #Paint the second pixel to white in the copy
        sw $t5, -264($t9) #Paint the third pixel to white in the copy
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
        lw $t2, -528($t3) #t2 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -528($t9) #Paint the fifth pixel to white in the copy
        lw $t1, -660($t3) #t1 holds the color of the sixth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -660($t9) #Paint the sixth pixel to white in the copy
        j end_of_diagonal_match_135
    Starts_from_the_third_pixel6_135:
        lw $t1, -264($t3) #t1 holds the color of the third pixel
        beq $t1, $t7,  Starts_from_the_fourth_pixel6_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_fourth_pixel6_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -396($t3) #t2 holds the color of the fourth pixel
        bne $t1, $t2, Starts_from_the_fourth_pixel6_135
        lw $t1, -528($t3) #t1 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -264($t9) #Paint the third pixel to white in the copy
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
        sw $t5, -528($t9) #Paint the fifth pixel to white in the copy
        lw $t2, -660($t3) #t2 holds the color of the sixth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -660($t9) #Paint the sixth pixel to white in the copy
        
    Starts_from_the_fourth_pixel6_135:
        lw $t1, -396($t3) #t1 holds the color of the fourth pixel
        beq $t1, $t7,  end_of_diagonal_match_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  end_of_diagonal_match_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -528($t3) #t2 holds the color of the fifth pixel
        bne $t1, $t2, end_of_diagonal_match_135
        lw $t1, -660($t3) #t1 holds the color of the sixth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
        sw $t5, -528($t9) #Paint the fifth pixel to white in the copy
        sw $t5, -660($t9) #Paint the sixth pixel to white in the copy
    
    Starts_from_the_first_pixel5_135:
        lw $t1, 0($t3) #t1 holds the color of the first pixel
        beq $t1, $t7,  Starts_from_the_second_pixel5_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_second_pixel5_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -132($t3) #t2 holds the color of the second pixel
        bne $t1, $t2, Starts_from_the_second_pixel5_135
        lw $t1, -264($t3) #t1 holds the color of the third pixel
        bne $t2, $t1, Starts_from_the_third_pixel5_135
        sw $t5, 0($t9) #Paint the first pixel to white in the copy
        sw $t5, -132($t9) #Paint the second pixel to white in the copy
        sw $t5, -264($t9) #Paint the third pixel to white in the copy
        lw $t2, -396($t3) #t2 holds the color of the fourth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
        lw $t1, -528($t3) #t1 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -528($t9) #Paint the fifth pixel to white in the copy
        j end_of_diagonal_match_135
    Starts_from_the_second_pixel5_135:
        lw $t1, -132($t3) #t1 holds the color of the second pixel
        beq $t1, $t7,  Starts_from_the_third_pixel5_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_third_pixel5_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -264($t3) #t2 holds the color of the third pixel
        bne $t1, $t2, Starts_from_the_third_pixel5_135
        lw $t1, -396($t3) #t1 holds the color of the fourth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -132($t9) #Paint the second pixel to white in the copy
        sw $t5, -264($t9) #Paint the third pixel to white in the copy
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
        lw $t2, -528($t3) #t2 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -528($t9) #Paint the fifth pixel to white in the copy
    Starts_from_the_third_pixel5_135:
        lw $t1, -264($t3) #t1 holds the color of the third pixel
        beq $t1, $t7,  end_of_diagonal_match_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  end_of_diagonal_match_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -396($t3) #t2 holds the color of the fourth pixel
        bne $t1, $t2, end_of_diagonal_match_135
        lw $t1, -528($t3) #t1 holds the color of the fifth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -264($t9) #Paint the third pixel to white in the copy
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
        sw $t5, -528($t9) #Paint the fifth pixel to white in the copy
        
    Starts_from_the_first_pixel4_135:
        lw $t1, 0($t3) #t1 holds the color of the first pixel
        beq $t1, $t7,  Starts_from_the_second_pixel4_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  Starts_from_the_second_pixel4_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -132($t3) #t2 holds the color of the second pixel
        bne $t1, $t2, Starts_from_the_second_pixel4_135
        lw $t1, -264($t3) #t1 holds the color of the third pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, 0($t9) #Paint the first pixel to white in the copy
        sw $t5, -132($t9) #Paint the second pixel to white in the copy
        sw $t5, -264($t9) #Paint the third pixel to white in the copy
        lw $t2, -396($t3) #t2 holds the color of the fourth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
    Starts_from_the_second_pixel4_135:
        lw $t1, -132($t3) #t1 holds the color of the second pixel
        beq $t1, $t7,  end_of_diagonal_match_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  end_of_diagonal_match_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -264($t3) #t2 holds the color of the third pixel
        bne $t1, $t2, end_of_diagonal_match_135
        lw $t1, -396($t3) #t1 holds the color of the fourth pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, -132($t9) #Paint the second pixel to white in the copy
        sw $t5, -264($t9) #Paint the third pixel to white in the copy
        sw $t5, -396($t9) #Paint the fourth pixel to white in the copy
    Starts_from_the_first_pixel3_135:
        lw $t1, 0($t3) #t1 holds the color of the first pixel
        beq $t1, $t7,  end_of_diagonal_match_135 #t1 stores BACKGROUND, then ignore
        beq $t1, $a3,  end_of_diagonal_match_135 #t1 stores BACKGROUND, then ignore
        lw $t2, -132($t3) #t2 holds the color of the first pixel
        bne $t1, $t2, end_of_diagonal_match_135
        lw $t1, -264($t3) #t1 holds the color of the second pixel
        bne $t2, $t1, end_of_diagonal_match_135
        sw $t5, 0($t9) #Paint the first pixel to white in the copy
        sw $t5, -132($t9) #Paint the second pixel to white in the copy
        sw $t5, -264($t9) #Paint the third pixel to white in the copy

end_of_diagonal_match_135:
    jr $ra
    
#############
# General Structure of matching code for horizontal/vertical
# for(i=0; i< len(col/row); i++)
#     for(j=0; j<len(height/width); j++)
#           x is at a1 
#           if color(x) == color(x+1)
#               if color(x)==color(x+2)
#                   if color(x) != BACKGROUND
#                      make color(x) color(x+1) color(x+2) white for copy
#           relocate x to 1 up or 1 right
#      relocate x to 1 up of a1 or 1 right of a1
#########
#start of horizontal matching
begin_hmatch: #initializes a forloop-like structure
    addi $a1, $t0, 3628 #starts from bottom left corner
    addi $a1, $a1, -4 #Due to debugging purposes
    add $a2, $zero, $zero #start of inner loop
    addi $a3, $zero, 4 #end of inner loop
    add $t9, $zero, $zero #start of outer loop
    addi $t5, $zero, 18 #end of outer loop
    j hmatching
    

hmatching: #recursion-for loop until all rows checked
    addi $a1, $a1, 4
    beq $t9, $t5, h_end
    beq $a2, $a3, horizontal_checked
    addi $a2, $a2, 1
    lw $t1, 0($a1)
    lw $t2, 4($a1)
    bne $t1, $t2, hmatching
    lw $t2, 8($a1)
    beq $t1, $t2, whatifbackgroundh
    j hmatching

whatifbackgroundh:
    lw $t3, BACKGROUND 
    bne $t1, $t3, check_score_color
        j hmatching
    check_score_color:
        lw $t3, SCORE_COLOR
        bne $t1, $t3, hmatch_found
    j hmatching
  
horizontal_checked:
    addi $a1, $a1, -148 #goes 1 up, and 3 left = -128 -3*4 -4 for debug
    addi $t9, $t9, 1
    add $a2, $zero, $zero
    j hmatching

hmatch_found:
    sub $t3, $a1, $t0
    add $t4, $t6, $t3
    lw $t3, WHITE
    sw $t3, 0($t4)
    sw $t3, 4($t4)
    sw $t3, 8($t4)
    j hmatching

h_end:
    jr $ra
#end of horizontal matching

#start of vertical matching
begin_vmatch: #initializes a forloop-like structure
    addi $a1, $t0, 3628 #starts from bottom left corner
    addi $a1, $a1, 128 #just for debugging purposes
    add $a2, $zero, $zero #start
    addi $a3, $zero, 16 #end
    add $t9, $zero, $zero #start of outer loop 
    addi $t5, $zero, 6 #end of outer loop
    j vmatching

vmatching:
    addi $a1, $a1, -128
    beq $t9, $t5, v_end
    beq $a2, $a3, vorizontal_checked
    addi $a2, $a2, 1
    lw $t1, 0($a1)
    lw $t2, -128($a1)
    bne $t1, $t2, vmatching
    lw $t2, -256($a1)
    beq $t1, $t2, whatifbackgroundv
    j vmatching

whatifbackgroundv:
    lw $t3, BACKGROUND 
    bne $t1, $t3, check_score_color_vertical
    j vmatching
    check_score_color_vertical:
        lw $t3, SCORE_COLOR
        bne $t1, $t3, check_preview_color_vertical
        j vmatching
    check_preview_color_vertical:
        lw $t2, PREVIEW_COLOR
        bne $t1, $t3, vmatch_found
        j vmatching
        
vorizontal_checked: #su fonksiyonun adini inanilmaz vorizontal yapasim var, YAPYAPYAP, YAPTIM!
    addi $a1, $a1, 2180 #goes 16 down, and 1 right =16*128+4 (+ 128 for debug)
    addi $t9, $t9, 1
    add $a2, $zero, $zero
    j vmatching

vmatch_found:
    sub $t3, $a1, $t0
    add $t4, $t6, $t3
    lw $t3, WHITE
    sw $t3, 0($t4)
    sw $t3, -128($t4)
    sw $t3, -256($t4)
    j vmatching

v_end:
  jr $ra
#end of vertical matching


#############
# General Structure of iteration to 
# for(i=0; i< #of col; i++)
#     for(j=0; j< #of row); j++)
#           x is at a1 
#   
#           if color(x) == BACKGROUND 
#               if color(1 up of x)!= BACKGROUND
#                      color(x) = color (1 up of x)
#                      color 1upof x = BACKGROUND
#           relocate x to 1 up
#      relocate x to 1 right of a1
#########

#start of iterating block falling
begin_iteration: #initializes a forloop-like structure
    addi $a1, $t0, 3628 #starts from bottom left corner
    addi $a1, $a1, 128 #just for debugging purposes
    add $a2, $zero, $zero #start of inner loop
    addi $a3, $zero, 17 #end of inner loop
    add $t9, $zero, $zero #start of outer loop 
    addi $t5, $zero, 6 #end of outer loop
    j iterating

iterating:
    addi $a1, $a1, -128 #At first, a1 comes to bottom left corner.
    beq $t9, $t5, i_end #if outer loop ended, then go to i_end
    beq $a2, $a3, column_iterated #if we iterated through all rows of that column, then go to column_iterated
    addi $a2, $a2, 1 #increase j (inner loop) by 1
    lw $t1, 0($a1) #Store the color at $a1 in $t1
    lw $t3, BACKGROUND #load Background value into $t3
    beq $t1, $t3, bg_found
    j iterating
    
bg_found:
    lw $t4, -128($a1)
    bne $t4, $t3, color_above_bg_found
    j iterating

color_above_bg_found:
    sw $t4, 0($a1)
    sw $t1, -128($a1) 
    j iterating

column_iterated:
    addi $a1, $a1, 2308 #goes 17 down, and 1 right =17*128+4 (+ 128 for debug)
    addi $t9, $t9, 1
    add $a2, $zero, $zero
    j iterating

i_end:
    
    jr $ra
#end of iterating for block falling

#start of checking if everything fell
begin_check: #initializes a forloop-like structure
    addi $a1, $t0, 3628 #starts from bottom left corner
    addi $a1, $a1, 128 #just for debugging purposes
    add $a2, $zero, $zero #start of inner loop
    addi $a3, $zero, 17 #end of inner loop
    add $t9, $zero, $zero #start of outer loop 
    addi $t5, $zero, 6 #end of outer loop
    j checking

checking:
    addi $a1, $a1, -128 #At first, a1 comes to bottom left corner.
    beq $t9, $t5, check_end #if outer loop ended, then go to check_end
    beq $a2, $a3, column_iterated_check #if we iterated through all rows of that column, then go to column_iterated_check
    addi $a2, $a2, 1 #increase j (inner loop) by 1
    lw $t1, 0($a1) #Store the color at $a1 in $t1
    lw $t3, BACKGROUND #load Background value into $t3
    lw $t4, PREVIEW_COLOR
    beq $t1, $t3, bg_found_check
    beq $t1, $t4, bg_found_check
    j checking
    
bg_found_check:
    lw $t4, -128($a1)
    bne $t4, $t3, color_above_bg_found_check
    j checking

color_above_bg_found_check:
    j lets_fall

column_iterated_check:
    addi $a1, $a1, 2308 #goes 17 down, and 1 right =17*128+4 (+ 128 for debug)
    addi $t9, $t9, 1
    add $a2, $zero, $zero
    j checking

check_end:
    jr $ra
#end of checking if everything fell

wr_1:
    add $t1, $a1, $t0
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra

wr_2:
    add $t1, $a1, $t0
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 132
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra

wr_3:
    add $t1, $a1, $t0
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra

write_1_bigger:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 8 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 132 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 8 #eigth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
write_2_bigger:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #eigth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #ninth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #tenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #eleventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #twelfth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #thirteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourteenth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
write_3_bigger:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #eigth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 136 #ninth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #tenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #eleventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #twelfth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #thirteenth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
write_4:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #eigth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 384 #ninth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #tenth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
write_5:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 116 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #eigth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #ninth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #tenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #eleventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #twelfth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #thirteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #fourteenth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
write_6:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 116 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #eigth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #ninth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #tenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #eleventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #twelfth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #thirteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #fourteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #fourteenth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
write_7:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #eigth location to be painted
    sw $t2, 0($t1)
    jr $ra

write_8:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #eigth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #ninth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #tenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #eleventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #twelfth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #thirteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #fourteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 132 #fourteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourteenth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
write_9:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #eigth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #ninth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #tenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #eleventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -256 #twelfth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128#thirteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 132 #fourteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourteenth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
write_0:
    #a1 is the x offset of the starting point
    #a2 is the y offset of the starting point
    lw $t2, SCORE_COLOR
    sll $a1, $a1, 2 #Total x location, multiplied by 4
    sll $a2, $a2, 7 #Total y location, multiplied by 128
    add $t1, $zero $t0
    add $t1, $t1, $a1
    add $t1, $t1, $a2 #t1 stores the starting point
    addi $t1, $t1, 0 #First location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #Second location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #third location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 4 #fourth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #fifth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #sixth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #seventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, 128 #eigth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #ninth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #tenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -4 #eleventh location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #twelfth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #thirteenth location to be painted
    sw $t2, 0($t1)
    addi $t1, $t1, -128 #fourteenth location to be painted
    sw $t2, 0($t1)
    jr $ra
    
wr_Y:
    add $t1, $a1, $t0 #a1 is the starting location
    sw $t2, 0($t1)
    addi $t1, $t1, 16
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 8
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    jr $ra


wr_I:
    add $t1, $a1, $t0 #a1 is the starting location, 
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra

wr_D:
    add $t1, $a1, $t0 #a1 is the starting location
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra

wr_H:
    add $t1, $a1, $t0 #a1 is the starting location
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    jr $ra

wr_AA:
    add $t1, $a1, $t0 #a1 is the starting location
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 104
    sw $t2, 0($t1)
    addi $t1, $t1, 28
    sw $t2, 0($t1)
    addi $t1, $t1, 100
    sw $t2, 0($t1)
    addi $t1, $t1, 28
    sw $t2, 0($t1)
    addi $t1, $t1, 100
    sw $t2, 0($t1)
    addi $t1, $t1, 28
    sw $t2, 0($t1)
    addi $t1, $t1, 100
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 100
    sw $t2, 0($t1)
    addi $t1, $t1, 28
    sw $t2, 0($t1)
    addi $t1, $t1, 100
    sw $t2, 0($t1)
    addi $t1, $t1, 28
    sw $t2, 0($t1)
    jr $ra

wr_A:
    add $t1, $a1, $t0 #a1 is the starting location
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    jr $ra

wr_M:
    add $t1, $a1, $t0 #a1 is the starting location
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 8
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 8
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 8
    sw $t2, 0($t1)
    addi $t1, $t1, 8
    sw $t2, 0($t1)
    addi $t1, $t1, 112
    sw $t2, 0($t1)
    addi $t1, $t1, 16
    sw $t2, 0($t1)
    addi $t1, $t1, 112
    sw $t2, 0($t1)
    addi $t1, $t1, 16
    sw $t2, 0($t1)
    jr $ra


wr_V:
    add $t1, $a1, $t0 #a1 is the starting location
    sw $t2, 0($t1)
    addi $t1, $t1, 16
    sw $t2, 0($t1)
    addi $t1, $t1, 112
    sw $t2, 0($t1)
    addi $t1, $t1, 16
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 8
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 8
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    jr $ra

wr_C:
    add $t1, $a1, $t0 #a1 is the starting location
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra

wr_G:
    add $t1, $a1, $t0 #a1 is the starting location
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 8
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra
    
wr_P:
    add $t1, $a1, $t0 #a1 is the starting location
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    jr $ra

wr_R:
    add $t1, $a1, $t0 #a1 is the starting location
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    jr $ra

wr_E:
    add $t1, $a1, $t0 #a1 is the starting location
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra
  
wr_O:
    add $t1, $a1, $t0 #a1 is the starting location
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 12
    sw $t2, 0($t1)
    addi $t1, $t1, 120
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra

wr_T:
    add $t1, $a1, $t0 #a1 is the starting location
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 124
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)
    addi $t1, $t1, 128
    sw $t2, 0($t1)

    jr $ra

wr_S:
    add $t1, $a1, $t0 #a1 is the starting location
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 132
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 132
    sw $t2, 0($t1)
    addi $t1, $t1, 116
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    addi $t1, $t1, 4
    sw $t2, 0($t1)
    jr $ra
    

random_column_generator_title:
#generates 3 random colors and stores them at $s1, $s2, $s3 and prints them at the specified location with $a0 and $a1
#x and y offsets of the column are stored in $s4 and $s5 
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    addi $t2, $zero, 0
    beq $a0, $t2, column_red
    addi $t2, $t2, 1
    beq $a0, $t2, column_green
    addi $t2, $t2, 1
    beq $a0, $t2, column_blue
    addi $t2, $t2, 1
    beq $a0, $t2, column_yellow
    addi $t2, $t2, 1
    beq $a0, $t2, column_purple
    addi $t2, $t2, 1
    beq $a0, $t2, column_cyan
column_red:        
    lw $s1, RED
    j draw_column_title 
column_green:        
    lw $s1, GREEN
    j draw_column_title         
column_blue:        
    lw $s1, BLUE
    j draw_column_title 
column_yellow:        
    lw $s1, YELLOW
    j draw_column_title        
column_purple:        
    lw $s1, PURPLE
    j draw_column_title         
column_cyan:
    lw $s1, CYAN
    j draw_column_title

draw_column_title:
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    addi $a0, $a0, 13
    add $s4, $zero, $a0
    sll $a0, $a0, 2
    add $t1, $t0, $a0
    addi $a1, $zero, 10
    add $s5, $zero, $a1
    sll $a1, $a1, 7
    add $t1, $t1, $a1
    add $s2, $s1, $zero
    add $s3, $s1, $zero
    sw $s1, 0($t1)
    sw $s2, 128($t1)
    sw $s3, 256($t1)
    jr $ra
    
# END OF COLUMN IN TITLE SCREEN
  

preview_generator:
    add $t1, $zero, $t0 #Starting point
    add $t3, $zero, $zero #Loop Variable
    addi $t2, $zero, 4100 #Total number of bits + 4
    lw $t4, PREVIEW_COLOR
    lw $t7, BACKGROUND
    preview_loop: #Deletes all the previous preview
        beq $t3, $t2, end_loop_preview
        lw $t5, 0($t1)
        bne $t5, $t4, increment_preview
        sw $t7, 0($t1)
        increment_preview:
            addi $t1, $t1, 4
            addi $t3, $t3, 4
            j preview_loop
    end_loop_preview:
    
    create_preview:
       add $t1, $zero, $t0 #Store the address of the bitmap in $t1
       add $t2, $zero, $s4 #Store the x offset of the current column
       sll $t2, $t2, 2 #Multiply by 4 to get the x value
       add $t1, $t1, $t2 #Add the x value to address
       add $t3, $zero, $s5 #Store the y offset of the current column
       sll $t3, $t3, 7 #Multiply by 128 to get the y value
       add $t1, $t1, $t3 #Location of the top pixel of the current column
       
       addi $t4, $zero, 3 #Hold 3 in t4, this will be the starting point of the loop
       lw $t3, BACKGROUND #t3 holds the color of the background
       lw $t7, PREVIEW_COLOR #t7 holds the color of the preview
       addi $a1, $zero, 3
       addi $a2, $zero, 4
       addi $a3, $zero, 5
       Loop_create_preview:
       add $t5, $t1, $zero #t5 stores the starting point of the column
       sll $t9, $t4, 7 #we iterate and check the pixels under our column
       add $t5, $t5, $t9 #($t4-2)th column under ours
       lw $t2, 0($t5) #hold the color of the ($t4-2)th column
       beq $t3, $t2, increment_create_preview
       beq $t4, $a1, end_preview
       beq $t4, $a2, preview_only_1
       beq $t4, $a3, preview_only_2
       sw $t7, -128($t5)
       sw $t7, -256($t5)
       sw $t7, -384($t5)
       j end_preview
       increment_create_preview: addi $t4, $t4, 1
       j Loop_create_preview
       preview_only_1:
               sw $t7, -128($t5)
               j end_preview
       preview_only_2:
       sw $t7, -128($t5)
       sw $t7, -256($t5)
                j end_preview
       end_preview:
            jr $ra
      
exit: #Given in the starter code
    li $v0, 10              # terminate the program gracefully
    syscall
