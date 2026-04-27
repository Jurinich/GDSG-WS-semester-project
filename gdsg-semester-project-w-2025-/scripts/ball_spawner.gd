class_name BallSpawner
extends Timer

@export var ball_scene : PackedScene
@export var spawn_position: Vector2
@export var split_all_balls: bool = false
@onready var player_1: CharacterBody2D = $"../Player1"

func _ready():
	add_to_group("ball_spawner")
	timeout.connect(spawn_ball)
	trigger_spawn()


func trigger_spawn():
	start()

func spawn_ball():
	if GameManager.can_spawn_more():
		var ball = ball_scene.instantiate()
		ball.global_position = spawn_position
		get_parent().add_child.call_deferred(ball) 
	else:
		print("Spawn blocked: Ball limit reached.")

func split_ball(target_ball: Ball, split_amount: int):
	if not is_instance_valid(target_ball):
		return
		
	var angle_step = (2 * PI) / split_amount 
	var random_offset = randf_range(0, 2 * PI) 
	var current_size = target_ball.sprite.scale.x
	
	var starting_slow_speed = 150.0
	
	var current_count = get_tree().get_nodes_in_group("balls").size()
	
	for i in range(split_amount):
		var ball_to_modify: Ball
		
		if i == 0:
			ball_to_modify = target_ball
		else:
			if current_count < GameManager.ball_limit:
				ball_to_modify = ball_scene.instantiate()
				ball_to_modify.is_split_spawn = true 
				ball_to_modify.global_position = target_ball.global_position
				ball_to_modify.size_multiplier = current_size
				
				get_parent().add_child(ball_to_modify) 
				current_count += 1
			else:
				break 

		var current_angle = random_offset + (i * angle_step)
		var direction = Vector2(cos(current_angle), sin(current_angle))
		
		ball_to_modify.velocity = Vector2(cos(current_angle), sin(current_angle))
		ball_to_modify.current_speed = starting_slow_speed 
		

func apply_speed_boost_deferred(ball: Ball, target_speed: float):
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(ball):
		ball.current_speed = target_speed
