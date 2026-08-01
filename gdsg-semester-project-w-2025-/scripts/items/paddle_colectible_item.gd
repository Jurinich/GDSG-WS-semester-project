class_name PaddleCollectibleItem extends Item

func _ready() -> void:
	super._ready()
	pickup_area.area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D && (body.name == "Player1" or body.name == "Player2"):
		var inventory = _get_inventory(body)
		if inventory != null:
			inventory.activate_powerup(item_data, null)
		queue_free()
	
func _on_area_entered(area: Node2D) -> void:
	if area is VacuumCleaner:
		var inventory = _get_inventory(area.get_parent())
		if inventory != null:
			inventory.activate_powerup(item_data, null)
		queue_free()

func _get_inventory(node: Node2D) -> PlayerInventory:
	for child in node.get_children():
		if child is PlayerInventory: 
			return child
	return null
