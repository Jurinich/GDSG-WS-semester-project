@tool
class_name LoopingSelection extends Control

signal value_changed(value: Variant)

@onready var label: Label = $HBoxContainer/Label
@onready var left_button: TextureRect = $HBoxContainer/Left/Arrow
@onready var right_button: TextureRect = $HBoxContainer/Right/Arrow

@export var font_size: int = 40:
	set(value):
		font_size = value
		if label != null:
			label.remove_theme_font_size_override("font_size")
			label.add_theme_font_size_override("font_size", font_size)

@export var selected_item: int = 0:
	set(value):
		if items.is_empty():
			return
		var index = posmod(value, items.size())
		selected_item = index
		if label != null:
			label.text = items[index].text

@export var items: Array[LoopingSelectionItem]
@export var hold_delay: float = 0.4
@export var hold_repeat: float = 0.08

var hold_timer: float = 0.0
var held_direction: int = 0

var focused: bool = false

func _ready() -> void:
	label.remove_theme_font_size_override("font_size")
	label.add_theme_font_size_override("font_size", font_size)
	left_button.visible = focused
	right_button.visible = focused
	var arrow_size = label.size.y * 0.8
	left_button.custom_minimum_size = Vector2(arrow_size, arrow_size)
	right_button.custom_minimum_size = Vector2(arrow_size, arrow_size)
	focus_entered.connect(_on_focused_changed.bind(true))
	focus_exited.connect(_on_focused_changed.bind(false))

func select(index: int) -> void:
	if items.is_empty():
		return
	selected_item = index
	value_changed.emit(items[selected_item].value)

func select_value(value: Variant) -> void:
	for i in range(items.size()):
		if items[i].value == value:
			select(i)
			return
	select(0)

func _on_button_input(change: int) -> void:
	select(selected_item + change)

func _gui_input(event: InputEvent) -> void:
	var direction: int = 0
	
	if event.is_action("ui_right"):
		direction = 1
	elif event.is_action("ui_left"):
		direction = -1
	
	if direction == 0 || event.is_released():
		held_direction = 0
		return
	
	get_viewport().set_input_as_handled()
	if held_direction != direction:
		hold_timer = hold_delay
		held_direction = direction
	else:
		hold_timer -= get_process_delta_time()
		if hold_timer > 0.0:
			return
	
	hold_timer = hold_repeat
	select(selected_item + direction)
	AudioManager.playSound(&"menu_hover")

func _on_focused_changed(focus: bool) -> void:
	focused = focus
	left_button.visible = focused
	right_button.visible = focused
	AudioManager.playSound(&"menu_hover")
