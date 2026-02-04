class_name PlayerSelectionNode
extends Control

@onready var label: Label = $"Label"
@onready var selection: TextureRect = $"Selection"

@export var player_name: String
@export var possible_textures: Array[Texture2D]
@export var start_index: int = 0

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
