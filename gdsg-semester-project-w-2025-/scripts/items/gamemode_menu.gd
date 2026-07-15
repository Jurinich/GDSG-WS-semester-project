extends Control


func _on_time_button_pressed() -> void:
	GameManager.game_mode = GameManager.GameMode.TIME
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_score_button_pressed() -> void:
	GameManager.game_mode = GameManager.GameMode.SCORE
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
