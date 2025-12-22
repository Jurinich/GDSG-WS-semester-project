extends Label

func _ready():
	GameManager.score_changed.connect(update_label)

func update_label():
	text = GameManager.get_score_formatted()
