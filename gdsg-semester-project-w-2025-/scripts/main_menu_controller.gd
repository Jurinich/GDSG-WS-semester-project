extends Control

@onready var info_label: Label = $"InfoLabel"
@onready var selection_controller = $"SelectionController"


func _ready():
	if (GameManager.left_player_score <= 0 && GameManager.right_player_score <= 0):
		info_label.text = ""
	else:
		info_label.text = get_winner_text()


func _on_start_button_pressed():
	GameManager.reset()
	selection_controller.set_selections()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings_scene.tscn")


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://scenes/credits_scene.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func get_winner_text() -> String:
	var winner_msg = "%s Player won!" % (
		"Left" if (GameManager.left_player_score > GameManager.right_player_score) else "Right"
	)

	return winner_msg + "\n" + GameManager.get_score_formatted()
