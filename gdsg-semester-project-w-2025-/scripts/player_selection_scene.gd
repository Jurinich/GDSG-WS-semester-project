extends Control

var selections = []

func _ready():
	for child in get_children():
		if child is PlayerSelectionNode:
			selections.append(child)
			child.ready_changed.connect(check_ready)


func check_ready():
	for selection in selections:
		if selection.player_ready == false:
			return

	get_tree().change_scene_to_file("res://scenes/game.tscn")
