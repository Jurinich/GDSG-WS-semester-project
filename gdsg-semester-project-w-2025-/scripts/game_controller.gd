extends Node2D

@onready var alarm_ui: CanvasLayer = $ForegroundUILayer
@onready var time_minutes_label: Label = $ForegroundUILayer/TimeContainer/TimeMinutes
@onready var time_colon_label: Label = $ForegroundUILayer/TimeContainer/TimeColon
@onready var time_seconds_label: Label = $ForegroundUILayer/TimeContainer/TimeSeconds
@onready var pause_menu: Control = $ForegroundUILayer/PauseMenu
@export var game_duration: int = 17
@export_range(1, 30, 1) var alarm_threshold: int = 15

var cur_game_time: int

func _ready():
	cur_game_time = game_duration
	update_time_label()
	alarm_ui.set_alarm_state(cur_game_time, alarm_threshold)
	$GameTimer.start()


func timer_tick():
	if (cur_game_time <= 0):
		$GameTimer.stop()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
		return

	cur_game_time -= 1
	update_time_label()
	alarm_ui.set_alarm_state(cur_game_time, alarm_threshold)


func update_time_label():
	var safe_time = cur_game_time if cur_game_time > 0 else 0
	@warning_ignore("integer_division")
	var minute = safe_time / 60
	var second = safe_time % 60
	time_minutes_label.text = str(minute)
	time_colon_label.text = ":"
	time_seconds_label.text = "%02d" % second

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		get_tree().paused = true
		pause_menu.show()
		get_viewport().set_input_as_handled()
