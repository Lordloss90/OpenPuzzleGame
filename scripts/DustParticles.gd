extends CPUParticles2D

func _ready():
	emitting = true


func _on_end_timer_timeout():
	queue_free()
