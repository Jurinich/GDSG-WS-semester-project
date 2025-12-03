extends CharacterBody2D

@export var SPEED: float = 600.0

func _ready():
	launch_ball()

func launch_ball():
	var direction = [-1, 1].pick_random()
	velocity = Vector2(direction, randf_range(-0.5, 0.5)).normalized() * SPEED
	
func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		#print("Ball hit:",collider, " at pos ", collider.global_position)
		if collider is CharacterBody2D or collider is StaticBody2D:
			var normal := collision.get_normal()
			velocity = velocity.bounce(normal)
			if collider is CharacterBody2D:
				velocity.y += collider.velocity.y * 0.5  
			velocity = velocity.normalized() * SPEED
