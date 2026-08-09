class_name CustomSlider extends Control

@onready var slider: Slider = $HBoxContainer/HSlider
@onready var left_wrapper: Control = $HBoxContainer/Left/Control
@onready var right_wrapper: Control = $HBoxContainer/Right/Control
@onready var left_arrow: TextureRect = $HBoxContainer/Left/Control/Arrow
@onready var right_arrow: TextureRect = $HBoxContainer/Right/Control/Arrow

@export var arrow_animation_speed: float = 0.005
@export var arrow_animation_distance: float = 3.0

var focused: bool = false

func _ready() -> void:
	left_wrapper.visible = focused
	right_wrapper.visible = focused
	var arrow_size = slider.size.y * 2.5
	left_wrapper.custom_minimum_size = Vector2(arrow_size, arrow_size)
	right_wrapper.custom_minimum_size = Vector2(arrow_size, arrow_size)
	focus_entered.connect(_on_focused_changed.bind(true))
	focus_exited.connect(_on_focused_changed.bind(false))

func _process(_delta: float) -> void:
	var offset = sin(Time.get_ticks_msec() * arrow_animation_speed) * arrow_animation_distance
	left_arrow.position.x = offset
	right_arrow.position.x = -offset

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left", true):
		slider.value = clamp(slider.value - slider.step, slider.min_value, slider.max_value)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right", true):
		slider.value = clamp(slider.value + slider.step, slider.min_value, slider.max_value)
		get_viewport().set_input_as_handled()

func _on_focused_changed(focus: bool) -> void:
	focused = focus
	left_wrapper.visible = focused
	right_wrapper.visible = focused
	AudioManager.playSound(&"menu_hover")
