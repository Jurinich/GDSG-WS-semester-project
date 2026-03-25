extends Control

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _unhandled_input(event):
	# Now we safely know this event belongs to THIS player
	if event.is_action_pressed("Start"):
		_on_back_button_pressed()

	if event.is_action_pressed("Credits"):
		_on_back_button_pressed()
