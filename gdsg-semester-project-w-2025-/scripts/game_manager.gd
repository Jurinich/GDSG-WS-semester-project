extends Node

signal score_changed

var ball_limit: int = 20

var left_player_score: int = 0
var right_player_score: int = 0

var left_player_paddle: Paddle
var right_player_paddle: Paddle

var arcade_mode = false
var arcade_p1_id = -1
var arcade_p2_id = 1

var settings: Settings = Settings.new()

enum Scene {
	MAIN_MENU, GAME, SETTINGS, CREDITS, ARCADE_CALIBRATION
}

const SCENE_FILES: Dictionary = {
	Scene.MAIN_MENU: "res://scenes/ui/main_menu.tscn",
	Scene.GAME: "res://scenes/game.tscn",
	Scene.SETTINGS: "res://scenes/ui/settings_scene.tscn",
	Scene.CREDITS: "res://scenes/ui/credits_scene.tscn",
	Scene.ARCADE_CALIBRATION: "res://scenes/ui/arcade_calibration.tscn"
}

func _ready() -> void:
	settings.load()

func reset():
	left_player_score = 0
	right_player_score = 0
	score_changed.emit()

# function returns true if the game should continue on
func add_point(player : String) -> bool:
	match player.to_lower():
		"left":
			left_player_score += 1
		"right":
			right_player_score += 1
	print("Score:", left_player_score, " - ", right_player_score)
	score_changed.emit()
	
	if (settings.gamemode == Settings.GameMode.SCORE):
		if (left_player_score >= settings.score || right_player_score >= settings.score):
			change_scene(Scene.MAIN_MENU, true)
			return false

	return true

func change_scene(scene: Scene, deferred: bool = false) -> void:
	if deferred:
		get_tree().call_deferred("change_scene_to_file", SCENE_FILES[scene])
	else:
		get_tree().change_scene_to_file(SCENE_FILES[scene])

func get_score_formatted() -> String:
	return str(left_player_score) + ":" + str(right_player_score)

func _unhandled_input(event):
	if event.is_action_pressed("Quit"):
		get_tree().quit()

func can_spawn_more() -> bool:
	var current_ball_count = get_tree().get_nodes_in_group("balls").size()
	return current_ball_count < ball_limit
