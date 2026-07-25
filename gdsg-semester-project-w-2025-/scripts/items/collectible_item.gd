class_name CollectibleItem extends Item

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		var player = body.last_hit_by
		var inventory: PlayerInventory = null
		
		for child in player.get_children():
			if child is PlayerInventory:
				inventory = child
				break 
		
		if inventory != null:
			var was_picked_up = inventory.add_item(item_data)
			
			if not was_picked_up:
				inventory.activate_powerup(item_data, body)
			
			queue_free()
