extends Label

@onready var score_up = preload("res://scenes/score_up.tscn")

func _ready():
	GlobalStats.score_changed.connect(_on_score_changed)



func _on_score_changed(amount):

	text = "Score: " + str(GlobalStats.score)
	if amount > 0:	#instantiate the score animation
		var instance = score_up.instantiate()
		add_child(instance)
		instance.text = "+" + str(amount)
