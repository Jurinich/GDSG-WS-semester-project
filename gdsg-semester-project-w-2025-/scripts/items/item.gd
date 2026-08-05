class_name Item extends CharacterBody2D

@onready var capsule: ItemCapsule = $Item
@onready var pickup_area: Area2D = $PickupArea

@export var roll_speed: float = 0.0045
@export var friction: float = 235.0

var offset: float = 0.0
var capsule_rotation: float = randf_range(0, PI / 2.0)
var item_data: ItemData
var layers: int

func _ready() -> void:
	layers = collision_layer
	collision_layer = 0
	capsule.set_sprite(item_data)

func shoot(initial_velocity: Vector2):
	velocity = initial_velocity

func _process(delta: float) -> void:
	var tangent = Vector2.RIGHT.rotated(capsule_rotation)
	var direction := velocity.normalized().dot(tangent)
	offset -= velocity.length() * direction * delta * roll_speed
	capsule.set_capsule_offset(offset)
	capsule.set_capsule_rotation(capsule_rotation)

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

func enable() -> void:
	collision_layer = layers
	pickup_area.body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	pass
