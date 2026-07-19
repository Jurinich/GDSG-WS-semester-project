@tool
class_name LoopingSelection extends Control

signal value_changed(value: Variant)

@export var horizontal: bool = false
@export var item_padding: float = 50.0 # affects 3d effect and how far up/down the menu goes
@export var rotation_speed: float = 10.0  # how fast the menu should spin
@export var font_size: int = 40

@export_range(0.0, 1.0) var scale_modifier: float = 0.20  # how quickly elements scale down

@export var selected_item: int = 0
@export var items: Array[LoopingSelectionItem]:
	set(value):
		items = value
		if is_node_ready():
			_populate_label_array()

var labels: Array[Label] = []
var largest_label: float = 0.0

var visual_selected_item: float = selected_item # used to smooth the animation
var target_selected_item: float = selected_item # used to smooth the animation

var focused: bool = false

func _ready() -> void:
	if items.size() == 2:
		items.append_array(items)
	_populate_label_array()
	focus_entered.connect(_on_focused_changed.bind(true))
	focus_exited.connect(_on_focused_changed.bind(false))

func _process(delta: float) -> void:
	var interpolation = clamp(rotation_speed * delta, 0.0, 1.0)
	
	visual_selected_item = lerpf(visual_selected_item, target_selected_item, interpolation)
	
	var center = size / 2.0
	var count = labels.size()
	
	var max_index_range = max(1.0, float(count - 1) / 2.0)
	var angle_step = PI / max_index_range
	
	var desired_spacing = largest_label + item_padding
	var menu_radius = desired_spacing / (2.0 * sin(angle_step * 0.5))
	
	for i in range(count):
		var label = labels[i]
		
		# distance to selected button, needs to wrap around but also has to be from -n/2 to n/2
		# first I get the relative position to selected button but fposmod only returns positive values (from 0 to n)
		# so count / 2.0 needs to be subtracted (-n/2 to n/2)
		var offset = fposmod(i - visual_selected_item + count / 2.0, count) - count / 2.0
		
		var angle = clamp(offset / max_index_range, -1.0, 1.0) * PI
		var position_offset = sin(angle) * menu_radius
		var depth = cos(angle)
		
		# depth gives (-1.0 to 1.0), need (0 to 1)
		var depth_level = (depth + 1.0) / 2.0
		
		var target_position = Vector2(center.x, center.y) - label.size / 2.0
		if horizontal:
			target_position.x += position_offset
		else:
			target_position.y += position_offset
		
		label.position = lerp(label.position, target_position, interpolation)
		
		var target_scale = lerp(1.0 - scale_modifier, 1.0, depth_level)
		label.scale = Vector2.ONE * target_scale
		
		label.modulate = (Color.WHITE if focused else Color.GRAY) * (depth_level * 0.7 + 0.3)
		label.modulate.a = 1.0 if depth_level > 0.1 else depth_level

		label.z_index = round(depth_level)

func _populate_label_array() -> void:
	for child in get_children():
		if child is Label:
			child.queue_free()
	labels.clear()
	largest_label = 0.0
	for item in items:
		var label := Label.new()
		label.text = item.text
		label.add_theme_font_size_override("font_size", font_size)
		label.pivot_offset_ratio = Vector2(0.5, 0.5)
		add_child(label)
		labels.append(label)
		var label_size : Vector2 = label.get_combined_minimum_size()
		largest_label = max(largest_label, label_size.x if horizontal else label_size.y)
	update_minimum_size()

func select(index: int, animate: bool = false) -> void:
	if labels.is_empty():
		return
	
	if animate:
		target_selected_item += (index - selected_item)
	else:
		target_selected_item = index
		visual_selected_item = index
	selected_item = posmod(index, labels.size())
	value_changed.emit(items[selected_item].value)

func select_value(value: Variant) -> bool:
	for i in range(items.size()):
		if items[i].value == value:
			select(i, false)
			return true
	return false

func _gui_input(event: InputEvent) -> void:
	if _increase_event(event):
		select(selected_item + 1, true)
		get_viewport().set_input_as_handled()
		return
	if _decrease_event(event):
		select(selected_item - 1, true)
		get_viewport().set_input_as_handled()
		return

func _increase_event(event: InputEvent) -> bool:
	if horizontal:
		return event.is_action_pressed("ui_right")
	return event.is_action_pressed("ui_down")

func _decrease_event(event: InputEvent) -> bool:
	if horizontal:
		return event.is_action_pressed("ui_left")
	return event.is_action_pressed("ui_up")

func _on_focused_changed(focus: bool) -> void:
	focused = focus;

func _get_minimum_size() -> Vector2:
	var largest := Vector2.ZERO
	for label in labels:
		largest = largest.max(label.get_combined_minimum_size())
		
	if labels.size() > 1:
		var max_index_range = max(1.0, float(labels.size() - 1) / 2.0)
		var angle_step = PI / max_index_range
		var desired_spacing = largest_label + item_padding
		var menu_radius = desired_spacing / (2.0 * sin(angle_step * 0.5))
		
		if horizontal:
			largest.x += menu_radius * 2.0
		else:
			largest.y += menu_radius * 2.0
	return largest
