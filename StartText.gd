extends Sprite

func _ready():
	$AnimationPlayer.play("fade in")


func _process(delta):
	if Global.started:
		$AnimationPlayer.play("fade out")

func end():
	queue_free()
