extends Node2D


#These are the basic tetris pieces. Simply defined by an array with positions as Vector2i
#(0,0) is the pivot point of pieces
const long_boy = [Vector2i(0,0), Vector2i(-1,0), Vector2i(-2,0), Vector2i(1,0)]
const z_left = [Vector2i(0,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(1,1)]
const z_right = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,1)]
const quad = [Vector2i(0,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(-1,1)]
const l_left = [Vector2i(0,0), Vector2i(-1,0), Vector2i(1,0), Vector2i(1,1)]
const l_right = [Vector2i(0,0), Vector2i(-1,0), Vector2i(-1,1), Vector2i(1,0)]
const cross = [Vector2i(0,0), Vector2i(-1,0), Vector2i(1,0), Vector2i(0,1)]

#Example of extra non-vanilla pieces
const single = [Vector2i(0,0)]
const big_chonker = [Vector2i(0,0), Vector2i(-1,0), Vector2i(-2,0), Vector2i(-3,0), Vector2i(1,0), Vector2i(2,0)]
const u_shape = [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(-1,0), Vector2i(-1,1)]

var current_cells
var old_cells
var current_position: Vector2i
var old_position: Vector2i
var tile_number: int
var preview_tile_number: int

signal piece_moved(direction:Vector2i)


func _ready():
	
	current_cells = get_random_piece(true)
	old_cells = [] + current_cells



func get_random_piece(called_by_piece) -> Array:
	var piece = []
	var rnd_number = randi() % 7
	match rnd_number:
		0: piece += long_boy
		1: piece += z_left
		2: piece += z_right
		3: piece += quad
		4: piece += l_left
		5: piece += l_right
		6: piece += cross
	if called_by_piece:
		tile_number = rnd_number + 1
	else:
		preview_tile_number = rnd_number + 1
	return piece



func _process(delta):
	
	var moved = Vector2i(0, 0)
	
	if Input.is_action_just_pressed("left"):
		moved = Vector2i.LEFT
		$horizontal_timer.start()
	if Input.is_action_just_pressed("right"):
		moved = Vector2i.RIGHT
		$horizontal_timer.start()
	if Input.is_action_just_pressed("down"):
		moved = Vector2i.DOWN
		$vertical_timer.start()
	if Input.is_action_just_pressed("up") and not current_cells == quad:
		rotate_clockwise()
	if Input.is_action_just_pressed("accept"):
		$fall_down_timer.wait_time = 0.01
		$fall_down_timer.start()
	
	if moved != Vector2i(0,0):
		current_position += moved
		emit_signal("piece_moved", moved)



func rotate_clockwise():	#Vectors can easily be rotated by 90 degrees if we either invert x or y and then flip both values.
	for i in current_cells.size():
		var new_x = current_cells[i].y * -1
		current_cells[i].y = current_cells[i].x
		current_cells[i].x = new_x
	emit_signal("piece_moved", Vector2i(0,0))



func _fall_down_timer_timeout():
	current_position += Vector2i.DOWN
	emit_signal("piece_moved", Vector2i.DOWN)



func _on_horizontal_timer_timeout():
	var moved = Vector2i(0, 0)
	if Input.is_action_pressed("left"):
		moved = Vector2i.LEFT
	elif Input.is_action_pressed("right"):
		moved = Vector2i.RIGHT
	else:
		$horizontal_timer.wait_time = .2
		return
	$horizontal_timer.wait_time = .075
	$horizontal_timer.start()
	current_position += moved
	emit_signal("piece_moved", moved)



func _on_vertical_timer_timeout():
	if Input.is_action_pressed("down"):
			current_position += Vector2i.DOWN
			emit_signal("piece_moved", Vector2i.DOWN)
			$vertical_timer.wait_time = .04
			$vertical_timer.start()
	else:
		$vertical_timer.wait_time = .2
