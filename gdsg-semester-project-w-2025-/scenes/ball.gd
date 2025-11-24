extends CharacterBody2D

const SPEED := 600.0

func _ready() -> void:
	velocity = Vector2(-SPEED, 0)
	
	
func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var normal := collision.get_normal()
		velocity = velocity.bounce(normal)
		
		if collision.get_collider() is CharacterBody2D:
			var paddle := collision.get_collider()
			var paddle_vel : float = paddle.velocity.y
			velocity.y += paddle_vel * 0.5  
			velocity = velocity.normalized() * SPEED
