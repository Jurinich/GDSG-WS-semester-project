extends Control

@onready var p1_selection: PlayerSelectionNode = $"PlayerSelectionNode1"
@onready var p2_selection: PlayerSelectionNode = $"PlayerSelectionNode2"

func set_selections():
	GameManager.left_player_paddle = p1_selection.cur_index
	GameManager.right_player_paddle = p2_selection.cur_index
	
	if GameManager.left_player_paddle == GameManager.BONE_INDEX1 || GameManager.left_player_paddle == GameManager.BONE_INDEX2:
		GameManager.left_player_paddle = GameManager.SpriteType.BONE;
	else:
		GameManager.left_player_paddle = GameManager.SpriteType.REGULAR;
		
	if GameManager.right_player_paddle == GameManager.BONE_INDEX1 || GameManager.right_player_paddle == GameManager.BONE_INDEX2:
		GameManager.right_player_paddle = GameManager.SpriteType.BONE;
	else:
		GameManager.right_player_paddle = GameManager.SpriteType.REGULAR;
