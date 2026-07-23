extends Control


func _on_time_button_pressed() -> void:
	GameManager.game_mode = GameManager.GameMode.TIME
	GameManager.change_scene(GameManager.Scene.MAIN_MENU)


func _on_score_button_pressed() -> void:
	GameManager.game_mode = GameManager.GameMode.SCORE
	GameManager.change_scene(GameManager.Scene.MAIN_MENU)
