extends Control

func _on_back_button_pressed():
	GameManager.change_scene(GameManager.Scene.MAIN_MENU)

func _unhandled_input(event):
	# Now we safely know this event belongs to THIS player
	if event.is_action_pressed("Start"):
		_on_back_button_pressed()

	if event.is_action_pressed("Credits"):
		_on_back_button_pressed()
