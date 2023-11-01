extends Node

var lines = 0: set = setLines
var level = 0
var fall_time = 1.0
var score = 0

signal score_changed(amount:int)


#setter-function of lines. Everytime lines get changed also the level, score and difficulty get updated.
func setLines(amount):
	level = amount/10
	if amount > lines:	#if new lines are positive, add score
		calculate_score(amount-lines)
	lines = amount
	update_fall_time()

#TODO: Change the difficulty increase: higher increase in earlygame, lower increase in lategame. Currently it takes a while until speedup is noticeable
func update_fall_time():
	var new_time = 1.0
	for i in range(1, level + 1):	#the piece falls faster for each level
		new_time -= new_time / 9
	fall_time = new_time


func add_score(amount):
	score += amount
	score_changed.emit(amount)


func calculate_score(lines):
	var new_score = 0
	match(lines):	#current score formula for lines
		1:	new_score = 50 + (5 * level)
		2:	new_score = 150 + (15 * level)
		3:	new_score = 250 + (20 * level)
		4:	new_score = 500 + (30 * level)
	new_score += 5 + level	#score for block placed
	add_score(new_score)
