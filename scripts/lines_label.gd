extends Label


func _on_lines_cleared(amount):
	text = "Lines: " + str(GlobalStats.lines)
