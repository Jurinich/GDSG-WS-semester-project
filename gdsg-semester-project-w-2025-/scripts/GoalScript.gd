extends Area2D

@export var player : String

@onready var ball_spawner: BallSpawner = $"../../BallSpawner"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("Goal hit by:", body, " at pos ", body.global_position)
	if body.name == "Ball":
		GameManager.add_point(player)
		ball_spawner.spawn_ball(body)
