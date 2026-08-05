class_name ItemCapsule extends Node2D

@onready var sprite : Sprite2D = $Item

@export var animation_speed: float = 0.003
@export var animation_scale: float = 0.1

@onready var back_material: ShaderMaterial = $CapsuleBack.material
@onready var front_material: ShaderMaterial = $CapsuleFront.material

func set_sprite(item_data: ItemData) -> void:
	sprite.texture = item_data.sprite

func set_capsule_rotation(capsule_rotation: float):
	back_material.set_shader_parameter("texture_rotation", capsule_rotation)
	front_material.set_shader_parameter("texture_rotation", capsule_rotation)

func set_capsule_offset(offset: float):
	back_material.set_shader_parameter("offset", -offset)
	front_material.set_shader_parameter("offset", offset)

func _process(_delta: float) -> void:
	var scale_modifier = sin(Time.get_ticks_msec() * animation_speed) * animation_scale
	sprite.scale = Vector2.ONE * (1 + scale_modifier)
