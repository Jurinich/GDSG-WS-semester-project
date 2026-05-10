@tool
extends Control

@export var menu_radius: float = 300.0  # affects 3d effect and how far up/down the menu goes
@export var rotation_speed: float = 10  # how fast the menu should spin

@export_range(0.0, 1.0) var fade_modifier: float = 0.35   # how quickly elements fade
@export_range(0.0, 1.0) var scale_modifier: float = 0.20  # how quickly elements scale down

signal button_pressed(button: Button)

var selected_menu: int = 0
var buttons: Array[Button] = []
var alignment_position: float

var visual_selected_menu: float = selected_menu # used to smooth the animation
var target_selected_menu: float = selected_menu # used to smooth the animation

enum Direction {UP, DOWN}

func _ready() -> void:
	_populate_button_array()
	alignment_position = size.x / 2
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))

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
		var y = sin(angle) * menu_radius
		var depth = cos(angle)

		# depth gives (-1.0 to 1.0), need (0 to 1)
		var depth_level = (depth + 1.0) / 2.0

		# fade_modifier is unusable atm
		# as soon as it is turned on the elements in the back are visible, need to do it with another formula?
		# exponential instead of linear
		var color_level = fade_modifier + (1 - fade_modifier) * depth_level
		var scale_level = depth_level

		var target_position = Vector2(center.x, center.y + y) - button.size / 2.0
		button.position = lerp(button.position, target_position, interpolation)

		var target_scale = lerp(1.0 - scale_modifier, 1.0, scale_level)
		button.scale = Vector2.ONE * target_scale

		button.modulate = Color.WHITE * color_level

		button.z_index = int(depth_level)
		
	
# Fill container with children (can also do buttons = get_children() but I wanted static typing)
func _populate_button_array() -> void:
	for child in get_children():
		if child is Button:
			buttons.append(child)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("downP1") or event.is_action_pressed("downP2"):
		target_selected_menu += 1.0
		selected_menu = posmod(roundi(target_selected_menu), buttons.size())
		return
	if event.is_action_pressed("upP1") or event.is_action_pressed("upP2"):
		target_selected_menu -= 1.0
		selected_menu = posmod(roundi(target_selected_menu), buttons.size())
		return
	if event.is_action_pressed("Start"):
		buttons[selected_menu].pressed.emit()

func _on_button_pressed(button: Button):
	button_pressed.emit(button)
