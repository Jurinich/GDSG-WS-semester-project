extends Control

@onready var sound_slider: HSlider = $Container/HBoxContainer2/HSlider
@onready var music_slider: HSlider = $Container/HBoxContainer/HSlider
@onready var sound_button: Button = $Container/Button
@onready var music_button: Button = $Container/Button2
@onready var back_button: Button = $Container/BackButton
@onready var gamemode_menu: LoopingSelection = $Container/ScrollContainer/Content/Gamemode/LoopingSelection
@onready var time_menu: LoopingSelection = $Container/ScrollContainer/Content/Time/LoopingSelection
@onready var score_menu: LoopingSelection = $Container/ScrollContainer/Content/Score/LoopingSelection
@onready var time_container: Control = $Container/ScrollContainer/Content/Time
@onready var score_container: Control = $Container/ScrollContainer/Content/Score
@onready var layout_menu: LoopingSelection = $Container/ScrollContainer/Content/MapLayout/LoopingSelection
@onready var items: Control = $Container/ScrollContainer/Content/Items
@onready var scroll_container: ScrollContainer = $Container/ScrollContainer

var item_scene: PackedScene = preload("res://scenes/ui/item_settings.tscn")

func _ready():
	gamemode_menu.grab_focus()
	_set_focus_sound([sound_slider, music_slider, sound_button, music_button, back_button])
	_init_menus()
	_init_item_settings()
	_init_sound()
	connect_focus_signals(scroll_container)

func connect_focus_signals(node: Node):
	if node is LoopingSelection:
		node.focus_entered.connect(_on_control_focused.bind(node))
	
	for child in node.get_children():
		connect_focus_signals(child)

func _set_focus_sound(elements: Array[Control]) -> void:
	for element in elements:
		element.focus_entered.connect(AudioManager.playSound.bind(&"menu_hover"))

func _on_control_focused(control: Control):
	var control_rect = control.get_global_rect()
	var scroll_rect = scroll_container.get_global_rect()
	
	var control_top = control_rect.position.y - scroll_rect.position.y
	var control_bottom = control_top + control_rect.size.y
	
	var margin = control_rect.size.y
	
	if control_top < margin:
		scroll_container.scroll_vertical -= margin - control_top
	elif control_bottom > scroll_rect.size.y - margin:
		scroll_container.scroll_vertical += control_bottom - (scroll_rect.size.y - margin)

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
	sound_slider.value_changed.connect(AudioManager.set_sound_volume)
	music_slider.value_changed.connect(AudioManager.set_music_volume)

func _init_item_settings() -> void:
	for i in GameManager.settings.items.size():
		var item: ItemDrop = GameManager.settings.items[i]
		var item_setting = item_scene.instantiate();
		item_setting.get_node("Label").text = item.item.power_up_effect
		items.add_child(item_setting)
		var selection: LoopingSelection = item_setting.get_node("LoopingSelection")
		selection.value_changed.connect(_on_item_changed.bind(i))
		selection.select_value(item.weight)

func _on_gamemode_changed(value: Settings.GameMode) -> void:
	GameManager.settings.gamemode = value
	time_container.visible = value == Settings.GameMode.TIME
	score_container.visible = value == Settings.GameMode.SCORE

func _on_time_changed(value: float) -> void:
	GameManager.settings.time = value

func _on_score_changed(value: int) -> void:
	GameManager.settings.score = value

func _on_layout_changed(value: int) -> void:
	GameManager.settings.layout = value

func _on_item_changed(value: float, index: int) -> void:
	GameManager.settings.items[index].weight = value

func _on_back_button_pressed():
	GameManager.settings.save()
	GameManager.change_scene(GameManager.Scene.MAIN_MENU)

func sound_button_pressed():
	AudioManager.mute_sound(!AudioManager.sound_muted())
	_update_sound_button()

func music_button_pressed():
	AudioManager.mute_music(!AudioManager.music_muted())
	_update_music_buttons()

func _init_sound():
	_update_sound_button()
	_update_music_buttons()
	sound_slider.value = AudioManager.get_sound_volume();
	music_slider.value = AudioManager.get_music_volume();

func _update_music_buttons() -> void:
	var music_muted = AudioManager.music_muted()
	music_button.text = "Music: " + ("Off" if music_muted else "On")
	music_slider.editable = !music_muted
	music_slider.focus_mode = Control.FOCUS_NONE if music_muted else Control.FOCUS_ALL

func _update_sound_button() -> void:
	var sound_muted = AudioManager.sound_muted()
	sound_button.text = "Sound: " + ("Off" if sound_muted else "On")
	sound_slider.editable = !sound_muted
	sound_slider.focus_mode = Control.FOCUS_NONE if sound_muted else Control.FOCUS_ALL
