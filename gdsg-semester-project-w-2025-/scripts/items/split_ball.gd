extends Node

@export var split_all_balls: bool = false
@export var split_amount: int = 3 

func apply_effect(player: CharacterBody2D, triggering_ball: Ball = null):
	var spawner = get_tree().get_first_node_in_group("ball_spawner")
	if not spawner: return
	
	if split_all_balls:
		var active_balls = get_tree().get_nodes_in_group("balls")
		for ball in active_balls:
			spawner.split_ball(ball, split_amount)
	elif triggering_ball != null:
		spawner.split_ball(triggering_ball, split_amount)
