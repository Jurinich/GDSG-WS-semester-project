class_name BallSpawner
extends Timer

@export var ball_scene : PackedScene
@export var spawn_position: Vector2


func _ready():
	timeout.connect(spawn_ball)
	trigger_spawn()


func trigger_spawn(old_ball = null):
	if (old_ball != null):
		old_ball.call_deferred("queue_free")

	start()


func spawn_ball():
	var ball = ball_scene.instantiate()
	ball.global_position = spawn_position
	add_child(ball)

	print("spawned a ball")
