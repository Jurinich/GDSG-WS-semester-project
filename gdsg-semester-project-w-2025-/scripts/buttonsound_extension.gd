extends BaseButton

func _ready():
	pressed.connect(_on_hovered);
	mouse_entered.connect(_on_pressed);


func _on_hovered():
	GlobalSounds.playSound("click_sound");
	
func _on_pressed():
	GlobalSounds.playSound("hover_sound");
