extends Timer

#this timer handles the automatic falling of the current piece. It is dependent on the level. The formula at which difficulty scales is defined in GlobalStats

func _ready():
	wait_time = GlobalStats.fall_time
