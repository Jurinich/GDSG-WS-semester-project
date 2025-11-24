extends CharacterBody2D

const SPEED := 500
@export var isP1: bool = false

func getYdir() -> float:
	if isP1:
		return Input.get_action_strength("downP1") - Input.get_action_strength("upP1")
	else:
		return Input.get_action_strength("downP2") - Input.get_action_strength("upP2")

func _physics_process(delta: float) -> void:
	var dir:Vector2=Vector2(0, getYdir())
	velocity = dir * SPEED
	move_and_slide()
