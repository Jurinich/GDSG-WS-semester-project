extends Area2D
class_name CollectibleItem

@onready var sprite : Sprite2D = $Sprite2D
var item_data : ItemData

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(_item_data : ItemData):
	item_data = _item_data
	sprite.texture = item_data.sprite

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		var player = body.last_hit_by

		if player != null:
			var inventory: PlayerInventory = null
			for child in player.get_children():
				if child is PlayerInventory:
					inventory = child
					break 

			if inventory != null:
				var was_picked_up = inventory.add_item(item_data)

				if not was_picked_up:
					print(player.name, " inventory is full -> auto-use item")
					inventory.activate_powerup(item_data)

				queue_free()
