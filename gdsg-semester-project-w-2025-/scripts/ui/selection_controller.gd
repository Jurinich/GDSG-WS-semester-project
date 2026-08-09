extends Control

@onready var p1_selection: PlayerSelectionNode = $"PlayerSelectionNode1"
@onready var p2_selection: PlayerSelectionNode = $"PlayerSelectionNode2"

func set_selections() -> void:
	GameManager.left_player_paddle = p1_selection.get_selection()
	GameManager.right_player_paddle = p2_selection.get_selection()

func swap_sides() -> void:
	var temp: int = p1_selection.index
	p1_selection.index = p2_selection.index
	p2_selection.index = temp
	p1_selection.update_texture()
	p2_selection.update_texture()
