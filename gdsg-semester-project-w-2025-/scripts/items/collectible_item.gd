extends Area2D
class_name CollectibleItem

@export var tex_scale: float = 1.0

@onready var sprite : Sprite2D = $CollisionShape2D/Sprite2D
@onready var shadow : Sprite2D = $CollisionShape2D/Shadow
@onready var player_1: CharacterBody2D = $"../../Player1"

@export var animation_speed : float = 0.003
@export var animation_bounce_range : float = 5.0
@export var animation_shadow_scale : float = 0.1

var item_data : ItemData

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(_item_data : ItemData):
	item_data = _item_data
	sprite.texture = item_data.sprite
	$CollisionShape2D.scale = Vector2.ONE * tex_scale

func _process(_delta: float) -> void:
	var value = sin(animation_speed * Time.get_ticks_msec())
	sprite.position.y = value * animation_bounce_range
	shadow.scale = Vector2.ONE * (1.0 + (value * animation_shadow_scale))

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		var player = player_1
		var inventory: PlayerInventory = null
		for child in player.get_children():
			if child is PlayerInventory:
				inventory = child
				print(child)
				break 

		if inventory != null:
			print("test1")
			var was_picked_up = inventory.add_item(item_data)

			if not was_picked_up:
				print("test2")
				print(player.name, " inventory is full -> auto-use item")
				inventory.activate_powerup(item_data)

			queue_free()
