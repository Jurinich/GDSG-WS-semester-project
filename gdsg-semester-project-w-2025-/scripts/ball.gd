class_name Ball
extends CharacterBody2D

@export var BASE_SPEED: float = 600.0
@export var SPEED_DECAY: float = 300.0

var current_speed: float
var last_hit_by: CharacterBody2D = player_1
var is_split_spawn: bool = false
var size_multiplier: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var border_sound: AudioStreamPlayer = $"../../border sound"
@onready var fish_paddle_sound: AudioStreamPlayer = $"../../fish paddle sound"

@onready var player_1: CharacterBody2D = $"../../Player1"



func _ready():
	current_speed = BASE_SPEED
	collision_shape.shape = collision_shape.shape.duplicate()
	add_to_group("balls")
	last_hit_by = player_1
	print("Balls ", last_hit_by)
	if size_multiplier != 1.0:
		scale_ball(size_multiplier)
	if not is_split_spawn:
		launch_ball()

func launch_ball():
	last_hit_by = null
	current_speed = BASE_SPEED
	var direction = [-1, 1].pick_random()
	velocity = Vector2(direction, randf_range(-0.5, 0.5)).normalized() * current_speed
	
func _physics_process(delta: float) -> void:
	if current_speed > BASE_SPEED:
		current_speed = move_toward(current_speed, BASE_SPEED, SPEED_DECAY * delta)
	velocity = velocity.normalized() * current_speed
	
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		#print("Ball hit:",collider, " at pos ", collider.global_position)
		if collider is CharacterBody2D or collider is StaticBody2D:
			if collider is StaticBody2D:
				border_sound.play()
			var normal := collision.get_normal()
			velocity = velocity.bounce(normal)
			if collider is CharacterBody2D:
				fish_paddle_sound.play()
				last_hit_by = collider
				#print("Last hit:",collider)
				velocity.y += collider.velocity.y * 0.5  
			velocity = velocity.normalized() * BASE_SPEED

func paw_hit(new_direction: Vector2, boost_amount: float):
	velocity = new_direction.normalized()
	current_speed += boost_amount
	
func scale_ball(multiplier: float):
	sprite.scale *= multiplier
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius *= multiplier
