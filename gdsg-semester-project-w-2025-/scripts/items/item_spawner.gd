extends Node2D
class_name ItemSpawner

var elapsed_time : float = 0.0

var item_drops : Array[ItemDrop] = [] 
@export var item_scene : PackedScene 
@export var paddle_item_scene: PackedScene 

@export var time_for_new_item : float = 12.0
@export var min_items_to_spawn: int = 3
@export var max_items_to_spawn: int = 5
@export var delay_between_spawns: float = 0.5

@export_range(-360.0, 360.0) var shoot_angle_degrees: float = 90.0 
@export var min_shoot_speed: float = 400.0
@export var max_shoot_speed: float = 700.0
@export var spread_degrees: float = 45.0

func _ready() -> void:
	item_drops = GameManager.settings.items

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= time_for_new_item:
		var item = chooseItem()
		if item != null: 
			spawn_burst()
		elapsed_time = 0.0

func spawn_burst():
	var amount = randi_range(min_items_to_spawn, max_items_to_spawn)
	
	for i in range(amount):
		var item = chooseItem()
		if item != null: 
			spawnItem(item)
			
		await get_tree().create_timer(delay_between_spawns).timeout
		
func chooseItem() -> ItemData:
	if item_drops.is_empty():
		return null
		
	var total_weight: float = 0.0
	for drop in item_drops:
		total_weight += drop.weight
	
	if total_weight == 0.0:
		return null
	
	var roll = randf_range(0.0, total_weight)
	var current_weight: float = 0.0
	for drop in item_drops:
		current_weight += drop.weight
		if roll <= current_weight:
			return drop.item
	return item_drops[0].item
	
func spawnItem(item_data: ItemData):
	AudioManager.playSound("powerup_spawned");
	
	var item_node: Node2D
	if item_data.is_paddle_powerup:
		item_node = paddle_item_scene.instantiate() 
	else:
		item_node = item_scene.instantiate()
	
	item_node.top_level = true 
	add_child(item_node) 
	item_node.global_position = self.global_position

	var random_angle = shoot_angle_degrees + randf_range(-spread_degrees, spread_degrees)
	var direction = Vector2.RIGHT.rotated(deg_to_rad(random_angle))
	var random_speed = randf_range(min_shoot_speed, max_shoot_speed)
	var velocity = direction * random_speed

	item_node.setup(item_data)
	if item_node.has_method("shoot"):
		item_node.shoot(velocity)
