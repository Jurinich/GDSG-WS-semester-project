@tool
extends Control

@export var horizontal: bool = false
@export var menu_radius: float = 300.0  # affects 3d effect and how far up/down the menu goes
@export var rotation_speed: float = 10  # how fast the menu should spin

@export_range(0.0, 1.0) var fade_modifier: float = 0.35   # how quickly elements fade
@export_range(0.0, 1.0) var scale_modifier: float = 0.20  # how quickly elements scale down

var selected_menu: int = 0
var buttons: Array[Button] = []
var alignment_position: float

var visual_selected_menu: float = selected_menu # used to smooth the animation
var target_selected_menu: float = selected_menu # used to smooth the animation

var focused: bool = false

func _ready() -> void:
	_populate_button_array()
	alignment_position = size.x / 2
	focus_entered.connect(_on_focused_changed.bind(true))
	focus_exited.connect(_on_focused_changed.bind(false))

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

		# fade_modifier is unusable atm
		# as soon as it is turned on the elements in the back are visible, need to do it with another formula?
		# exponential instead of linear
		var color_level = fade_modifier + (1 - fade_modifier) * depth_level
		var scale_level = depth_level

		var target_position = Vector2(center.x, center.y) - button.size / 2.0
		if horizontal:
			target_position.x += position_offset
		else:
			target_position.y += position_offset
		
		button.position = lerp(button.position, target_position, interpolation)

		var target_scale = lerp(1.0 - scale_modifier, 1.0, scale_level)
		button.scale = Vector2.ONE * target_scale

		button.modulate = (Color.WHITE if focused else Color.GRAY) * color_level
		if button.modulate.a > 0.1:
			button.modulate.a = 1.0

		button.z_index = round(depth_level)
		
	
# Fill container with children (can also do buttons = get_children() but I wanted static typing)
func _populate_button_array() -> void:
	for child in get_children():
		if child is Button:
			buttons.append(child)

func _gui_input(event: InputEvent) -> void:
	if _increase_event(event):
		target_selected_menu += 1.0
		selected_menu = posmod(roundi(target_selected_menu), buttons.size())
		return
	if _decrease_event(event):
		target_selected_menu -= 1.0
		selected_menu = posmod(roundi(target_selected_menu), buttons.size())
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

func _on_focused_changed(focus: bool) -> void:
	focused = focus;
