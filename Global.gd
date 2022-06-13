extends Node2D

var start_time
var started = false
var end = false
var deaths = 0

func _process(_delta):
	if not started and (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
		started = true
		start_time = OS.get_ticks_msec()
	if end and $Music.playing: $Music.stop()
