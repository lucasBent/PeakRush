extends RichTextLabel

var frame_by_frame = false

func _physics_process(_delta):
	if frame_by_frame: get_tree().paused = true
	if Input.is_action_just_pressed("ui_accept"):
		if not frame_by_frame: frame_by_frame = true
		else: get_tree().paused = false
	if Input.is_action_just_pressed("ui_end"):
		if frame_by_frame: frame_by_frame = false
		get_tree().paused = false

func _process(delta):
	if not delta == 0: text = "fps: " + str(1/delta)
	text += "\nPlayer.motion.x: " + str($"/root/Main/Player".motion.x)
	text += "\nPlayer.motion.y: " + str($"/root/Main/Player".motion.y)
	text += "\nPlayer animation: " + $"/root/Main/Player".get_node("AnimationPlayer").current_animation
	text += "\nPlayer next to wall: " + str($"/root/Main/Player".next_to_wall())
	text += "\nceiling_cling_timer: " + str($"/root/Main/Player".ceiling_cling_timer)
	text += "\nceiling_clinging: " + str($"/root/Main/Player".ceiling_clinging)
	text += "\nceiling_cling_buffer: " + str($"/root/Main/Player".ceiling_cling_buffer)
	text += "\nwall_hit_timer: " + str($"/root/Main/Player".wall_hit_timer)
