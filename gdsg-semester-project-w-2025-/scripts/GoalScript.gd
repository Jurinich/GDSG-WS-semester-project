extends Area2D

@export var player : String

@onready var ball_spawner: BallSpawner = $"../../BallSpawnTimer"
@onready var goal_sound: AudioStreamPlayer = $"../../Goal Sound"

signal goal_scored()

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is Ball:
		print("Goal hit by:", body, " at pos ", body.global_position)
		goal_sound.play()
		body.remove_from_group("balls")
		var balls_in_play = get_tree().get_nodes_in_group("balls").size()
		body.queue_free()
		if GameManager.add_point(player) and balls_in_play < 1:
			ball_spawner.trigger_spawn()
		goal_scored.emit()
