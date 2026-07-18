extends CharacterBody2D
class_name CollectibleItem

@export var tex_scale: float = 1.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var shadow : Sprite2D = $Shadow
@onready var player_1: CharacterBody2D = $"../../Player1"

@export var animation_speed : float = 0.003
@export var animation_bounce_range : float = 5.0
@export var animation_shadow_scale : float = 0.1

@onready var pickup_area: Area2D = $PickupArea

var item_data : ItemData
@export var friction: float = 235.0

func _ready() -> void:
	pickup_area.body_entered.connect(_on_body_entered)

func setup(_item_data : ItemData):
	item_data = _item_data
	sprite.texture = item_data.sprite
	$CollisionShape2D.scale = Vector2.ONE * tex_scale
	$PickupArea.scale = Vector2.ONE * tex_scale

func shoot(initial_velocity: Vector2):
	velocity = initial_velocity

func _physics_process(delta: float) -> void:
	if velocity.length() > 0:
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			var collider = collision.get_collider()
			if collider is CollectibleItem:
				collider.velocity -= collision.get_normal() * (velocity.length() * 0.5)
			
			velocity = velocity.bounce(collision.get_normal()) * 0.9
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	
	var value = sin(animation_speed * Time.get_ticks_msec())
	sprite.position.y = value * animation_bounce_range
	shadow.scale = Vector2.ONE * (1.0 + (value * animation_shadow_scale))


func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		var player = body.last_hit_by
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
				inventory.activate_powerup(item_data, body)

			queue_free()
