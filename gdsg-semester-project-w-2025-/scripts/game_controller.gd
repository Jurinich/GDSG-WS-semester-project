extends Node2D

signal score_changed(left: int, right: int)

@onready var score_ui: ScoreOverlay = $ForegroundUILayer/ScoreOverlay
@onready var pause_menu: PauseMenu = $ForegroundUILayer/PauseMenu
@onready var gameover_menu: GameOverMenu = $ForegroundUILayer/GameoverMenu
@onready var goal_left: Area2D = $Goals/LeftGoal
@onready var goal_right: Area2D = $Goals/RightGoal
@onready var ball_spawner: BallSpawner = $BallSpawnTimer
@onready var timer: Timer = $GameTimer
@export var game_duration: int = 180

@export_range(1, 30, 1) var alarm_threshold: int = 15
var cur_game_time: int

@export var layouts: Array[PackedScene]
var current_layout: Node2D

var left_player_score: int = 0
var right_player_score: int = 0

func _ready():
	score_changed.connect(score_ui.set_score)
	goal_left.goal_scored.connect(_add_point)
	goal_right.goal_scored.connect(_add_point)
	if GameManager.settings.gamemode == Settings.GameMode.TIME:
		cur_game_time = int(GameManager.settings.time)
		score_ui.set_time(cur_game_time)
	else:
		alarm_threshold = -1
	_load_layout()
	await get_tree().create_timer(1.0).timeout
	_start_game()

func _start_game() -> void:
	ball_spawner.activate_spawner()
	if GameManager.settings.gamemode == Settings.GameMode.TIME:
		timer.start()

func _load_layout() -> void:
	if not layouts.is_empty():
		var index = GameManager.settings.layout
		if index < 0:
			current_layout = layouts.pick_random().instantiate()
		else:
			current_layout = layouts[index].instantiate()
		add_child(current_layout)
	else:
		push_warning("No layouts assigned in the inspector!")

func _add_point(p1: bool) -> void:
	if p1:
		left_player_score += 1
	else:
		right_player_score += 1
	score_changed.emit(left_player_score, right_player_score)
	
	if _max_score_reached(false) || _max_score_reached(true):
		gameover_menu.show_menu(left_player_score, right_player_score)
		return
	
	var balls_in_play = get_tree().get_nodes_in_group("balls").size()
	if balls_in_play == 0:
		ball_spawner.spawn_ball()

func _max_score_reached(p1: bool) -> bool:
	if GameManager.settings.gamemode != Settings.GameMode.SCORE:
		return false
	if p1:
		return left_player_score >= GameManager.settings.score
	else:
		return right_player_score >= GameManager.settings.score

func timer_tick():
	if (cur_game_time <= 0):
		timer.stop()
		gameover_menu.show_menu(left_player_score, right_player_score)
		AudioManager.playSound("Time_end");
		return
	
	if(cur_game_time > 0 && cur_game_time <= 15):
		AudioManager.playSound("Time_beep");
	
	cur_game_time -= 1
	score_ui.set_time(cur_game_time)

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		pause_menu.show_menu()
		get_viewport().set_input_as_handled()
