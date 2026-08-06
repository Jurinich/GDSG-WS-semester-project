extends Control

@onready var back_button: CustomButton = $Container/BackButton
@onready var gamemode_menu: LoopingSelection = $Container/ScrollContainer/Content/Gamemode/LoopingSelection
@onready var time_menu: LoopingSelection = $Container/ScrollContainer/Content/Time/LoopingSelection
@onready var score_menu: LoopingSelection = $Container/ScrollContainer/Content/Score/LoopingSelection
@onready var item_menu: LoopingSelection = $Container/ScrollContainer/Content/ItemSpawns/LoopingSelection
@onready var time_container: Control = $Container/ScrollContainer/Content/Time
@onready var score_container: Control = $Container/ScrollContainer/Content/Score
@onready var layout_menu: LoopingSelection = $Container/ScrollContainer/Content/MapLayout/LoopingSelection
@onready var items: Control = $Container/ScrollContainer/Content/Items
@onready var scroll_container: ScrollContainer = $Container/ScrollContainer

var focusable_controls: Array[Control] = []
var item_scene: PackedScene = preload("res://scenes/ui/item_settings.tscn")

func _ready():
	gamemode_menu.grab_focus()
	back_button.pressed.connect(_on_back_button_pressed)
	_init_menus()
	_init_item_settings()
	_connect_focus_signals(scroll_container)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_button_pressed()

func _connect_focus_signals(node: Node):
	if node is Control && node.focus_mode != FOCUS_NONE:
		node.focus_entered.connect(_on_control_focused_item.bind(focusable_controls.size()))
		focusable_controls.append(node)
	for child in node.get_children():
		_connect_focus_signals(child)

func _on_control_focused_item(index: int):
	AudioManager.playSound.bind(&"menu_hover")
	if index > 0:
		scroll_container.ensure_control_visible(focusable_controls[index - 1])
	if index < focusable_controls.size() - 1:
		scroll_container.ensure_control_visible(focusable_controls[index + 1])

func _setup_score_menu() -> void:
	var score_items: Array[LoopingSelectionItem]
	for i in range(5, 51):
		var item: LoopingSelectionItem = LoopingSelectionItem.new()
		item.text = str(i)
		item.value = i
		score_items.append(item)
	score_menu.items = score_items

func _init_menus() -> void:
	gamemode_menu.select_value(GameManager.settings.gamemode)
	gamemode_menu.value_changed.connect(_on_gamemode_changed)
	time_menu.select_value(GameManager.settings.time)
	time_menu.value_changed.connect(_on_time_changed)
	time_container.visible = GameManager.settings.gamemode == Settings.GameMode.TIME
	_setup_score_menu()
	score_menu.select_value(GameManager.settings.score)
	score_menu.value_changed.connect(_on_score_changed)
	score_container.visible = GameManager.settings.gamemode == Settings.GameMode.SCORE
	layout_menu.select_value(GameManager.settings.layout)
	layout_menu.value_changed.connect(_on_layout_changed)
	item_menu.select_value(GameManager.settings.spawn_rates)
	item_menu.value_changed.connect(_on_items_changed)
	items.visible = GameManager.settings.spawn_rates == Settings.ItemSpawns.CUSTOM

func _init_item_settings() -> void:
	var last_category = -1
	for i in GameManager.settings.items.size():
		var item: ItemDrop = GameManager.settings.items[i]
		if last_category != item.item.category:
			last_category = item.item.category
			items.add_child(_create_label(ItemData.CATEGORY_NAMES[last_category]))
		var item_setting = item_scene.instantiate();
		item_setting.get_node("Label").text = item.item.name
		items.add_child(item_setting)
		var selection: LoopingSelection = item_setting.get_node("LoopingSelection")
		selection.value_changed.connect(_on_item_changed.bind(i))
		selection.select_value(item.weight)

func _create_label(text: String) -> Label:
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = text
	label.add_theme_font_size_override("font_size", 30)
	return label

func _on_gamemode_changed(value: Settings.GameMode) -> void:
	GameManager.settings.gamemode = value
	time_container.visible = value == Settings.GameMode.TIME
	score_container.visible = value == Settings.GameMode.SCORE

func _on_time_changed(value: float) -> void:
	GameManager.settings.time = value
	
func _on_items_changed(value: Settings.ItemSpawns) -> void:
	GameManager.settings.spawn_rates = value
	items.visible = value == Settings.ItemSpawns.CUSTOM

func _on_score_changed(value: int) -> void:
	GameManager.settings.score = value

func _on_layout_changed(value: int) -> void:
	GameManager.settings.layout = value

func _on_item_changed(value: float, index: int) -> void:
	GameManager.settings.items[index].weight = value

func _on_back_button_pressed():
	GameManager.settings.save()
	GameManager.change_scene(GameManager.Scene.MAIN_MENU)
