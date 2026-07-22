extends Node

@export var speed: float = 1400
@export var duration: float = 10.0

func apply_effect(player: CharacterBody2D, _triggering_ball: Ball = null):
	print(player.name, " used Speed UP Powerup: ")
	
	if player.has_method("change_speed"):
		player.change_speed(speed, duration)
