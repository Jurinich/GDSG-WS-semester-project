@tool
class_name LoopingMenu extends Control

signal button_pressed(button: String)

var ARROW_TEXTURE: Texture = preload("res://assets/sprites/UI/arrow.png")

@export var modulate_factor: float = 0.5
@export var item_spacing: float = 60.0
@export var rotation_speed: float = 10.0
@export var font_size: int = 40

@export var arrow_padding: float = 10.0
@export var arrow_animation_speed: float = 0.005
@export var arrow_animation_distance: float = 8.0

@export_range(0.0, 1.0) var scale_modifier: float = 0.4

@export var selected_menu: int = 0
@export var items: Array[String]:
	set(value):
		items = value
		if is_node_ready():
			_populate_button_array()

var arrow_left: TextureRect
var arrow_right: TextureRect
var buttons: Array[Button] = []

var visual_selected_menu: float = selected_menu # used to smooth the animation
var target_selected_menu: float = selected_menu # used to smooth the animation

var focused: bool = false

var largest_button: float = 0.0

func _ready() -> void:
	_populate_button_array()
	focus_entered.connect(_on_focused_changed.bind(true))
	focus_exited.connect(_on_focused_changed.bind(false))

func _process(delta: float) -> void:
	_compute_positions(delta)

func _compute_positions(delta: float) -> void:
	var interpolation = clamp(rotation_speed * delta, 0.0, 1.0)

	visual_selected_menu = lerpf(visual_selected_menu, target_selected_menu, interpolation)

	var center = size / 2.0
	var count = buttons.size()

	for i in range(count):
		var button = buttons[i]

		var offset: float = fposmod(i - visual_selected_menu + count / 2.0, count) - count / 2.0
		var distance = abs(offset)
		
		var target_position = Vector2(center.x, center.y) - button.size / 2.0
		if distance < 1.5:
			target_position.y += offset * item_spacing
		button.position = lerp(button.position, target_position, interpolation)
		
		var target_scale = lerp(1.0, 1.0 - scale_modifier, distance)
		button.scale = button.scale.lerp(Vector2.ONE * target_scale, interpolation)
		
		var factor = (1.0 - distance) * modulate_factor + (1.0 - modulate_factor)
		var target_color = (Color.WHITE if focused else Color.GRAY) * factor
		button.modulate = button.modulate.lerp(target_color, interpolation)
		var alpha = clamp((distance - 1.0), 0.0, 1.0)
		button.modulate.a = lerp(1.0, 0.0, alpha)

		button.z_index = lerp(10, 0, distance * 0.5)
	_update_arrow(delta)

func _update_arrow(delta: float) -> void:
	if arrow_left == null || arrow_right == null:
		return
	
	arrow_left.visible = focused
	arrow_right.visible = focused
	if focused:
		var offset = sin(Time.get_ticks_msec() * arrow_animation_speed) * arrow_animation_distance
		var button = buttons[selected_menu]
		var animation_delta = rotation_speed * delta
		var center_x = size.x / 2
		var target_position = (button.size.x / 2) + arrow_padding + offset
		arrow_left.position.x = lerp(arrow_left.position.x, center_x - target_position, animation_delta)
		arrow_right.position.x = lerp(arrow_right.position.x, center_x + target_position, animation_delta)

func _populate_button_array() -> void:
	for child in get_children():
		child.queue_free()
	buttons.clear()
	largest_button = 0.0
	for i in items.size():
		var button := Button.new()
		button.text = items[i]
		button.add_theme_font_size_override("font_size", font_size)
		button.pivot_offset_ratio = Vector2(0.5, 0.5)
		button.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
		add_child(button)
		buttons.append(button)
		button.pressed.connect(_on_button_pressed.bind(i))
		var button_size : Vector2 = button.get_combined_minimum_size()
		largest_button = max(largest_button, button_size.y)
	update_minimum_size()
	
	arrow_left = _create_arrow()
	arrow_left.rotation = PI
	arrow_right = _create_arrow()
	
	_compute_positions(1.0)

func _create_arrow() -> TextureRect:
	var arrow = TextureRect.new()
	arrow.texture = ARROW_TEXTURE
	arrow.pivot_offset_ratio = Vector2(0.0, 0.5)
	arrow.scale = Vector2(0.4, 0.4)
	add_child(arrow)
	arrow.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	return arrow

func select(index: int, animate: bool = false) -> void:
	if items.is_empty():
		return
	
	if animate:
		target_selected_menu += (index - selected_menu)
	else:
		target_selected_menu = index
		visual_selected_menu = index
	selected_menu = posmod(index, buttons.size())

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		select(selected_menu + 1, true)
		AudioManager.playSound(&"menu_hover");
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_up"):
		select(selected_menu - 1, true)
		AudioManager.playSound(&"menu_hover");
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept"):
		if buttons[selected_menu].text == "Start Game":
			AudioManager.playSound(&"game_start")
		else:
			AudioManager.playSound(&"menu_select");
		buttons[selected_menu].pressed.emit()

func _on_button_pressed(index: int):
	button_pressed.emit(items[index])

func _on_focused_changed(focus: bool) -> void:
	focused = focus;

func _get_minimum_size() -> Vector2:
	var largest := Vector2.ZERO
	for button in buttons:
		largest = largest.max(button.get_combined_minimum_size())
		
	if buttons.size() > 1:
		largest.y += item_spacing * 2.0
	return largest
