extends Node2D

@onready var win_condition_label: Label = $ForegroundUILayer/WinConditionLabel
@onready var left_goal = $"Goals/LeftGoal"
@onready var right_goal = $"Goals/RightGoal"

@export var time_limit: int = 180
@export var score_limit: int = 15

const GameMode = GameManager.GameMode


var cur_game_time: int

func _ready():
	left_goal.goal_scored.connect(_goal_scored)
	right_goal.goal_scored.connect(_goal_scored)
	match GameManager.game_mode:
		GameMode.TIME:
			cur_game_time = time_limit
			update_time_label()
			$GameTimer.start()
		GameMode.SCORE:
			set_score_label()
			

func set_score_label():
	win_condition_label.text = "Goals for win: " + str(score_limit)

func timer_tick():
	if (cur_game_time <= 0):
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

	cur_game_time -= 1
	update_time_label()

func _goal_scored():
	if GameManager.game_mode != GameMode.SCORE:
		return
		
	if GameManager.left_player_score >= score_limit or GameManager.right_player_score >= score_limit:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
	

func update_time_label():
	@warning_ignore("integer_division")
	var minute = cur_game_time / 60
	var second = cur_game_time % 60
	win_condition_label.text = str(minute) + ":" + ("%02d" % second)
