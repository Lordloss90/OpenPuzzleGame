extends TileMap

@onready var piece = preload("res://scenes/piece.tscn")

const lower_bounds = Vector2i(11, 6)
const upper_bounds = Vector2i(20, 25)

var entry_point = Vector2i(lower_bounds.x + ((upper_bounds.x - lower_bounds.x) / 2 + 1), lower_bounds.y)
var preview_point = Vector2i(upper_bounds.x + 6, lower_bounds.y + 3)

var current_piece

var current_preview: Array
var current_preview_tile_number: int
var old_preview: Array

var rows_to_clear = []
var blocks_to_clear = []
var animation_timer = 0.0
var animation_started = false

signal lines_cleared(amount:int)



func _ready():
	
	#initialize RNG
	randomize()
	
	spawn_piece()



func _process(delta):
	if rows_to_clear.size() > 0:
		block_remove_animation_step(delta)



func block_remove_animation_step(delta):
	if !animation_started and blocks_to_clear.size() == 0:
		for x in range(lower_bounds.x, upper_bounds.x + 1):
			blocks_to_clear.append(x)
		animation_started = true
	
	animation_timer += delta
	
	if animation_timer >= 0.08: 	#this number controls at which speed blocks get removed
		animation_timer = 0
		for y in rows_to_clear:
			set_cell(0, Vector2i(blocks_to_clear.front(),y), 0, Vector2i(0, 0), 0)
			set_cell(0, Vector2i(blocks_to_clear.back(),y), 0, Vector2i(0, 0), 0)
		blocks_to_clear.pop_front()
		blocks_to_clear.pop_back()
	
	if animation_started and blocks_to_clear.size() == 0: 	#Animation has finished
		for i in rows_to_clear:
			push_down_rows(i)
		rows_to_clear = []
		animation_started = false
		spawn_piece()



func set_preview_piece():
	current_preview = current_piece.get_random_piece(false)
	current_preview_tile_number = current_piece.preview_tile_number
	
	for pos in old_preview:
		set_cell(0, preview_point + pos, -1, Vector2i(0, 0), 0)
	
	for pos in current_preview:
		set_cell(0, preview_point + pos, 1, Vector2i(0, 0), current_preview_tile_number)
	
	old_preview = [] + current_preview



func spawn_piece():
	current_piece = piece.instantiate()
	add_child(current_piece)
	if current_preview.size() > 0:
		current_piece.current_cells = [] + current_preview
		current_piece.tile_number = current_preview_tile_number
		current_piece.old_cells = [] + current_preview
	current_piece.old_position = entry_point
	current_piece.current_position = entry_point
	current_piece.piece_moved.connect(_on_piece_moved)
	check_for_failure()
	render_piece()
	set_preview_piece()



func check_for_failure():
	for pos in current_piece.current_cells:
		if get_cell_source_id(0, current_piece.current_position + pos) == 2:
			game_over()



func game_over():
	if $SoundCheckbox.button_pressed:
		$GameEndPlayer.play()
	current_piece.queue_free()
	for y in range(lower_bounds.y + 7, lower_bounds.y + 12):
		for x in range(lower_bounds.x, upper_bounds.x + 1):
			set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)
	$GameOverLabel/AnimationPlayer.play("game_over")



func reset_game():
	GlobalStats.lines = 0
	GlobalStats.score = 0
	GlobalStats.score_changed.emit(0)
	lines_cleared.emit(0)
	for y in range(lower_bounds.y, upper_bounds.y + 1):
		for x in range(lower_bounds.x, upper_bounds.x + 1):
			set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)
	spawn_piece()



func _on_piece_moved(direction:Vector2i):
	if is_position_valid():
		render_piece()
		current_piece.old_position = current_piece.current_position
		current_piece.old_cells = [] + current_piece.current_cells
	else:
		current_piece.current_position = current_piece.old_position
		current_piece.current_cells = [] + current_piece.old_cells
		if direction == Vector2i.DOWN:
			lock_piece()



func lock_piece():
	for pos in current_piece.current_cells:
		if current_piece.current_position.y + pos.y >= lower_bounds.y:	#Dont render cell which is out of bounds
			set_cell(0, current_piece.current_position + pos, 2, Vector2i(0, 0), current_piece.tile_number)
	current_piece.queue_free()
	
	
	var full_rows = check_rows()
	if full_rows.size() > 0:
		GlobalStats.lines += full_rows.size()
		lines_cleared.emit(full_rows.size())
		rows_to_clear = full_rows
	else:
		GlobalStats.add_score(5+GlobalStats.level)	#score for block placed
		if $SoundCheckbox.button_pressed:
			$BlockPlaceSoundPlayer.play()
		spawn_piece()



func check_rows() -> Array:
	var full_rows = []
	for y in range(lower_bounds.y, upper_bounds.y +1):
		var found_empty = false
		for x in range(lower_bounds.x, upper_bounds.x + 1):
			if get_cell_source_id(0, Vector2i(x, y)) != 2:
				found_empty = true
		if not found_empty:
			if $SoundCheckbox.button_pressed:
				$RowClearPlayer.play()
			full_rows.append(y)
	return full_rows



func push_down_rows(full_row):
	for y in range(full_row, lower_bounds.y -1, -1):
		for x in range(lower_bounds.x, upper_bounds.x + 1):
			var target_id = get_cell_source_id(0, Vector2i(x, y - 1))
			var target_alternative = get_cell_alternative_tile(0, Vector2i(x, y - 1))
			if target_id == -1:
				target_id = 0
				target_alternative = 0
			set_cell(0, Vector2i(x,y), target_id, Vector2i(0, 0), target_alternative)



func is_position_valid() -> bool:
	for pos in current_piece.current_cells:
		var id = get_cell_source_id(0, current_piece.current_position + pos)
		#allow clipping through upper end of board. id 2: locked tiles, id -1: Empty tiles
		if (current_piece.current_position + pos).y >= lower_bounds.y and (id == 2 or id == -1):
			return false
		if(current_piece.current_position + pos).x < lower_bounds.x or (current_piece.current_position + pos).x > upper_bounds.x:
			return false
	return true



func render_piece():
	for pos in current_piece.old_cells:
		#dont render cells which are above board (through rotating)
		if (current_piece.old_position + pos).y >= lower_bounds.y:
			set_cell(0, current_piece.old_position + pos, 0, Vector2i(0, 0), 0)
	
	for pos in current_piece.current_cells:
		#dont render cells which are above board (through rotating)
		if (current_piece.current_position + pos).y >= lower_bounds.y:
			set_cell(0, current_piece.current_position + pos, 1, Vector2i(0, 0), current_piece.tile_number)
