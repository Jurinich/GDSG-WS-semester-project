@tool
class_name CustomButton extends Control

signal pressed

@onready var label: Label = $HBoxContainer/Label
@onready var left_wrapper: Control = $HBoxContainer/Left/Control
@onready var right_wrapper: Control = $HBoxContainer/Right/Control
@onready var left_arrow: TextureRect = $HBoxContainer/Left/Control/Arrow
@onready var right_arrow: TextureRect = $HBoxContainer/Right/Control/Arrow

@export var font_size: int = 40:
	set(value):
		font_size = value
		if label != null:
			label.remove_theme_font_size_override("font_size")
			label.add_theme_font_size_override("font_size", font_size)

@export var text: String = "Text":
	set(value):
		text = value
		if label != null:
			label.text = value

@export var arrow_animation_speed: float = 0.005
@export var arrow_animation_distance: float = 3.0

var focused: bool = false

func _ready() -> void:
	label.remove_theme_font_size_override("font_size")
	label.add_theme_font_size_override("font_size", font_size)
	label.text = text
	left_wrapper.visible = focused
	right_wrapper.visible = focused
	var arrow_size = label.size.y * 0.8
	left_wrapper.custom_minimum_size = Vector2(arrow_size, arrow_size)
	right_wrapper.custom_minimum_size = Vector2(arrow_size, arrow_size)
	focus_entered.connect(_on_focused_changed.bind(true))
	focus_exited.connect(_on_focused_changed.bind(false))

func _process(_delta: float) -> void:
	var offset = sin(Time.get_ticks_msec() * arrow_animation_speed) * arrow_animation_distance
	left_arrow.position.x = offset
	right_arrow.position.x = -offset

func _gui_input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		pressed.emit()
		AudioManager.playSound(&"menu_select")

func _on_focused_changed(focus: bool) -> void:
	focused = focus
	left_wrapper.visible = focused
	right_wrapper.visible = focused
	AudioManager.playSound(&"menu_hover")
