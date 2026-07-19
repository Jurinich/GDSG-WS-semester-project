extends Control

@onready var p1_selection: PlayerSelectionNode = $"PlayerSelectionNode1"
@onready var p2_selection: PlayerSelectionNode = $"PlayerSelectionNode2"

func set_selections():
	GameManager.left_player_paddle = p1_selection.get_selection()
	GameManager.right_player_paddle = p2_selection.get_selection()
