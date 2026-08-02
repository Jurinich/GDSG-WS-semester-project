extends Control

func _on_back_button_pressed():
	GameManager.change_scene(GameManager.Scene.MAIN_MENU)
	AudioManager.playSound(&"menu_select");

func _unhandled_input(event):
	# Now we safely know this event belongs to THIS player
	if event.is_action_pressed("Start"):
		get_viewport().set_input_as_handled()
		_on_back_button_pressed()

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_button_pressed()
