class_name BallSpawner
extends Timer

@export var ball_scene : PackedScene
@export var spawn_position: Vector2
@onready var player_1: CharacterBody2D = $"../Player1"

func _ready():
	add_to_group("ball_spawner")
	timeout.connect(spawn_ball)
	trigger_spawn()


func trigger_spawn():
	start()

func spawn_ball():
	var ball = ball_scene.instantiate()
	ball.global_position = spawn_position
	call_deferred("add_child", ball)
	print("spawned a new ball")

func split_ball(target_ball: Ball, split_amount: int):
	if not is_instance_valid(target_ball):
		return
		
	var fast_speed = max(target_ball.current_speed, target_ball.BASE_SPEED)
	var slow_speed = fast_speed * 0.5 
	var angle_step = (2 * PI) / split_amount 
	var random_offset = randf_range(0, 2 * PI) 
	var newly_split_balls = [] 
	var current_size = target_ball.sprite.scale.x
	
	for i in range(split_amount):
		var current_angle = random_offset + (i * angle_step)
		var new_direction = Vector2(cos(current_angle), sin(current_angle))
		var ball_to_modify: Ball
		
		if i == 0:
			ball_to_modify = target_ball
		else:
			ball_to_modify = ball_scene.instantiate()
			ball_to_modify.is_split_spawn = true 
			ball_to_modify.global_position = target_ball.global_position
			ball_to_modify.size_multiplier = current_size
			call_deferred("add_child", ball_to_modify)
			
		ball_to_modify.velocity = new_direction
		ball_to_modify.current_speed = slow_speed
		newly_split_balls.append(ball_to_modify)
		
	await get_tree().create_timer(0.5).timeout
	
	for ball in newly_split_balls:
		if is_instance_valid(ball):
			if ball.current_speed < fast_speed:
				ball.current_speed = fast_speed
