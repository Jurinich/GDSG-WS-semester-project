class_name GameOverMenu extends Control

@onready var quit_button: Button = $content/Buttons/QuitButton
@onready var replay_button: Button = $content/Buttons/ReplayButton
@onready var score: Label = $content/Buttons/Score
@onready var winner: Label = $content/Buttons/Winner

func _ready():
	quit_button.pressed.connect(_on_quit_button_pressed);
	replay_button.pressed.connect(_on_replay);

func show_menu(left: int, right: int) -> void:
	AudioManager.playSound("pause_menu")
	get_tree().paused = true
	if left > right:
		winner.text = "Left Player won!"
	elif left < right:
		winner.text = "Right Player won!"
	else:
		winner.text = "Draw!"
	score.text = str(left) + " : " + str(right)
	show()
	replay_button.grab_focus()

func _on_quit_button_pressed():
	get_tree().paused = false
	GameManager.change_scene(GameManager.Scene.MAIN_MENU)

func _on_replay():
	get_tree().paused = false
	GameManager.change_scene(GameManager.Scene.GAME)
