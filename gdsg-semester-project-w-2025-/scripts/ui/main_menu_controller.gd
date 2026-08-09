extends Control

@onready var selection_controller = $"SelectionController"
@onready var looping_menu = $"ButtonBox/LoopingMenu"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	looping_menu.grab_focus();
	looping_menu.button_pressed.connect(_on_looping_menu_button_pressed)
	if OS.has_feature("no_quit"):
		looping_menu.items = looping_menu.items.filter(func(item): return item != "Quit")

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
