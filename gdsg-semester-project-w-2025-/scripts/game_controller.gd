extends Node2D

@onready var alarm_ui: CanvasLayer = $BackgroundUILayer
@onready var time_minutes_label: Label = $BackgroundUILayer/TimeContainer/TimeMinutes
@onready var time_colon_label: Label = $BackgroundUILayer/TimeContainer/TimeColon
@onready var time_seconds_label: Label = $BackgroundUILayer/TimeContainer/TimeSeconds
@onready var pause_menu: Control = $ForegroundUILayer/PauseMenu
@onready var timer: Timer = $GameTimer
@export var game_duration: int = 180

@export_range(1, 30, 1) var alarm_threshold: int = 15
var cur_game_time: int

@export var layouts: Array[PackedScene]
var current_layout: Node2D

func _ready():
	if GameManager.settings.gamemode == Settings.GameMode.TIME:
		cur_game_time = int(GameManager.settings.time)
		timer.start()
	update_time_label()
	alarm_ui.set_alarm_state(cur_game_time, alarm_threshold)
	if not layouts.is_empty():
		var random_scene: PackedScene = layouts.pick_random()
		current_layout = random_scene.instantiate()
		add_child(current_layout)
	else:
		push_warning("No layouts assigned in the inspector!")

func timer_tick():
	if (cur_game_time <= 0):
		timer.stop()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")
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
		AudioManager.playSound("pause_menu")
		get_tree().paused = true
		pause_menu.show()
		get_viewport().set_input_as_handled()
