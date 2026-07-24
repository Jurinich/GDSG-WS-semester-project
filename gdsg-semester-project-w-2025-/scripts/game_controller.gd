extends Node2D

@onready var score_ui: ScoreOverlay = $ForegroundUILayer/ScoreOverlay
@onready var pause_menu: PauseMenu = $ForegroundUILayer/PauseMenu
@onready var timer: Timer = $GameTimer
@export var game_duration: int = 180

@export_range(1, 30, 1) var alarm_threshold: int = 15
var cur_game_time: int

@export var layouts: Array[PackedScene]
var current_layout: Node2D

func _ready():
	if GameManager.settings.gamemode == Settings.GameMode.TIME:
		cur_game_time = int(GameManager.settings.time)
		score_ui.set_time(cur_game_time)
		timer.start()
	else:
		alarm_threshold = -1
	if not layouts.is_empty():
		var index = GameManager.settings.layout
		if index < 0:
			current_layout = layouts.pick_random().instantiate()
		else:
			current_layout = layouts[index].instantiate()
		add_child(current_layout)
	else:
		push_warning("No layouts assigned in the inspector!")

func timer_tick():
	if (cur_game_time <= 0):
		timer.stop()
		GameManager.change_scene(GameManager.Scene.MAIN_MENU, true)
		return
	
	cur_game_time -= 1
	score_ui.set_time(cur_game_time)

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		pause_menu.show_menu()
		get_viewport().set_input_as_handled()
