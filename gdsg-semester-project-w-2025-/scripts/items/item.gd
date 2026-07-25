class_name Item extends CharacterBody2D

@onready var sprite : Sprite2D = $Item
@onready var shadow: Sprite2D = $Shadow
@onready var pickup_area: Area2D = $PickupArea

@export var animation_speed: float = 0.003
@export var animation_scale: float = 0.1
@export var roll_speed: float = 0.0045

@onready var back_material: ShaderMaterial = $CapsuleBack.material
@onready var front_material: ShaderMaterial = $CapsuleFront.material

@export var friction: float = 235.0

var offset: float = 0.0
var capsule_rotation: float = randf_range(0, PI / 2.0)
var item_data : ItemData

func _ready() -> void:
	pickup_area.body_entered.connect(_on_body_entered)
	sprite.texture = item_data.sprite

func shoot(initial_velocity: Vector2):
	velocity = initial_velocity

func _process(delta: float) -> void:
	var tangent = Vector2.RIGHT.rotated(capsule_rotation)
	var direction := velocity.normalized().dot(tangent)
	offset -= velocity.length() * direction * delta * roll_speed
	
	back_material.set_shader_parameter("offset", -offset)
	front_material.set_shader_parameter("offset", offset)
	back_material.set_shader_parameter("texture_rotation", capsule_rotation)
	front_material.set_shader_parameter("texture_rotation", capsule_rotation)
	var scale_modifier = sin(Time.get_ticks_msec() * animation_speed) * animation_scale
	sprite.scale = Vector2.ONE * (1 + scale_modifier)

func _physics_process(delta: float) -> void:
	if velocity.length() > 0:
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			var collider = collision.get_collider()
			if collider is Item:
				collider.velocity -= collision.get_normal() * (velocity.length() * 0.5)
			
			velocity = velocity.bounce(collision.get_normal()) * 0.9
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _on_body_entered(_body: Node2D) -> void:
	pass
