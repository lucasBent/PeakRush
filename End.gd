extends ColorRect

func end():
	$CenterContainer/Label.text = "YOU WIN!\nTotal time: " + str(float(OS.get_ticks_msec() - Global.start_time) / 1000) + " seconds\nDeaths: " + str(Global.deaths)
	$AnimationPlayer.play("slide in")

func _ready():
	rect_position.x = -1940
