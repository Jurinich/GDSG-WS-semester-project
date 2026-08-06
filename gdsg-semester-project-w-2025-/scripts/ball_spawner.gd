class_name BallSpawner
extends Timer

@export var ball_scene : PackedScene
@export var spawn_position: Vector2
@export var split_all_balls: bool = false
@export var spawn_interval: float = 8.0 # Change how often a ball spawns here!

@onready var player_1: CharacterBody2D = $"../Player1"

func _ready():
	add_to_group("ball_spawner")
	
	wait_time = spawn_interval
	one_shot = false
	timeout.connect(spawn_ball)

func activate_spawner() -> void:
	spawn_ball()
	start()

func spawn_ball():
	if GameManager.can_spawn_more():
		var ball = ball_scene.instantiate()
		ball.global_position = spawn_position
		get_parent().add_child.call_deferred(ball)
	else:
		print("Spawn blocked: Ball limit reached.")

func split_single_ball(target_ball: Ball, split_amount: int):
	if not is_instance_valid(target_ball):
		return
		
	var angle_step = (2 * PI) / split_amount 
	var random_offset = randf_range(0, 2 * PI) 
	var current_size = target_ball.scale.x
	var starting_slow_speed = 150.0
	
	var current_count = get_tree().get_nodes_in_group("balls").size()
	var spawnable = min(split_amount - 1, GameManager.ball_limit - current_count)

	for i in range(spawnable + 1):
		var ball_to_modify: Ball
		
		if i == 0:
			ball_to_modify = target_ball
		else:
			ball_to_modify = ball_scene.instantiate()
			ball_to_modify.is_split_spawn = true 
			ball_to_modify.global_position = target_ball.global_position
			ball_to_modify.size_multiplier = current_size
			
			get_parent().add_child.call_deferred(ball_to_modify)
				
		var current_angle = random_offset + (i * angle_step)
		ball_to_modify.velocity = Vector2(cos(current_angle), sin(current_angle))
		ball_to_modify.current_speed = starting_slow_speed 

func split_all_active_balls(split_amount: int):
	var active_balls = get_tree().get_nodes_in_group("balls")
	for ball in active_balls:
		split_single_ball(ball, split_amount)

func apply_speed_boost_deferred(ball: Ball, target_speed: float):
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(ball):
		ball.current_speed = target_speed
