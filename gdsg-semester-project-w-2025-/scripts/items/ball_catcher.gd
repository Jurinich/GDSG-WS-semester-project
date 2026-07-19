extends Node

@export var catcher_scene: PackedScene

func apply_effect(player: CharacterBody2D, _triggering_ball: Ball = null):
	print(player.name, " used the Paddle Catcher")
	
	if player.has_node("BallCatcher"):
		return
		
	if catcher_scene:
		var catcher = catcher_scene.instantiate()
		catcher.name = "BallCatcher"
		
		catcher.paddle_owner = player
		player.add_child.call_deferred(catcher)
		
		var offset_x = 60.0 if player.isP1 else -60.0
		catcher.position = Vector2(offset_x, 0)
		if player.isP1:
			catcher.scale.x = -1
	else:
		push_error("catcher not assigned")
