class_name BallSpawner
extends Node2D

@export var ball_scene : PackedScene
@export var spawn_position: Vector2
@export var spawn_delay := 1.0


func _ready():
	spawn_ball()
	
func spawn_ball(old_ball = null):
	if (old_ball != null):
		old_ball.queue_free()

	var ball = ball_scene.instantiate()

	await get_tree().create_timer(spawn_delay).timeout

	add_child(ball)
	ball.global_position = spawn_position

	print("spawned a ball")
