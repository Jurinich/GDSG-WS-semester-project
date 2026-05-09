extends Control

@export var BUTTON_DISPLAY_MAX = 5
@export var SCALE_STEP = 0.25

signal button_pressed(button: Button)

var selected_menu: int = 0
var buttons: Array[Button] = []
var alignment_position: float

enum Direction {UP, DOWN}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_populate_button_array()
	alignment_position = size.x / 2
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	_draw_buttons(selected_menu)

# Fill container with children (can also do buttons = get_children() but I wanted static typing)
func _populate_button_array() -> void:
	for child in get_children():
		if child is Button:
			buttons.append(child)
	
func _hide_buttons() -> void:
	for button in buttons:
		button.hide()
		button.scale = Vector2.ONE
		button.modulate.a = 1
		button.position = Vector2.ZERO
		button.reset_size()
	
# Show a maximum of 5 buttons at once, middle one is the selected one
# @param index is used to draw the buttons relative to the currently selected one
func _draw_buttons(index: int) -> void:
	_hide_buttons()

	var vertical_offset = 0.0
	var middle = BUTTON_DISPLAY_MAX / 2

	for i in range(BUTTON_DISPLAY_MAX):
		var offset = i - middle
		var relative_index = wrapi(index + offset, 0, buttons.size())
		var current_button = buttons[relative_index]

		var distance = abs(offset)
		var modifier = 1.0 - SCALE_STEP * distance

		current_button.scale = Vector2.ONE * modifier
		current_button.modulate.a = modifier

		var scaled_size = current_button.size * modifier
		var horizontal_offset = alignment_position - scaled_size.x / 2
		current_button.position = Vector2(horizontal_offset, vertical_offset)
		vertical_offset += scaled_size.y

		current_button.show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("downP1") or event.is_action_pressed("downP2"):
		rotate_buttons(Direction.DOWN)
		return
	if event.is_action_pressed("upP1") or event.is_action_pressed("upP2"):
		rotate_buttons(Direction.UP)
		return
	if event.is_action_pressed("Start"):
		buttons[selected_menu].pressed.emit()

func _on_button_pressed(button: Button):
	button_pressed.emit(button)
		
# If we want to make this fancier we can make a
# real rotation animation
func rotate_buttons(direction: Direction):
	if direction == Direction.UP:
		selected_menu = wrapi(selected_menu - 1, 0, buttons.size())
		_draw_buttons(selected_menu)
		return
	
	selected_menu = wrapi(selected_menu + 1, 0, buttons.size())
	_draw_buttons(selected_menu)
