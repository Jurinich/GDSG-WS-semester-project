extends Node

func apply_effect(player: CharacterBody2D):
	print(player.name, " used the Bigger Balls")
	get_tree().call_group("balls", "scale_ball", 1.5)
