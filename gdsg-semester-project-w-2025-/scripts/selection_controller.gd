extends Control

@onready var p1_selection: PlayerSelectionNode = $"PlayerSelectionNode1"
@onready var p2_selection: PlayerSelectionNode = $"PlayerSelectionNode2"

func set_selections():
	GameManager.left_player_paddle = p1_selection.cur_index
	GameManager.right_player_paddle = p2_selection.cur_index