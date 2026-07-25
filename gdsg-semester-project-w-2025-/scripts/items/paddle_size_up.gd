extends Node

@export var size: float = 1.3
@export var duration: float = 10.0

func apply_effect(player: CharacterBody2D, _triggering_ball: Ball = null):
	if player.has_method("scale_paddle"):
		player.scale_paddle(size, duration)
