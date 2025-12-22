extends Label

func _ready():
	GameManager.score_changed.connect(update_label)

func update_label():
	text = str(GameManager.left_player_score) + ":" + str(GameManager.right_player_score)
