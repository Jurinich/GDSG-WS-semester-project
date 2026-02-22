extends Node

@export var split_amount: int = 3 

func apply_effect(player: CharacterBody2D):
	print(player.name, " used Split Ball x", split_amount)
	
	var spawner = get_tree().get_first_node_in_group("ball_spawner")
	var active_balls = get_tree().get_nodes_in_group("balls")
	
	if spawner and active_balls.size() > 0:
		# Loop through EVERY ball on the board and split it
		for ball in active_balls:
			spawner.split_ball(ball, split_amount)
