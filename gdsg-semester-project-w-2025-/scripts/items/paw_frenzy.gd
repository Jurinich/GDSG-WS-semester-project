extends Node

func apply_effect(player: CharacterBody2D):
	print(player.name, " used the Paw Frenzy")
	var spawner = get_tree().get_first_node_in_group("kitten_spawner")
	if spawner and spawner.has_method("activate_frenzy"):
		spawner.activate_frenzy(10.0)
