extends Node

var max_score: int = -1

var left_player_score: int = 0
var right_player_score: int = 0

var left_player_paddle: int = 0
var right_player_paddle: int = 0

var sound_vol: int = 100
var music_vol: int = 100

signal score_changed
signal sound_changed

func reset():
	left_player_score = 0
	right_player_score = 0
	score_changed.emit()

func change_sound(new: int):
	sound_vol = new
	sound_changed.emit()

func change_music(new: int):
	music_vol = new

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
			get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
			return false

	return true


func get_score_formatted() -> String:
	return str(left_player_score) + ":" + str(right_player_score)
