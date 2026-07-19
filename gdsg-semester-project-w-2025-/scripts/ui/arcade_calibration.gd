extends Control

var p1 = true

func _unhandled_input(event):
	if not event.is_pressed():
		return

	if p1:
		GameManager.arcade_p1_id = event.device
		print("p1 is device: " + str(GameManager.arcade_p1_id))
		$"InfoLabel".text = "Player 2 (right)\nPress any Button"
		p1 = false
	else:
		if event.device == GameManager.arcade_p1_id:
			$"Calibr".text = "They cannot be the same\nTry again"
			$"InfoLabel".text = "Player 1 (left)\nPress any Button"
			p1 = true
			return

		GameManager.arcade_p2_id = event.device
		print("p2 is device: " + str(GameManager.arcade_p1_id))
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
