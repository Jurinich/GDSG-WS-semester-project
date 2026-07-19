class_name PlayerSelectionNode
extends Control

@onready var label: Label = $"Label"
@onready var selection: TextureRect = $"Selection"

@export var player_name: String
@export var paddles: Array[Paddle]
@export var start_index: int = 0
@export var isP1: bool

var index: int

func _ready():
	label.text = player_name
	index = start_index
	update_texture()

func _on_right_button_pressed():
	index = posmod(index + 1, paddles.size());
	update_texture()

func _on_left_button_pressed():
	index = posmod(index - 1, paddles.size());
	update_texture()

func get_selection() -> Paddle:
	return paddles[index]

func update_texture():
	selection.texture = paddles[index].sprite
	if isP1:
		selection.flip_h = true;

func _unhandled_input(event):
	if GameManager.arcade_mode:
		if _check_input_arcade(event):
			AudioManager.playSound(&"menu_select");
			get_viewport().set_input_as_handled()
	else:
		if _check_input_desktop(event):
			AudioManager.playSound(&"menu_select");
			get_viewport().set_input_as_handled()

func _check_input_arcade(event: InputEvent) -> bool:
	if event.device not in [GameManager.arcade_p1_id, GameManager.arcade_p2_id]:
		return false
	
	if isP1:
		if event.device == GameManager.arcade_p2_id: return false
	else:
		if event.device == GameManager.arcade_p1_id: return false
	
	if event.is_action_pressed("ui_left"):
		_on_left_button_pressed()
		return true
	elif event.is_action_pressed("ui_right"):
		_on_right_button_pressed()
		return true
	return false

func _check_input_desktop(event: InputEvent) -> bool:
	if event.is_action_pressed("leftP1" if isP1 else "leftP2"):
		_on_left_button_pressed()
		return true
	elif event.is_action_pressed("rightP1" if isP1 else "rightP2"):
		_on_right_button_pressed()
		return true
	return false
