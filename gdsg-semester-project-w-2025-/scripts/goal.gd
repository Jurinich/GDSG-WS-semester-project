extends Area2D

signal goal_scored(p1: bool)

@export var isP1: bool

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Ball:
		AudioManager.playSound("goal")
		body.remove_from_group("balls")
		body.queue_free()
		goal_scored.emit(!isP1)
	elif body is Item:
		body.queue_free()
