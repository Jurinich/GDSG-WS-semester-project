extends Node
class_name PlayerInventory

@export var max_items: int = 0
var items: Array[ItemData] = []
var selected_index: int = 0

@export var cycle_action: String = "" 
@export var use_action: String = ""

@onready var powerup_use: AudioStreamPlayer = $"../../powerup use"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(cycle_action):
		cycle_item()
	elif Input.is_action_just_pressed(use_action):
		use_item()
		
func add_item(new_item: ItemData) -> bool:
	if items.size() < max_items:
		items.append(new_item)
		print(get_parent().name, " picked up an item, total: ", items.size())
		return true 
	else:#full inventory
		return false 

func cycle_item() -> void:
	pass

func use_item(triggering_ball: Ball = null) -> void:
	if items.size() > 0 and selected_index < items.size():
		var item_to_use = items[selected_index]
		
		activate_powerup(item_to_use)
		
		items.remove_at(selected_index)
		
		if selected_index >= items.size() and items.size() > 0:
			selected_index = items.size() - 1
		elif items.size() == 0:
			selected_index = 0
			
func activate_powerup(item: ItemData, triggering_ball: Ball = null) -> void:
	if item.power_up_effect.is_empty():
		return
	var effects_hub = get_tree().get_first_node_in_group("item_effects")
	
	if effects_hub != null:
		var effect_node = effects_hub.get_node_or_null(item.power_up_effect)
		if effect_node and effect_node.has_method("apply_effect"):
			effect_node.apply_effect(get_parent(), triggering_ball) 
			powerup_use.play()
		else:
			print("no '", item.power_up_effect, "' or no apply_effect method.")
	else:
		print("not in ItemEffects group")
