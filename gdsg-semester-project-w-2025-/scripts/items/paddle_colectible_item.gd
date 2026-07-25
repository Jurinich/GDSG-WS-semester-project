class_name PaddleCollectibleItem extends Item

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and (body.name == "Player1" or body.name == "Player2"):
		var inventory: PlayerInventory = null
		for child in body.get_children():
			if child is PlayerInventory: 
				inventory = child
				break 
		
		if inventory != null and inventory.has_method("activate_powerup"):
			inventory.activate_powerup(item_data, null)
			
		queue_free() 
