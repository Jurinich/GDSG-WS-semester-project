extends Node
var left_player_score : int = 0
var right_player_score : int = 0

signal score_changed

func reset():
	left_player_score = 0
	right_player_score = 0
	score_changed.emit()

func add_point(player : String) -> void:
	match player.to_lower():
		"left":
			left_player_score += 1
		"right":
			right_player_score += 1
	print("Score:", left_player_score, " - ", right_player_score)
	score_changed.emit()
