extends Control

@onready var info_label: Label = $"InfoLabel"
@onready var selection_controller = $"SelectionController"
@onready var looping_menu = $"ButtonBox/LoopingMenu"
@onready var start_button = $"ButtonBox/LoopingMenu/StartButton"
@onready var settings_button = $"ButtonBox/LoopingMenu/SettingsButton"
@onready var credits_button = $"ButtonBox/LoopingMenu/CreditsButton"
@onready var quit_button = $"ButtonBox/LoopingMenu/QuitButton"

func _ready():
	looping_menu.grab_focus()
	start_button.pressed.connect(_on_start)
	settings_button.pressed.connect(_on_settings)
	credits_button.pressed.connect(_on_credits)
	quit_button.pressed.connect(_on_quit)
	if (GameManager.left_player_score <= 0 && GameManager.right_player_score <= 0):
		info_label.text = ""
	else:
		info_label.text = get_winner_text()

	if GameManager.arcade_mode:
		if GameManager.arcade_p1_id == -1:
			get_tree().change_scene_to_file("res://scenes/ui/arcade_calibration.tscn")

	else:
		$"SelectionController/PlayerSelectionNode1/ArControls".visible = false
		$"SelectionController/PlayerSelectionNode2/ArControls2".visible = false


func _on_start() -> void:
	GameManager.reset()
	selection_controller.set_selections()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings_scene.tscn")

func _on_credits() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/credits_scene.tscn")

func _on_quit() -> void:
	get_tree().quit()

func get_winner_text() -> String:
	var winner_msg = "%s Player won!" % (
		"Left" if (GameManager.left_player_score > GameManager.right_player_score) else "Right"
	)

	return winner_msg + "\n" + GameManager.get_score_formatted()
