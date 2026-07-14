class_name Ball
extends CharacterBody2D

@export var BASE_SPEED: float = 600.0
@export var SPEED_DECAY: float = 300.0
@export var VELOCITY_THRESHOLD: float = 50.0
@export var PADDLE_DIRECTION_INFLUENCE: float = 0.45
@export var PADDLE_SPEED_INFLUENCE: float = 0.0
@export var MIN_SCALE: float = 0.75
@export var MAX_SCALE: float = 1.5
@export var ROLL_SPEED: float = 0.01

var current_scale: float = 1.0
var current_speed: float
var last_hit_by: CharacterBody2D = player_1
var is_split_spawn: bool = false
var size_multiplier: float = 1.0
var tile_offset := Vector2.ZERO

@onready var sprite_material: ShaderMaterial = $Visuals/Ball.material
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@onready var player_1: CharacterBody2D = $"../Player1"

@onready var kitten_spawner: KittenSpawner = $"../KittenPawSpawner"

func _ready():
	current_speed = 150.0
	add_to_group("balls")
	last_hit_by = player_1
	print("Balls ", last_hit_by)
	if size_multiplier != 1.0:
		scale_ball(size_multiplier)
	if not is_split_spawn:
		launch_ball()

func _process(delta: float) -> void:
	tile_offset -= velocity * delta * ROLL_SPEED
	sprite_material.set_shader_parameter("tile_offset", tile_offset);
	sprite_material.set_shader_parameter("velocity", velocity);

func launch_ball():
	last_hit_by = player_1
	current_speed = BASE_SPEED
	var direction = [-1, 1].pick_random()
	velocity = Vector2(direction, randf_range(-0.5, 0.5)).normalized() * current_speed
	
func _physics_process(delta: float) -> void:
	if current_speed != BASE_SPEED:
		current_speed = move_toward(current_speed, BASE_SPEED, SPEED_DECAY * delta)
	velocity = velocity.normalized() * current_speed
	
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		#print("Ball hit:",collider, " at pos ", collider.global_position)
		if collider is CharacterBody2D or collider is StaticBody2D:
			if collider is StaticBody2D:
				GlobalSounds.playSound("border_hit");
			var normal := collision.get_normal()
			velocity = velocity.bounce(normal)
			if collider is CharacterBody2D:
				GlobalSounds.playSound("paddle_hit");
				last_hit_by = collider
				if collider.has_method("play_hit_animation"):
					collider.play_hit_animation()
				
				velocity.y += collider.velocity.y * PADDLE_DIRECTION_INFLUENCE
				current_speed += abs(collider.velocity.y) * PADDLE_SPEED_INFLUENCE
				
		if check_velocity_threshold():
			kitten_spawner.call_deferred("spawn_paw", self)

func check_velocity_threshold() -> bool:
	if velocity.x < VELOCITY_THRESHOLD && velocity.x > -VELOCITY_THRESHOLD:
		return true
	elif velocity.y < VELOCITY_THRESHOLD && velocity.y > -VELOCITY_THRESHOLD:
		return true
	return false


func paw_hit(new_direction: Vector2, boost_amount: float):
	velocity = new_direction.normalized()
	current_speed += boost_amount

func scale_ball(multiplier: float):
	var new_scale = clampf(current_scale * multiplier, MIN_SCALE, MAX_SCALE)
	var actual_multiplier = new_scale / current_scale
	scale *= actual_multiplier
	
	current_scale = new_scale
