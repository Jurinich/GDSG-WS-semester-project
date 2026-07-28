extends Area2D

var caught_balls: Array[Ball] = []
var is_shooting: bool = false
var paddle_owner: CharacterBody2D
var shoot_direction: Vector2 = Vector2.RIGHT

var collection_timer: Timer
var shoot_timer: Timer

@export var catch_time : float = 5.0
@export var shoot_delay : float = 0.25
@export var shoot_angle : float = 10.0
func _ready():
	if paddle_owner and not paddle_owner.isP1:
		shoot_direction = Vector2.LEFT

	collection_timer = Timer.new()
	collection_timer.wait_time = catch_time
	collection_timer.one_shot = true
	collection_timer.timeout.connect(_on_collection_timeout)
	add_child(collection_timer)
	collection_timer.start()

	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(_on_shoot_tick)
	add_child(shoot_timer)

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if is_shooting: return 
	
	if body is Ball:
		catch_ball(body)

func catch_ball(ball: Ball):
	caught_balls.append(ball)
	ball.set_physics_process(false)
	ball.visible = false
	ball.collision_shape.set_deferred("disabled", true)
	ball.velocity = Vector2.ZERO
	if caught_balls.size() == get_tree().get_node_count_in_group("balls"):
		var remaining_time = min(collection_timer.time_left, 0.5)
		collection_timer.stop()
		collection_timer.start(remaining_time)

func _on_collection_timeout():
	is_shooting = true
	if caught_balls.is_empty():
		queue_free()
	else:
		shoot_timer.start()

func _on_shoot_tick():
	if caught_balls.is_empty():
		shoot_timer.stop()
		queue_free()
		return
		
	var ball = caught_balls.pop_front()
	shoot_ball(ball)

func shoot_ball(ball: Ball):
	ball.visible = true
	ball.collision_shape.set_deferred("disabled", false)
	ball.set_physics_process(true)
	
	ball.global_position = global_position 
	
	var spread_rad = deg_to_rad(randf_range(-shoot_angle, shoot_angle))
	var final_dir = shoot_direction.rotated(spread_rad)
	
	ball.velocity = final_dir * ball.BASE_SPEED
	ball.current_speed = ball.BASE_SPEED
	ball.last_hit_by = paddle_owner
