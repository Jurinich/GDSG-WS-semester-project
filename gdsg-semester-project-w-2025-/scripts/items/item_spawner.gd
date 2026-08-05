extends Node2D
class_name ItemSpawner

@onready var capsules_node: Node2D = $Capsules
@onready var polygon: Polygon2D = $Polygon
@onready var spawn_point: Node2D = $SpawnPoint
@onready var item_starting_point: Node2D = $ItemStartingPoint

@export var item_scene: PackedScene 
@export var paddle_item_scene: PackedScene 

@export var time_for_new_item : float = 12.0
@export var min_items_to_spawn: int = 3
@export var max_items_to_spawn: int = 5
@export var delay_between_spawns: float = 0.5

@export_range(-360.0, 360.0) var shoot_angle_degrees: float = 90.0 
@export var min_shoot_speed: float = 400.0
@export var max_shoot_speed: float = 700.0
@export var spread_degrees: float = 45.0

var elapsed_time: float = 0.0
var item_drops: Array[ItemDrop] = []

var capsules: Array[ItemCapsule] = []
var capsule_speed: Array[float] = []
var capsule_targets: Array[Vector2] = []

var base_position: Vector2
var shaking_strength := 0.0
var animation_time := 0.0
@export var animation_rotation := 0.007
@export var animation_position := 2.0

func _ready() -> void:
	base_position = position
	item_drops = GameManager.settings.items
	if chooseItem() == null:
		min_items_to_spawn = 0
		max_items_to_spawn = 0
	for capsule in capsules_node.get_children():
		if capsule is ItemCapsule:
			if max_items_to_spawn > 0:
				capsules.append(capsule)
				capsule_targets.append(random_point_in_polygon())
				capsule_speed.append(random_speed())
				capsule.set_sprite(chooseItem())
			else:
				capsule.hide()
	spawn_burst()

func _process(delta: float) -> void:
	if shaking_strength > 0.0:
		animation_time += delta * 30.0
		rotation = sin(animation_time) * animation_rotation * shaking_strength
		var modifier = animation_position * shaking_strength
		position.x = base_position.x + sin(animation_time * 1.7) * modifier
		position.y = base_position.y + cos(animation_time * 2.3) * modifier
	
	elapsed_time += delta
	if elapsed_time >= time_for_new_item:
		spawn_burst()
		elapsed_time = 0.0
	
	for index in range(capsules.size()):
		var capsule = capsules[index]
		var dir = capsule_targets[index] - capsule.position
		
		if dir.length() < 5.0:
			capsule_targets[index] = random_point_in_polygon()
			capsule_speed[index] = random_speed()
			capsule.set_capsule_offset(randf_range(-100.0, 100.0))
			capsule.set_capsule_rotation(randf_range(0, PI / 2))
			capsule.scale = randf_range(0.25, 0.3) * Vector2.ONE
		else:
			capsule.position += dir.normalized() * delta * capsule_speed[index]

func random_speed() -> float:
	return randf_range(80.0, 150.0)

func random_point_in_polygon() -> Vector2:
	var points: PackedVector2Array = polygon.polygon
	var bounds = Rect2(points[0], Vector2.ZERO)
	
	for p in points:
		bounds = bounds.expand(p)
	
	while true:
		var point = Vector2(randf_range(bounds.position.x, bounds.end.x), randf_range(bounds.position.y, bounds.end.y))
		if Geometry2D.is_point_in_polygon(point, points):
			return point
	
	return Vector2.ZERO

func spawn_burst():
	var fade_in = create_tween()
	fade_in.tween_property(self, "shaking_strength", 1.0, 0.5)
	
	var amount = randi_range(min_items_to_spawn, max_items_to_spawn)
	
	for i in range(amount):
		var item = chooseItem()
		if item != null: 
			spawnItem(item)
			
		await get_tree().create_timer(delay_between_spawns).timeout
		
	var fade_out = create_tween()
	fade_out.tween_property(self, "shaking_strength", 0.0, 0.5)

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
	
	var item_node: Item
	if item_data.is_paddle_powerup:
		item_node = paddle_item_scene.instantiate() 
	else:
		item_node = item_scene.instantiate()
	item_node.item_data = item_data
	add_child(item_node)
	item_node.top_level = true
	item_node.global_position = item_starting_point.global_position
	
	var item_scale = item_node.scale
	item_node.scale *= 0.5
	
	var position_tween = create_tween()
	position_tween.tween_property(item_node, "global_position", spawn_point.global_position, 1.0)
	position_tween.tween_callback(release_item.bind(item_node as Item))
	
	var scale_tween = create_tween()
	scale_tween.tween_property(item_node, "scale", item_scale * 2.0, 0.6)
	scale_tween.tween_property(item_node, "scale", item_scale, 0.4)

func release_item(item: Item) -> void:
	var random_angle = shoot_angle_degrees + randf_range(-spread_degrees, spread_degrees)
	var direction = Vector2.RIGHT.rotated(deg_to_rad(random_angle))
	var speed = randf_range(min_shoot_speed, max_shoot_speed)
	var velocity = direction * speed
	item.enable()
	item.shoot(velocity)
