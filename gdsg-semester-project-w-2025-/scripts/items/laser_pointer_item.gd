extends Node

func apply_effect(player: CharacterBody2D, _triggering_ball: Ball = null):
	print(player.name, " used the Laser Pointer")
	print("isPlayer1 ", player.isP1)
	print("player ", player)
	var laser = get_tree().get_first_node_in_group("laser_pointer")
	if laser and laser.has_method("activate"):
		laser.activate(3, !player.isP1)
