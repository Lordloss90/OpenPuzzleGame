extends Label


func _process(delta):
	if Input.is_action_just_pressed("accept") or Input.is_action_just_pressed("cancel"):
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
			get_parent().reset_game()
