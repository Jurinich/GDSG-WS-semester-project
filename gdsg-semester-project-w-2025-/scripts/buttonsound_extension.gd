extends BaseButton

@export var hover_sound: StringName = "menu_hover"
@export var select_sound: StringName = "menu_select"

func _ready():
	pressed.connect(_on_pressed);
	mouse_entered.connect(_on_hovered);


func _on_hovered():
	AudioManager.playSound(hover_sound);
	
func _on_pressed():
	AudioManager.playSound(select_sound);
