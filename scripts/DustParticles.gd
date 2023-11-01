extends CPUParticles2D

#probably add dust particles on block placement, currently not implemented

func _ready():
	emitting = true


func _on_end_timer_timeout():
	queue_free()
