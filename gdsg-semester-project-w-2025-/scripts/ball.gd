class_name Ball
extends CharacterBody2D

@export var BASE_SPEED: float = 600.0
@export var SPEED_DECAY: float = 300.0

var current_speed: float
var last_hit_by: CharacterBody2D = null

func _ready():
	current_speed = BASE_SPEED
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
			var normal := collision.get_normal()
			velocity = velocity.bounce(normal)
			if collider is CharacterBody2D:
				last_hit_by = collider
				#print("Last hit:",collider)
				velocity.y += collider.velocity.y * 0.5  
			velocity = velocity.normalized() * BASE_SPEED

func paw_hit(new_direction: Vector2, boost_amount: float):
	velocity = new_direction.normalized()
	current_speed += boost_amount
