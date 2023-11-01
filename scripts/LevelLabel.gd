extends Label



func _on_lines_cleared(amount):
	text = "Level: " + str((GlobalStats.level))
