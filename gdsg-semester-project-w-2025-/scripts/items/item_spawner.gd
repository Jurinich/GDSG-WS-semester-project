extends Node2D

class_name ItemSpawner

enum SpawnChance {
	NONE = 0,
	LOW = 5,
	MEDIUM = 10,
	HIGH = 20
}

@export var time_for_new_item : float = 8.0 #maybe later this could be a range using a Vector2ii
var elapsed_time : float = 0.0
var item_drops : Array[ItemDrop]
@export var item_scene : PackedScene 
@export var spawn_area_size: Vector2 = Vector2(800, 600)
@onready var powerup_spawn: AudioStreamPlayer = $"/root/Game/powerup spawn"

func _ready() -> void:
	item_drops = GameManager.settings.items

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= time_for_new_item:
		var item = chooseItem()
		spawnItem(item)
		elapsed_time = 0.0


##Choose which of the available items to spawn
func chooseItem() -> ItemData:
	if item_drops.is_empty():
		return null
		
	var total_weight: float = 0.0
	for drop in item_drops:
		total_weight += drop.weight
		
	var roll = randf_range(0.0, total_weight)
	
	var current_weight: float = 0.0
	for drop in item_drops:
		current_weight += drop.weight
		if roll <= current_weight:
			return drop.item
			
	return item_drops[0].item
	
	
	
##Spawn the actual item, by instantiating its scene with the corresponding Data
func spawnItem(item_data : ItemData):
	powerup_spawn.play()
	var item_node : CollectibleItem = item_scene.instantiate()
	var half_size = spawn_area_size / 2.0
	var random_x = randf_range(-half_size.x, half_size.x)
	var random_y = randf_range(-half_size.y, half_size.y)
	item_node.position = Vector2(random_x, random_y)

	add_child(item_node)
	item_node.setup(item_data)
