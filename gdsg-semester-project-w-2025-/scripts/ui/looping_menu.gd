@tool
class_name LoopingMenu extends Control

signal button_pressed(button: String)

@export var horizontal: bool = false
@export var menu_radius: float = 300.0  # affects 3d effect and how far up/down the menu goes
@export var rotation_speed: float = 10  # how fast the menu should spin
@export var font_size: int = 40

@export_range(0.0, 1.0) var scale_modifier: float = 0.20  # how quickly elements scale down

@export var selected_menu: int = 0
@export var items: Array[String]:
	set(value):
		items = value
		if is_node_ready():
			_populate_button_array()

var buttons: Array[Button] = []

var visual_selected_menu: float = selected_menu # used to smooth the animation
var target_selected_menu: float = selected_menu # used to smooth the animation

var focused: bool = false

var largest_button: float = 0.0

func _ready() -> void:
	_populate_button_array()
	focus_entered.connect(_on_focused_changed.bind(true))
	focus_exited.connect(_on_focused_changed.bind(false))
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))

func _process(delta: float) -> void:
	var interpolation = clamp(rotation_speed * delta, 0.0, 1.0)

	visual_selected_menu = lerpf(visual_selected_menu, target_selected_menu, interpolation)

	var center = size / 2.0
	var count = buttons.size()

	var max_index_range = max(1.0, float(count - 1) / 2.0)

	for i in range(count):
		var button = buttons[i]

		# distance to selected button, needs to wrap around but also has to be from -n/2 to n/2
		# first I get the relative position to selected button but fposmod only returns positive values (from 0 to n)
		# so count / 2.0 needs to be subtracted (-n/2 to n/2)
		var offset = fposmod(i - visual_selected_menu + count / 2.0, count) - count / 2.0
		
		var angle = clamp(offset / max_index_range, -1.0, 1.0) * PI
		var position_offset = sin(angle) * menu_radius
		var depth = cos(angle)

		# depth gives (-1.0 to 1.0), need (0 to 1)
		var depth_level = (depth + 1.0) / 2.0
		
		if depth_level >= 0.9:
			button.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
		else:
			button.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

		var target_position = Vector2(center.x, center.y) - button.size / 2.0
		if horizontal:
			target_position.x += position_offset
		else:
			target_position.y += position_offset
		
		button.position = lerp(button.position, target_position, interpolation)

		var target_scale = lerp(1.0 - scale_modifier, 1.0, depth_level)
		button.scale = Vector2.ONE * target_scale

		button.modulate = (Color.WHITE if focused else Color.GRAY) * (depth_level * 0.6 + 0.4)
		button.modulate.a = 1.0 if depth_level > 0.1 else depth_level

		button.z_index = round(depth_level)

func _populate_button_array() -> void:
	for child in get_children():
		if child is Button:
			child.queue_free()
	buttons.clear()
	largest_button = 0.0
	for item in items:
		var button := Button.new()
		button.text = item
		button.add_theme_font_size_override("font_size", font_size)
		button.pivot_offset_ratio = Vector2(0.5, 0.5)
		add_child(button)
		buttons.append(button)
		var button_size : Vector2 = button.get_combined_minimum_size()
		largest_button = max(largest_button, button_size.x if horizontal else button_size.y)
	update_minimum_size()

func select(index: int, animate: bool = false) -> void:
	if animate:
		target_selected_menu += (index - selected_menu)
	else:
		target_selected_menu = index
		visual_selected_menu = index
	selected_menu = posmod(index, buttons.size())

func _gui_input(event: InputEvent) -> void:
	if _increase_event(event):
		select(selected_menu + 1, true)
		get_viewport().set_input_as_handled()
		return
	if _decrease_event(event):
		select(selected_menu - 1, true)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept"):
		buttons[selected_menu].pressed.emit()

func _increase_event(event: InputEvent) -> bool:
	if horizontal:
		return event.is_action_pressed("ui_right")
	return event.is_action_pressed("ui_down")

func _decrease_event(event: InputEvent) -> bool:
	if horizontal:
		return event.is_action_pressed("ui_left")
	return event.is_action_pressed("ui_up")

func _on_button_pressed(index: int):
	button_pressed.emit(items[index])

func _on_focused_changed(focus: bool) -> void:
	focused = focus;

func _get_minimum_size() -> Vector2:
	var largest := Vector2.ZERO
	for button in buttons:
		largest = largest.max(button.get_combined_minimum_size())
		
	if buttons.size() > 1:
		if horizontal:
			largest.x += menu_radius * 2.0
		else:
			largest.y += menu_radius * 2.0
	return largest
