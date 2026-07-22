extends Node

@export var size: float = 0.7
@export var duration: float = 10.0

func apply_effect(player: CharacterBody2D, _triggering_ball: Ball = null):
	print(player.name, " used size UP Powerup: ")
	
	if player.has_method("scale_paddle"):
		player.scale_paddle(size, duration)
