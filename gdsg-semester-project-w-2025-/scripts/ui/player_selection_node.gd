class_name PlayerSelectionNode
extends Control

@onready var label: Label = $Label
@onready var selection: TextureRect = $Selection
@onready var fish_name: Label = $Container/Name
@onready var device_icon: AtlasTexture = $Device.texture

@onready var left_arrow: TextureRect = $Container/Left/Arrow
@onready var right_arrow: TextureRect = $Container/Right/Arrow

@export var player_name: String
@export var paddles: Array[Paddle]
@export var start_index: int = 0
@export var isP1: bool

@export var arrow_animation_speed: float = 0.005
@export var arrow_animation_distance: float = 8.0

var index: int

func _ready():
	label.text = player_name
	index = start_index
	update_texture()
	ControllerInput.devices_updated.connect(_update_device_icon)
	_update_device_icon(ControllerInput.p1_device, ControllerInput.p2_device)

func _process(_delta: float) -> void:
	var offset = sin(Time.get_ticks_msec() * arrow_animation_speed) * arrow_animation_distance
	left_arrow.position.x = -offset
	right_arrow.position.x = offset

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
	fish_name.text = paddles[index].name
	if isP1:
		selection.flip_h = true;

func _update_device_icon(p1_device: int, p2_device: int) -> void:
	if isP1:
		device_icon.region.position.y = _get_device_icon_offset(p1_device, p2_device)
	else:
		device_icon.region.position.y = _get_device_icon_offset(p2_device, p1_device)

func _get_device_icon_offset(device: int, other_device: int) -> int:
	if device == InputEvent.DEVICE_ID_KEYBOARD:
		return 0
	elif other_device == InputEvent.DEVICE_ID_KEYBOARD || device < other_device:
		return 128
	else:
		return 256

func _unhandled_input(event):
	if _check_input_desktop(event):
		AudioManager.playSound(&"skin_select");
		get_viewport().set_input_as_handled()

func _check_input_desktop(event: InputEvent) -> bool:
	if event.is_action_pressed("leftP1" if isP1 else "leftP2"):
		_on_left_button_pressed()
		return true
	elif event.is_action_pressed("rightP1" if isP1 else "rightP2"):
		_on_right_button_pressed()
		return true
	return false
