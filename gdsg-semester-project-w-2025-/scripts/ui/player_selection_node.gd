class_name PlayerSelectionNode
extends Control

@onready var label: Label = $"Label"
@onready var selection: TextureRect = $"Selection"

@export var player_name: String
@export var possible_textures: Array[Texture2D]
@export var start_index: int = 0
@export var isP1: bool

var cur_index: int

func _ready():
	label.text = player_name
	cur_index = start_index

	update_texture()


func _on_right_button_pressed():
	cur_index = cur_index + 1
	if (cur_index > possible_textures.size() - 1):
		cur_index = 0

	update_texture()


func _on_left_button_pressed():
	cur_index = cur_index - 1
	if (cur_index < 0):
		cur_index = possible_textures.size() - 1

	update_texture()


func update_texture():
	selection.texture = possible_textures[cur_index]
	if isP1:
		selection.flip_h = true;

func _unhandled_input(event):
	if GameManager.arcade_mode:
		_check_input_arcade(event)
	else:
		_check_input_desktop(event)

func _check_input_arcade(event: InputEvent) -> void:
	if event.device not in [GameManager.arcade_p1_id, GameManager.arcade_p2_id]:
		return

	if isP1:
		if event.device == GameManager.arcade_p2_id: return
	else:
		if event.device == GameManager.arcade_p1_id: return

	if event.is_action_pressed("ui_left"):
		_on_left_button_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_on_right_button_pressed()
		get_viewport().set_input_as_handled()
	

func _check_input_desktop(event: InputEvent) -> void:
	if event.is_action_pressed("leftP1" if isP1 else "leftP2"):
		_on_left_button_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rightP1" if isP1 else "rightP2"):
		_on_right_button_pressed()
		get_viewport().set_input_as_handled()
