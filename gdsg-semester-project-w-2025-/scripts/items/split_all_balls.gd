extends Node

@export var split_amount: int = 0

func apply_effect(_player: CharacterBody2D, _triggering_ball: Ball = null):
	var spawner = get_tree().get_first_node_in_group("ball_spawner")
	
	if spawner and spawner.has_method("split_all_active_balls"):
		spawner.split_all_active_balls(split_amount)
