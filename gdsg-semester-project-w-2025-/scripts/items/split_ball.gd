extends Node

@export var split_amount: int = 3 

func apply_effect(_player: CharacterBody2D, triggering_ball: Ball = null):
	if triggering_ball == null:
		return
		
	var spawner = get_tree().get_first_node_in_group("ball_spawner")
	if spawner and spawner.has_method("split_single_ball"):
		spawner.split_single_ball(triggering_ball, split_amount)
