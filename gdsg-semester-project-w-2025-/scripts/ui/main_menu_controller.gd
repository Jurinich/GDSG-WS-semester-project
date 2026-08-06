extends Control

@onready var selection_controller = $"SelectionController"
@onready var looping_menu = $"ButtonBox/LoopingMenu"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	looping_menu.grab_focus();
	looping_menu.button_pressed.connect(_on_looping_menu_button_pressed)

	if GameManager.arcade_mode:
		if GameManager.arcade_p1_id == -1:
			GameManager.change_scene(GameManager.Scene.ARCADE_CALIBRATION)

	else:
		$"SelectionController/PlayerSelectionNode1/ArControls".visible = false
		$"SelectionController/PlayerSelectionNode2/ArControls2".visible = false

func _on_looping_menu_button_pressed(button: String) -> void:
	match button:
		"Start Game":
			selection_controller.set_selections()
			GameManager.change_scene(GameManager.Scene.GAME)
		"Settings":
			GameManager.change_scene(GameManager.Scene.SETTINGS)
		"Credits":
			GameManager.change_scene(GameManager.Scene.CREDITS)
		"Quit":
			get_tree().quit()
