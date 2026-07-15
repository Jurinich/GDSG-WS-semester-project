extends Node

var max_score: int = -1
var ball_limit: int = 20;

var left_player_score: int = 0
var right_player_score: int = 0

var left_player_paddle: int = 0
var right_player_paddle: int = 0

var sound_vol: int = 100
var music_vol: int = 100

var arcade_mode = false
var arcade_p1_id = -1
var arcade_p2_id = 1

var game_mode = GameMode.TIME

signal score_changed
signal sound_changed

enum GameMode {TIME, SCORE}

func reset():
	left_player_score = 0
	right_player_score = 0
	score_changed.emit()

func change_sound(new: int):
	sound_vol = new
	sound_changed.emit()

func change_music(new: int):
	music_vol = new
	sound_changed.emit()

# function returns true if the game should continue on
func add_point(player : String) -> bool:
	match player.to_lower():
		"left":
			left_player_score += 1
		"right":
			right_player_score += 1
	print("Score:", left_player_score, " - ", right_player_score)
	score_changed.emit()

	if (max_score > 0):
		if (left_player_score >= max_score || right_player_score >= max_score):
			get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")
			return false

	return true

func get_score_formatted() -> String:
	return str(left_player_score) + ":" + str(right_player_score)

func _unhandled_input(event):
	if event.is_action_pressed("Quit"):
		get_tree().quit()

func can_spawn_more() -> bool:
	var current_ball_count = get_tree().get_nodes_in_group("balls").size()
	print("balls ", current_ball_count)
	return current_ball_count < ball_limit
