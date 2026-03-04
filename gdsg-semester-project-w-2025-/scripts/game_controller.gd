extends Node2D

@onready var time_label: Label = $ForegroundUILayer/TimeLabel
@export var game_duration: int = 180

var cur_game_time: int

func _ready():
	cur_game_time = game_duration
	update_time_label()
	$GameTimer.start()


func timer_tick():
	if (cur_game_time <= 0):
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

	cur_game_time -= 1
	update_time_label()


func update_time_label():
	@warning_ignore("integer_division")
	var minute = cur_game_time / 60
	var second = cur_game_time % 60
	time_label.text = str(minute) + ":" + ("%02d" % second)
