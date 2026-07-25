extends Node

func apply_effect(_player: CharacterBody2D, _triggering_ball: Ball = null):
	var spawner = get_tree().get_first_node_in_group("kitten_spawner")
	if spawner and spawner.has_method("activate_frenzy"):
		spawner.activate_frenzy(20.0)
