extends Node2D
class_name ItemSpawner

@export var time_for_new_item : float = 8.0
var elapsed_time : float = 0.0

var item_drops : Array[ItemDrop] = [] 

@export var item_scene : PackedScene 

@export_range(-360.0, 360.0) var shoot_angle_degrees: float = 90.0 
@export var min_shoot_speed: float = 250.0
@export var max_shoot_speed: float = 600.0
@export var spread_degrees: float = 45.0

@onready var powerup_spawn: AudioStreamPlayer = $"/root/Game/powerup spawn"
@export_file("*.json") var drop_data_file: String = "res://data/item_drop_rates.json"


func _ready() -> void:
	load_drops_from_json()


func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= time_for_new_item:
		var item = chooseItem()
		if item != null: 
			spawnItem(item)
		elapsed_time = 0.0


func load_drops_from_json():
	var file = FileAccess.open(drop_data_file, FileAccess.READ)
	if not file:
		push_error("Could not find JSON file!")
		return
		
	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error == OK:
		var parsed_data = json.data 
		
		for entry in parsed_data:
			var new_drop = ItemDrop.new()
			new_drop.weight = entry["weight"]
			new_drop.item = load(entry["item_path"]) as ItemData
			item_drops.append(new_drop)
	else:
		push_error("JSON Parse Error!")


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
	
	
func spawnItem(item_data : ItemData):
	powerup_spawn.play()
	var item_node : CollectibleItem = item_scene.instantiate()
	
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
