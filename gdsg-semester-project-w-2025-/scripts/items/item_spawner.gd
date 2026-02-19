extends Node2D

class_name ItemSpawner

enum SpawnChance{
	NONE,
	LOW,
	MEDIUM,
	HIGH
}

##Needs a list of all available items and then logic to spawn them 
##Within a designated area

@export var time_for_new_item : float = 10.0 #maybe later this could be a range using a Vector2ii
var elapsed_time : float = 0.0
@export var items_and_chance : Array[ItemData]
@export var item_scene : PackedScene 
@export var spawn_area_size: Vector2 = Vector2(800, 600)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= time_for_new_item:
		var item = chooseItem()
		spawnItem(item)
		elapsed_time = 0.0


##Choose which of the available items to spawn
func chooseItem() -> ItemData:
	return items_and_chance[0]
	
	
	
##Spawn the actual item, by instantiating its scene with the corresponding Data
func spawnItem(item_data : ItemData):
	var item_node : CollectibleItem = item_scene.instantiate()
	var half_size = spawn_area_size / 2.0
	var random_x = randf_range(-half_size.x, half_size.x)
	var random_y = randf_range(-half_size.y, half_size.y)
	item_node.position = Vector2(random_x, random_y)
	add_child(item_node)
	item_node.setup(item_data)
