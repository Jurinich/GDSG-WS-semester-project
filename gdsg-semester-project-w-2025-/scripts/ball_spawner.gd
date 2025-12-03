extends Node2D

@export var ball_scene : PackedScene
@export var spawn_position: Vector2
@export var spawn_delay := 1.0


func _ready():
	spawn_ball()
	
func spawn_ball():
	var ball = ball_scene.instantiate()
	add_child(ball)
	ball.global_position = spawn_position
	ball.tree_exited.connect(on_ball_removed)
	print("spawned a ball")
	
func on_ball_removed():
	await get_tree().create_timer(spawn_delay).timeout
	spawn_ball()
