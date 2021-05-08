extends KinematicBody2D
# Movement script

var motion = Vector2()
export var gravity = 2550
export var jump_height = 570
export var friction = 0.91
export var x_speed = 45
export var max_x_speed = 450
export var max_y_speed = 1200
export var start_position = Vector2(-448, -476)
export var snap = false
var movement = Vector2(0, 0)
var land_timer = 0
var wall_hit_timer = 0
var ceiling_cling_timer = 15
var ceiling_cling_buffer = 0
var blink_timer = 0
var jumping = false
var wall_jumping = false
var ceiling_clinging = false
var ceiling_fall = false
var previous = Vector2(0, 0)

func _ready():
	position = start_position

func _physics_process(delta):
	if (not ceiling_clinging or (ceiling_clinging and not ceiling_cling_timer > 0)) and ceiling_cling_buffer > 0: ceiling_cling_buffer -= 1
	if ceiling_clinging and ceiling_cling_timer > 0:
		ceiling_cling_timer -= 1
		if not ceiling_cling_timer > 0 and not ceiling_cling_buffer > 0: ceiling_clinging = false
	if land_timer != 0: land_timer -= 1
	if wall_hit_timer != 0: wall_hit_timer -= 1
	if blink_timer != 0: blink_timer -= 1
	if Input.is_action_pressed("ui_right") and not ceiling_clinging and (not wall_jumping or $Sprite.scale.x > 0):
		if $AnimationPlayer.current_animation != "skid" or Input.is_action_pressed("ui_left"): motion.x += x_speed
		else: motion.x += x_speed/16
		
	if Input.is_action_pressed("ui_left") and not ceiling_clinging and (not wall_jumping or $Sprite.scale.x < 0):
		if $AnimationPlayer.current_animation != "skid" or Input.is_action_pressed("ui_right"): motion.x -= x_speed
		else: motion.x -= x_speed/16
		
	motion.x *= friction
	if abs(motion.x) < 1: motion.x = 0
	if not is_on_floor():
		if $AnimationPlayer.current_animation == "wall slide":
			motion.y += gravity * delta * 0.3
		elif not ceiling_clinging:
			motion.y += gravity * delta
			
	if not is_on_floor():
		if Input.is_action_pressed("ui_up") and motion.y < 0 and jumping == true and not ceiling_clinging: motion.y *= 1.058
		else: jumping = false
		if motion.y > 60: wall_jumping = false


func _process(_delta):
	if is_on_floor():
		ceiling_fall = false
		ceiling_cling_timer = 15
		ceiling_clinging = false
		ceiling_cling_buffer = 0
		motion.y = 0
		jumping = false
		wall_jumping = false
		if previous.y > 800: land_timer = 5
		if abs(previous.x) > x_speed * 6 and abs(motion.x) < x_speed: wall_hit_timer = 5
		snap = true
		if Input.is_action_pressed("ui_up") and snap and land_timer == 0 and wall_hit_timer == 0:
			jumping = true
			snap = false
			var jump_multiplier = abs(motion.x) / 415
			if jump_multiplier < 1: jump_multiplier = 1
			motion.y = -jump_height * jump_multiplier
	elif Input.is_action_pressed("ui_up") and $AnimationPlayer.current_animation == "wall slide" and not (Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left")):
		wall_jumping = true
		snap = false
		motion.y = -1.25 * jump_height
		if $Sprite.scale.x > 0: motion.x = max_x_speed * -1
		else: motion.x = max_x_speed
		
	cap_motion()
	var snap_vector = Vector2(0, 200) if snap else Vector2()
	print(snap_vector)
	previous = motion
	
	if on_ceiling() and Input.is_action_pressed("ui_up") and ceiling_cling_timer > 0:
		ceiling_clinging = true
		ceiling_cling_buffer = 10
	if not on_ceiling() or (not Input.is_action_pressed("ui_up") and not ceiling_cling_buffer > 0) or (not ceiling_cling_buffer > 0 and not ceiling_cling_timer > 0):
		ceiling_clinging = false
		ceiling_cling_buffer = 0
	if ceiling_clinging: motion.y = 0
	if ceiling_clinging and not Input.is_action_pressed("ui_up"): ceiling_cling_timer = 0
	if ceiling_clinging and Input.is_action_pressed("ui_down"):
		ceiling_fall = true
		motion.y = 800
		ceiling_clinging = false
		ceiling_cling_buffer = 0
	movement = move_and_slide_with_snap(motion, snap_vector, Vector2.UP, true, 4, 0.9, false)
	motion.y = movement.y
	update_animation()
	if movement.x == 0: motion.x = 0
	
	if position.y > 1000:
		position = start_position
		motion.x = 0
		motion.y = 0


func cap_motion():
	if motion.x > max_x_speed:
		motion.x = max_x_speed
	if motion.x * -1 > max_x_speed:
		motion.x = max_x_speed *-1
	if motion.y > max_y_speed:
		motion.y = max_y_speed
	if motion.y * -1 > max_y_speed:
		motion.y = max_y_speed *-1


func update_animation():
	if is_on_floor():
		if land_timer > 0:
			$AnimationPlayer.play("land")
			$AnimationPlayer.advance(0)
		elif wall_hit_timer > 0:
			$AnimationPlayer.play("wall hit")
			$AnimationPlayer.advance(0)
		else:
			if movement.x == 0: $AnimationPlayer.play("idle")
			elif abs(motion.x) < 30:
				$AnimationPlayer.play("idle")
			elif not is_on_wall() and not (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
				walk_or_run()
			
			if Input.is_action_pressed("ui_right"):
				if motion.x < -200: $AnimationPlayer.play("skid")
				elif $AnimationPlayer.current_animation == "skid" and motion.x > -30 and Input.is_action_pressed("ui_left"): $AnimationPlayer.play("skid")
				elif not is_on_wall(): walk_or_run()
				if $Sprite.scale.x < 0 and not Input.is_action_pressed("ui_left") and $AnimationPlayer.current_animation != "skid":
					$Sprite.scale.x *= -1
			
			if Input.is_action_pressed("ui_left"):
				if motion.x > 200: $AnimationPlayer.play("skid")
				elif $AnimationPlayer.current_animation == "skid" and motion.x < 30 and Input.is_action_pressed("ui_right"): $AnimationPlayer.play("skid")
				elif not is_on_wall(): walk_or_run()
				if $Sprite.scale.x > 0 and not Input.is_action_pressed("ui_right") and $AnimationPlayer.current_animation != "skid":
					$Sprite.scale.x *= -1
			
			if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right") and $AnimationPlayer.current_animation != "skid":
				$AnimationPlayer.play("idle")
	else:
		if motion.y > 30:
			if (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and next_to_wall():
				if not $AnimationPlayer.current_animation == "wall slide": motion.y *= 0.4
				$AnimationPlayer.play("wall slide")
			elif ceiling_fall: $AnimationPlayer.play("ceiling fall")
			else: $AnimationPlayer.play("fall")
		elif motion.y < -30: $AnimationPlayer.play("jump")
		if ceiling_clinging:
			$AnimationPlayer.play("ceiling", -1, 3)
	if ($AnimationPlayer.current_animation == "idle" and round(rand_range(0, 500)) == 87) and blink_timer == 0:
		blink_timer = 2
		$AnimationPlayer.play("blink")
	if blink_timer > 0 and ($AnimationPlayer.current_animation == "idle" or $AnimationPlayer.current_animation == "blink"): $AnimationPlayer.play("blink")
	if motion.x > 0 and $Sprite.scale.x < 0: $Sprite.scale.x *= -1
	if motion.x < 0 and $Sprite.scale.x > 0: $Sprite.scale.x *= -1


func next_to_wall():
	var test_transform = Transform2D(0.0, position)
	return test_move(test_transform, Vector2(1, 0)) or test_move(test_transform, Vector2(-1, 0))
	
func on_ceiling():
	var test_transform = Transform2D(0.0, position)
	return test_move(test_transform, Vector2(0, -1))

func walk_or_run():
	var current_pos = 0
	if abs(motion.x) < 300:
		if $AnimationPlayer.get_current_animation() == "run":
			 current_pos = $AnimationPlayer.get_current_animation_position()
		$AnimationPlayer.play("walk", -1, abs(motion.x/max_x_speed)+0.3)
		if current_pos != 0: $AnimationPlayer.advance(current_pos)
	else:
		if $AnimationPlayer.get_current_animation() == "walk":
			 current_pos = $AnimationPlayer.get_current_animation_position()
		$AnimationPlayer.play("run", -1, abs(motion.x/max_x_speed))
		if current_pos != 0: $AnimationPlayer.advance(current_pos)
