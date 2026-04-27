extends Node

func apply_effect(player: CharacterBody2D, triggering_ball: Ball = null):
	print(player.name, " used the Smaller Balls")
	get_tree().call_group("balls", "scale_ball", 0.66)
