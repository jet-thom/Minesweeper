.data
	board:.space 256
	buffer: .space 10
	pressEnter: .asciiz "\nPress Enter key to continue...\n"
	openCellNum: .asciiz "Number of Open Cells: "
	flagNum: .asciiz " Number of Flags: " 
	newLine: .asciiz "\n"
	youLose: .asciiz "Mine exploded, you lose! Click reset or change size to play again! \n"
	youLose2: .asciiz "There was no mine under one of your flags, you lose! Click reset or change size to play again! \n"
	youLose3: .asciiz "There was no flag on top of one of the mines, you lose! Click reset or change size to play again! \n"
	youWin: .asciiz "Congrats, you found all the mines! Click reset or change size to play again! \n"
.text
	#Register Usage:
		#$s0 = address of board
		#$s1 = counter
		#$s2 = Upper Bound of Board
		#$s3 = Number of Mines
		#$s4 = address of random cell
		#$t1 = address holder
		#$t2 = 
		#$t9 = wait
	
eightSet:
	la $s0, board # Set $s0 to the address of the Minesweeper board
	la $s4, 0xffff8000
	add $s1, $zero, $zero # Counter
	addi $s2, $zero, 65 # Upper Bound
	addi $s3,$zero,10 # mines (plus one for loop)
eightLoop: #clears the buffer from previous entries
	beq $s1,$s2,minePlaceStart
	sb $zero,0($s0)
	sb $zero,0($s4)
	addi $s4,$s4,1
	addi $s1,$s1,1
	addi $s0,$s0,1
	j eightLoop
twelveSet:
	la $s0, board # Set $s0 to the address of the Minesweeper board
	la $s4, 0xffff8000
	add $s1, $zero, $zero # Counter
	addi $s2,$zero,145 # Upper Bound
	addi $s3,$zero,15
twelveLoop: #clears the buffer from previous entries
	beq $s1,$s2,minePlaceStart
	sb $zero,0($s0)
	sb $zero,0($s4)
	addi $s4,$s4,1
	addi $s1,$s1,1
	addi $s0,$s0,1
	j twelveLoop
sixteenSet:
	la $s0, board # Set $s0 to the address of the Minesweeper board
	la $s4, 0xffff8000
	addi $s2,$zero,257 # Upper Bound
	addi $s3,$zero,20 # mines
sixteenLoop: #clears the buffer from previous entries
	beq $s1,$s2,minePlaceStart
	sb $zero,0($s0)
	sb $zero,0($s4)
	addi $s4,$s4,1
	addi $s1,$s1,1
	addi $s0,$s0,1
	j sixteenLoop
minePlaceStart:
	add $s1,$zero,$zero
	j minePlace
minePlace: 
	la $s0, board
	beq $s1,$s3,initCells # if the required number of mines are placed, you're done
	add $a1,$zero,$s2 #load $a1 with the Upper Bound provided in $s2
	li $v0,42
	syscall
	add $s0,$s0,$a0 #adds the random number to the address of the board
	lb $s4,0($s0)
	bne $s4,$zero,minePlace #if the cell already contains something, reselect a random number
	addi $t0,$zero,10 #the mine
	sb $t0,0($s0)
	addi $s1,$s1,1 # increases counter
	j minePlace
initCells:
	add $s1,$zero,$zero
	add $t3,$zero,$zero #cell number holder
	la $s0,board
	beq $s2,65,setT58
	beq $s2,145,setT512
	beq $s2,257,setT516
setT58:
	addi $t5,$zero,8
	addi $t6,$zero,7
	addi $t7,$zero,9
	j setRowCount
setT512:
	addi $t5,$zero,12
	addi $t6,$zero,11
	addi $t7,$zero,13
	j setRowCount
setT516:
	addi $t5,$zero,16
	addi $t6,$zero,15
	addi $t7,$zero,17
	j setRowCount
setRowCount:
	addi $t8,$zero,-1 # row counter
	j resetT4
resetT4:
	add $t4,$zero,$zero # edge counter
	addi $t8,$t8,1 #a new row was started
	j initLoop
initLoop:
	beq $t4,$t5,resetT4 #when it hits the edge
	beq $s1,$s2,copyBoard # if you've checked all cells, wait for action
	lb $s4,0($s0)
	beq $s4,10,nextCellMine
	beq $t8,0,contn1 #if this is the top row, don't check the top parameters
	beq $t4,0,contn8 # if it is a left edge cell, skip to reading middle top
	sub $s0,$s0,$t7 #checks top left corner
	lb $s4,0($s0)
	add $s0,$s0,$t7
	beq $s4,10,addMinen9
contn8:
	beq $t8,0,cont1 #if it is a left edge and top, skip to reading middle right
	sub $s0,$s0,$t5 #now it's checking top middle
	lb $s4,0($s0)
	add $s0,$s0,$t5
	beq $s4,10,addMinen8
contn7:
	beq $t4,$t6,contn1 # if a right cell, skip to reading middle left
	sub $s0,$s0,$t6 #now it's checking top right
	lb $s4,0($s0)
	add $s0,$s0,$t6
	beq $s4,10,addMinen7
contn1:
	beq $t4,0,cont1 # if left edge skip reading middle left
	sub $s0,$s0,$t5
	add $s0,$s0,$t6 # checking middle left
	lb $s4,0($s0)
	addi $s0,$s0,1
	beq $s4,10,addMinen1
cont1:
	beq $t4,$t6,cont7 # if right edge, skip to reading bottom left
	add $s0,$s0,$t5
	sub $s0,$s0,$t6 # checking middle right
	lb $s4,0($s0)
	subi $s0,$s0,1
	beq $s4,10,addMine1
cont7:
	beq $t4,0,cont8 # if it's a left edge, skip to reading bottom middle
	beq $t8,$t6,nextCell #if it is a bottom row, skip reading the bottom all together
	add $s0,$s0,$t6 #checking bottom left
	lb $s4,0($s0)
	sub $s0,$s0,$t6
	beq $s4,10,addMine7
cont8:
	add $s0,$s0,$t5 # checking bottom middle
	lb $s4,0($s0)
	sub $s0,$s0,$t5
	beq $s4,10,addMine8
cont9:
	beq $t4,$t6,nextCell # if right edge, don't read bottom right
	add $s0,$s0,$t7 # checking bottom right
	lb $s4,0($s0)
	sub $s0,$s0,$t7
	beq $s4,10,addMine9
	j nextCell
addMinen9:
	addi $t3,$t3,1
	j contn8
addMinen8:
	addi $t3,$t3,1
	j contn7
addMinen7:
	addi $t3,$t3,1
	j contn1
addMinen1:
	addi $t3,$t3,1
	j cont1
addMine1:
	addi $t3,$t3,1
	j cont7
addMine7:
	addi $t3,$t3,1
	j cont8
addMine8:
	addi $t3,$t3,1
	j cont9
addMine9:
	addi $t3,$t3,1
	j nextCell
nextCell:
	addi $t4,$t4,1
	beq $t3,$zero,storeBlank
	sb $t3,0($s0) # stores # of mines near this cell into the cell
	addi $s0,$s0,1
	addi $s1,$s1,1
	add $t3,$zero,$zero
	j initLoop
storeBlank:
	addi $t3,$zero,9
	sb $t3,0($s0) # stores # of mines near this cell into the cell
	addi $s0,$s0,1
	addi $s1,$s1,1
	add $t3,$zero,$zero
	j initLoop
nextCellMine:
	addi $t4,$t4,1
	addi $s0,$s0,1
	addi $s1,$s1,1
	add $t3,$zero,$zero
	j initLoop
copyBoard:
	add $s1,$zero,$zero
	la $s0,board
	la $s7,0xffff8000
	j copyLoop
copyLoop:
	beq $s1,$s2,readEnter
	lb $s4,0($s0)
	sb $s4,0($s7)
	addi $s1,$s1,1
	addi $s7,$s7,1
	addi $s0,$s0,1
	j copyLoop
readEnter:
	li $v0,4
	la $a0,pressEnter
	syscall
enterLoop:
	li $v0,8
  	la $a0, buffer
  	li $a1, 2
   	syscall 
	add $s1,$zero,$zero
	la $s7,0xffff8000
	add $t4,$zero,$zero
	add $t1,$zero,$zero
	li $v0,4
	la $a0,openCellNum
	syscall
	li $v0,1
	add $a0,$zero,$t1
	syscall
	li $v0,4
	la $a0,flagNum
	syscall
	li $v0,1
	add $a0,$zero,$t4
	syscall
	li $v0,4
	la $a0,newLine
	syscall
	j closeLoop
closeLoop:
	beq $s1,$s2,waitStart
	sb $zero,0($s7)
	addi $s1,$s1,1
	addi $s7,$s7,1
	j closeLoop
waitStart:
	add $t9,$zero,$zero
	j wait
wait:
	beq $t9,$zero,wait
	beq $t9,0x200A0808,eightSet # size select Eight
	beq $t9,0x200F0C0C,twelveSet # size select Twelve
	beq $t9,0x20141010,sixteenSet # size select Sixteen
	beq $t9,0x400A0808,eightSet # reset Eight
	beq $t9,0x400F0C0C,twelveSet # reset Twelve
	beq $t9,0x40141010,sixteenSet # reset Sixteen
	#80 is left 00 RR CC
	#88 is right 00 RR CC
	sll $t0,$t9,16
	srl $t0,$t0,24 #$t0 is row
	andi $t2,$t9,0xFF #$t2 is column
	
	srl $t9,$t9,24 #t1 is left or right
	beq $t9,0x80,leftClick
	beq $t9,0x88, rightClick
leftClick:
	add $a0,$zero,$t0
	add $a1,$zero,$t2
	jal boardAddress
	add $s1,$zero,$v0
	
	lb $s4,0($s1)
	beq $s4,0,closedOpen
	bne $s4,0,openNumber
	
	j waitStart
#Start Rec Open for Closed Cell
closedOpen:
	add $a0,$zero,$t0
	add $a1,$zero,$t2
	jal recOpen
doneRec:
	beq $v0,1,failMessage
	li $v0,4
	la $a0,openCellNum
	syscall
	li $v0,1
	add $a0,$zero,$t1
	syscall
	li $v0,4
	la $a0,flagNum
	syscall
	li $v0,1
	add $a0,$zero,$t4
	syscall
	li $v0,4
	la $a0,newLine
	syscall
	j waitStart
recOpen:
	addi $sp,$sp,-12
	sw $ra,8($sp)
	sw $a0,4($sp)
	sw $a1,0($sp)
	slt $s4,$a0,$zero
	beq $s4,1,returnFZero
	slt $s4,$a1,$zero
	beq $s4,1,returnFZero
	jal bufferAddress
	lb $s4,0($v0)
	beq $s4,10,mineFound
	beq $s4,9,nothingFound
	jal boardAddress
	sb $s4,0($v0) #stores number if number
	addi $t1,$t1,1
	j returnZero
mineFound:
	jal bufferAddress
	addi $s4,$zero,13
	sb $s4,0($v0) #stores exploded mine
	addi $t1,$t1,1
	jal boardAddress
	addi $s4,$zero,13
	sb $s4,0($v0) #stores exploded mine
	
	add $s5, $zero, $zero # Counter
	la $s1,board
	la $s7,0xffff8000
revealLoop: #reveals Mines
	beq $s5,$s2,returnOne
	lb $s4,0($s1)
	beq $s4,10,showMine
	beq $s4,13,showMine
	addi $s1,$s1,1
	addi $s7,$s7,1
	addi $s5,$s5,1
	j revealLoop
showMine:
	sb $s4,0($s7)
	addi $s1,$s1,1
	addi $s7,$s7,1
	addi $s5,$s5,1
	j revealLoop
nothingFound:
	jal boardAddress
	sb $s4,0($v0) #stores the nothing
	addi $t1,$t1,1
	beq $a0,0,oNumber3 # if it's bottom row, don't check lower
	beq $a1,0,oNumber1 # if it is left edge
	addi $t7,$a0,-1 #row - 1
	addi $t8,$a1,-1 #col - 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,roNumber1
	jal recOpen
	lw $a0,4($sp)
	lw $a1,0($sp)
	beq $v0,1,returnOne
	j oNumber1
roNumber1:
	addi $a0,$a0,1 
	addi $a1,$a1,1 
	j oNumber1
oNumber1:
	addi $t7,$a0,-1 #row - 1
	add $a0,$zero,$t7
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,roNumber2
	jal recOpen
	lw $a0,4($sp)
	lw $a1,0($sp)
	beq $v0,1,returnOne
	j oNumber2
roNumber2:
	addi $a0,$a0,1 
	j oNumber2
oNumber2:
	beq $a1,$t6,oNumber3
	addi $t7,$a0,-1 #row - 1
	addi $t8,$a1,1 #col + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,roNumber3
	jal recOpen
	lw $a0,4($sp)
	lw $a1,0($sp)
	beq $v0,1,returnOne
	j oNumber3
roNumber3:
	addi $a0,$a0,1 
	addi $a1,$a1,-1 
	j oNumber3
oNumber3:
	beq $a1,0,oNumber4
	addi $t8,$a1,-1 #col - 1
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,roNumber4
	jal recOpen
	lw $a0,4($sp)
	lw $a1,0($sp)
	beq $v0,1,returnOne
	j oNumber4
roNumber4:
	addi $a1,$a1,1 
	j oNumber4
oNumber4:
	beq $a1,$t6,oNumber5
	addi $t8,$a1,1 #col + 1
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,roNumber5
	jal recOpen
	lw $a0,4($sp)
	lw $a1,0($sp)
	beq $v0,1,returnOne
	j oNumber5
roNumber5:
	addi $a1,$a1,-1 
	j oNumber5
oNumber5:
	beq $a0,$t6,oNumber8
	beq $a1,0,oNumber6
	addi $t7,$a0,1 #row + 1
	addi $t8,$a1,-1 #col -1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,roNumber6
	jal recOpen
	lw $a0,4($sp)
	lw $a1,0($sp)
	beq $v0,1,returnOne
	j oNumber6
roNumber6:
	addi $a0,$a0,-1 
	addi $a1,$a1,1 
	j oNumber6
oNumber6:
	addi $t7,$a0,1 #row + 1
	add $a0,$zero,$t7
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,roNumber7
	jal recOpen
	lw $a0,4($sp)
	lw $a1,0($sp)
	beq $v0,1,returnOne
	j oNumber7
roNumber7:
	addi $a0,$a0,-1 
	j oNumber7
oNumber7:
	beq $a1,$t6,oNumber8
	addi $t7,$a0,1 #row + 1
	addi $t8,$a1,1 #col + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,returnZero
	jal recOpen
	lw $a0,4($sp)
	lw $a1,0($sp)
	beq $v0,1,returnOne
oNumber8:
	j returnZero
returnOne:
	lw $ra,8($sp)
	addi $sp,$sp,12
	addi $v0,$zero,1
	jr $ra
returnZero:
	lw $ra,8($sp)
	addi $sp,$sp,12
	add $v0,$zero,$zero
	jr $ra
returnFZero:
	lw $ra,8($sp)
	addi $sp,$sp,12
	add $v0,$zero,$zero
	j doneRec
#End RecOpen for Closed Cell
#Start left-click on open number cell
openNumber:
	add $t9,$zero,$zero
	add $a0,$zero,$t0
	add $a1,$zero,$t2
	jal bufferAddress
	addi $sp,$sp,-4
	lb $s6,0($v0)
	sw $s6,0($sp)
	beq $t0,0,openNumber3 # if it's bottom row, don't check lower
	beq $t2,0,openNumber1
	addi $t7,$t0,-1 #row - 1
	addi $t8,$t2,-1 #col - 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	add $s1,$zero,$v0
	lb $s4,0($s1)
	beq $s4,12,addFlag1
openNumber1:
	addi $t7,$t0,-1 #row - 1
	add $t8,$t2,$zero #col 
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	add $s1,$zero,$v0
	lb $s4,0($s1)
	beq $s4,12,addFlag2
openNumber2:
	beq $t2,$t6,openNumber3
	addi $t7,$t0,-1 #row - 1
	addi $t8,$t2,1 #col + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	add $s1,$zero,$v0
	lb $s4,0($s1)
	beq $s4,12,addFlag3
openNumber3:
	beq $t2,0,openNumber4
	add $t7,$t0,$zero #row
	addi $t8,$t2,-1 #col - 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	add $s1,$zero,$v0
	lb $s4,0($s1)
	beq $s4,12,addFlag4
openNumber4:
	beq $t2,$t6,openNumber5
	add $t7,$t0,$zero #row
	addi $t8,$t2,1 #col + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	add $s1,$zero,$v0
	lb $s4,0($s1)
	beq $s4,12,addFlag5
openNumber5:
	beq $t0,$t6,openNumber8
	beq $t2,0,openNumber6
	addi $t7,$t0,1 #row + 1
	addi $t8,$t2,-1 #col -1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	add $s1,$zero,$v0
	lb $s4,0($s1)
	beq $s4,12,addFlag6
openNumber6:
	addi $t7,$t0,1 #row + 1
	add $t8,$t2,$zero #col
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	add $s1,$zero,$v0
	lb $s4,0($s1)
	beq $s4,12,addFlag7
openNumber7:
	beq $t2,$t6,openNumber8
	addi $t7,$t0,1 #row + 1
	addi $t8,$t2,1 #col + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	add $s1,$zero,$v0
	lb $s4,0($s1)
	beq $s4,12,addFlag8
openNumber8: 
	lw $s6,0($sp)
	addi $sp,$sp,4
	bne $s6,$t9,waitStart
	j openAround
addFlag1:
	addi $t9,$t9,1
	j openNumber1
addFlag2:
	addi $t9,$t9,1
	j openNumber2
addFlag3:
	addi $t9,$t9,1
	j openNumber3
addFlag4:
	addi $t9,$t9,1
	j openNumber4
addFlag5:
	addi $t9,$t9,1
	j openNumber5
addFlag6:
	addi $t9,$t9,1
	j openNumber6
addFlag7:
	addi $t9,$t9,1
	j openNumber7
addFlag8:
	addi $t9,$t9,1
	j openNumber8
openAround:
	beq $t0,0,opNumber3 # if it's bottom row, don't check lower
	beq $t2,0,opNumber1
	addi $t7,$t0,-1 #row - 1
	addi $t8,$t2,-1 #col - 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,opNumber1
	jal recOpen
	beq $v0,1,failMessage
opNumber1:
	addi $t7,$t0,-1 #row - 1
	add $a0,$zero,$t7
	add $a1,$zero,$t2
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,opNumber2
	jal recOpen
	beq $v0,1,failMessage
opNumber2:
	beq $t2,$t6,opNumber3
	addi $t7,$t0,-1 #row - 1
	addi $t8,$t2,1 #col + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,opNumber3
	jal recOpen
	beq $v0,1,failMessage
opNumber3:
	beq $t2,0,opNumber4
	addi $t8,$t2,-1 #col - 1
	add $a0,$zero,$t0
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,opNumber4
	jal recOpen
	beq $v0,1,failMessage
opNumber4:
	beq $t2,$t6,opNumber5
	addi $t8,$t2,1 #col + 1
	add $a0,$zero,$t0
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,opNumber5
	jal recOpen
	beq $v0,1,failMessage
opNumber5:
	beq $t0,0,opNumber8
	beq $t2,0,opNumber6
	addi $t7,$t0,1 #row + 1
	addi $t8,$t2,1 #col + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,opNumber6
	jal recOpen
	beq $v0,1,failMessage
opNumber6:
	addi $t7,$t0,-1 #row + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t2
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,opNumber7
	jal recOpen
	beq $v0,1,failMessage
opNumber7:
	beq $t2,$t6,opNumber8
	addi $t7,$t0,1 #row + 1
	addi $t8,$t2,1 #col + 1
	add $a0,$zero,$t7
	add $a1,$zero,$t8
	jal boardAddress
	lb $s4,0($v0)
	bne $s4,0,opNumber8
	jal recOpen
	beq $v0,1,failMessage
opNumber8:
	j waitStart
rightClick:
	add $a0,$zero,$t0
	add $a1,$zero,$t2
	jal boardAddress
	add $s0,$zero,$v0
	
	lb $s4,0($s0)
	beq $s4,0,closedNoFlag
	beq $s4,12,closedFlag
	
	j waitStart
closedNoFlag:
	addi $s4,$zero,12 
	sb $s4,0($s0) #places flag on top
	addi $t4,$t4,1
	li $v0,4
	la $a0,openCellNum
	syscall
	li $v0,1
	add $a0,$zero,$t1
	syscall
	li $v0,4
	la $a0,flagNum
	syscall
	li $v0,1
	add $a0,$zero,$t4
	syscall
	li $v0,4
	la $a0,newLine
	syscall
	beq $t4,$s3,gameOver
	j waitStart
closedFlag:
	addi $s4,$zero,0 
	sb $s4,0($s0) #removes flag
	addi $t4,$t4,-1
	li $v0,4
	la $a0,openCellNum
	syscall
	li $v0,1
	add $a0,$zero,$t1
	syscall
	li $v0,4
	la $a0,flagNum
	syscall
	li $v0,1
	add $a0,$zero,$t4
	syscall
	li $v0,4
	la $a0,newLine
	syscall
	j waitStart
bufferAddress: #takes in $a0 as row and $a1 as column, returns $v0 as address inside board buffer for row/col
	mult $a0,$t5 #calculates the cell number given the row and column
	mflo $t3
	add $t3,$t3,$a1
	la $s1,board #innerBoard
	add $v0,$s1,$t3
	jr $ra
boardAddress: #takes in $a0 as row and $a1 as column, returns $v0 as address inside physical board for row/col
	mult $a0,$t5 #calculates the cell number given the row and column
	mflo $t3
	add $t3,$t3,$a1
	la $s7,0xffff8000 #innerBoard
	add $v0,$s7,$t3
	jr $ra
failMessage:
	li $v0,4
	la $a0,youLose
	syscall
	j waitStart
failMessage2:
	li $v0,4
	la $a0,youLose2
	syscall
	j waitStart
failMessage3:
	li $v0,4
	la $a0,youLose3
	syscall
	j waitStart
gameOver:
	add $s1,$zero,$zero
	la $s0,board
	la $s7,0xffff8000
	j gameLoop
gameLoop:
	beq $s1,$s2,winMessage
	lb $s4,0($s7)
	beq $s4,12,checkMine
	lb $s4,0($s0)
	beq $s4,10,noFlag
	addi $s1,$s1,1
	addi $s7,$s7,1
	addi $s0,$s0,1
	j gameLoop
checkMine:
	lb $s4,0($s0)
	bne $s4,10,noMine
	addi $s1,$s1,1
	addi $s7,$s7,1
	addi $s0,$s0,1
	j gameLoop
noFlag:
	sb $s4,0($s7)
	j failMessage3
noMine:
	addi $s4,$zero,11
	sb $s4,0($s7)
	j failMessage2
winMessage:
	li $v0,4
	la $a0,youWin
	syscall
	j waitStart
