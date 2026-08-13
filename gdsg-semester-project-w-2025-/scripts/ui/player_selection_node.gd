class_name PlayerSelectionNode
extends Control

@onready var label: Label = $Container/Label
@onready var selection: TextureRect = $Container/Selection
@onready var fish_name: Label = $Container/Name/Name

@onready var device_icon: AtlasTexture = $Container/Device.texture
@onready var input_icon_move: AtlasTexture = $Container/Move/Buttons.texture
@onready var input_icon_accept: AtlasTexture = $Container/Accept/Buttons.texture
@onready var input_icon_back: AtlasTexture = $Container/Back/Buttons.texture

@onready var left_arrow: TextureRect = $Container/Name/Left/Arrow
@onready var right_arrow: TextureRect = $Container/Name/Right/Arrow

@export var player_name: String
@export var paddles: Array[Paddle]
@export var start_index: int = 0
@export var isP1: bool

@export var arrow_animation_speed: float = 0.005
@export var arrow_animation_distance: float = 8.0

@export var HIT_ANIMATION_DURATION = 0.1
@export var HIT_ANIMATION_SCALE = 0.1
@export var HIT_ANIMATION_ROTATION = 0.1

var tween_scale: Tween
var tween_rotation: Tween

var skin_start_rotation: float
var skin_start_scale: Vector2

var index: int

func _ready():
	label.text = player_name
	index = start_index
	skin_start_rotation = selection.offset_transform_rotation
	skin_start_scale = selection.offset_transform_scale
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
		selection.flip_v = true
	_play_select_animation()

func _update_device_icon(p1_device: int, p2_device: int) -> void:
	if isP1:
		device_icon.region.position.y = _get_device_icon_offset(p1_device, p2_device)
	else:
		device_icon.region.position.y = _get_device_icon_offset(p2_device, p1_device)
	var input_icons_offet = _get_input_icons_offset(p1_device if isP1 else p2_device)
	input_icon_move.region.position.x = input_icons_offet
	input_icon_accept.region.position.x = input_icons_offet
	input_icon_back.region.position.x = input_icons_offet

func _get_device_icon_offset(device: int, other_device: int) -> int:
	if device == InputEvent.DEVICE_ID_KEYBOARD:
		return 0
	elif other_device == InputEvent.DEVICE_ID_KEYBOARD || device < other_device:
		return 128
	else:
		return 256

func _get_input_icons_offset(device: int) -> int:
	if device == InputEvent.DEVICE_ID_KEYBOARD:
		return 0 if isP1 else 360
	else:
		return 720

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

func _play_select_animation():
	tween_scale = create_tween()
	var offset = Vector2(HIT_ANIMATION_SCALE, -HIT_ANIMATION_SCALE)
	tween_scale.tween_property(selection, "offset_transform_scale", skin_start_scale + offset, HIT_ANIMATION_DURATION / 2)
	offset /= -2
	tween_scale.tween_property(selection, "offset_transform_scale", skin_start_scale + offset, HIT_ANIMATION_DURATION)
	tween_scale.tween_property(selection, "offset_transform_scale", skin_start_scale, HIT_ANIMATION_DURATION)
	
	tween_rotation = create_tween()
	tween_rotation.tween_property(selection, "offset_transform_rotation", skin_start_rotation - HIT_ANIMATION_ROTATION, HIT_ANIMATION_DURATION / 2)
	tween_rotation.tween_property(selection, "offset_transform_rotation", skin_start_rotation + HIT_ANIMATION_ROTATION, HIT_ANIMATION_DURATION)
	tween_rotation.tween_property(selection, "offset_transform_rotation", skin_start_rotation, HIT_ANIMATION_DURATION)
