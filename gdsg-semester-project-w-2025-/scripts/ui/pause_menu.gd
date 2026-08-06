class_name PauseMenu extends Control

@onready var quit_button: Button = $content/QuitButton;
@onready var continue_button: Button = $content/ContinueButton;

func _ready():
	quit_button.pressed.connect(_on_quit_button_pressed);
	continue_button.pressed.connect(_on_continue);

func show_menu() -> void:
	AudioManager.playSound("pause_menu")
	get_tree().paused = true
	show()
	continue_button.grab_focus()

func _on_quit_button_pressed():
	get_tree().paused = false
	GameManager.change_scene(GameManager.Scene.MAIN_MENU)

func _on_continue():
	GameManager.settings.save()
	get_tree().paused = false
	hide()

func _unhandled_input(event):
	if visible && event.is_action_pressed("Pause"):
		AudioManager.playSound("pause_menu")
		_on_continue()
		get_viewport().set_input_as_handled()
