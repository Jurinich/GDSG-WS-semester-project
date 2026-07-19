extends BaseButton

func _ready():
	pressed.connect(GlobalSounds.get_node("click-sound").play)
	mouse_entered.connect(GlobalSounds.get_node("hover-sound").play)
