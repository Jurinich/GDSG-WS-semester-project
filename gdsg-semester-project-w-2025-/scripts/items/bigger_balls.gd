extends Node

func apply_effect(_player: CharacterBody2D, _triggering_ball: Ball = null):
	get_tree().call_group("balls", "scale_ball", 1.25)
