extends BaseButton

func _ready():
	pressed.connect(_on_pressed);
	mouse_entered.connect(_on_hovered);


func _on_hovered():
	GlobalSounds.playSound("menu_hover");
	
func _on_pressed():
	GlobalSounds.playSound("menu_select");
