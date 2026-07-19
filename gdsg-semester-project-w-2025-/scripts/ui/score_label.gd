extends Label

@export var left_player: bool

func _ready():
	GameManager.score_changed.connect(update_label)

func update_label():
	if(left_player):
		text = str(GameManager.right_player_score)
	else:
		text = str(GameManager.left_player_score)
