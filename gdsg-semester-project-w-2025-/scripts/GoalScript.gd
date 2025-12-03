extends Area2D

@export var player : String

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("Goal hit by:", body, " at pos ", body.global_position)
	if body.name == "Ball":
		GameManager.add_point(player)
		body.queue_free()
