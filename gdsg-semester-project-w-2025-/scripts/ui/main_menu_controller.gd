extends Control

@onready var info_label: Label = $"InfoLabel"
@onready var selection_controller = $"SelectionController"
@onready var looping_menu = $"ButtonBox/LoopingMenu"


func _ready():
	looping_menu.grab_focus();
	looping_menu.button_pressed.connect(_on_looping_menu_button_pressed)
	if (GameManager.left_player_score <= 0 && GameManager.right_player_score <= 0):
		info_label.text = ""
	else:
		info_label.text = get_winner_text()

	if GameManager.arcade_mode:
		if GameManager.arcade_p1_id == -1:
			get_tree().change_scene_to_file("res://scenes/ArcadeCalibration.tscn")

	else:
		$"SelectionController/PlayerSelectionNode1/ArControls".visible = false
		$"SelectionController/PlayerSelectionNode2/ArControls2".visible = false

func _on_looping_menu_button_pressed(button: String) -> void:
	match button:
		"Start Game":
			GameManager.reset()
			selection_controller.set_selections()
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		"Settings":
			get_tree().change_scene_to_file("res://scenes/ui/settings_scene.tscn")
		"Credits":
			get_tree().change_scene_to_file("res://scenes/ui/credits_scene.tscn")
		"Quit":
			get_tree().quit()

func get_winner_text() -> String:
	var winner_msg = "%s Player won!" % (
		"Left" if (GameManager.left_player_score > GameManager.right_player_score) else "Right"
	)

	return winner_msg + "\n" + GameManager.get_score_formatted()
