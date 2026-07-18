extends Node2D

@onready var time_label: Label = $ForegroundUILayer/TimeLabel
@onready var pause_menu: Control = $ForegroundUILayer/PauseMenu
@export var game_duration: int = 180
@export var layouts: Array[PackedScene]
var current_layout: Node2D
var cur_game_time: int

func _ready():
	cur_game_time = game_duration
	update_time_label()
	$GameTimer.start()
	if not layouts.is_empty():
		var random_scene: PackedScene = layouts.pick_random()
		current_layout = random_scene.instantiate()
		add_child(current_layout)
	else:
		push_warning("No layouts assigned in the inspector!")

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

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		get_tree().paused = true
		pause_menu.show()
		get_viewport().set_input_as_handled()
