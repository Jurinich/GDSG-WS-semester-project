extends Control

@onready var sound_slider: HSlider = $Container/Content/HBoxContainer2/HSlider
@onready var music_slider: HSlider = $Container/Content/HBoxContainer/HSlider
@onready var sound_button: Button = $Container/Content/Button
@onready var music_button: Button = $Container/Content/Button2
@onready var gamemode_menu: LoopingSelection = $Container/Content/Gamemode/LoopingSelection
@onready var time_menu: LoopingSelection = $Container/Content/Time/LoopingSelection
@onready var items: Control = $Container/Content/Items

var item_scene: PackedScene = preload("res://scenes/ui/item_settings.tscn")

func _ready():
	gamemode_menu.grab_focus()
	_init_menus()
	_init_item_settings()
	init_music()
	init_sound()

func _init_menus() -> void:
	gamemode_menu.select_value(GameManager.settings.gamemode)
	gamemode_menu.value_changed.connect(_on_gamemode_changed)
	time_menu.select_value(GameManager.settings.time)
	time_menu.value_changed.connect(_on_time_changed)
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

func _on_gamemode_changed(value: Variant) -> void:
	GameManager.settings.gamemode = value as Settings.GameMode

func _on_time_changed(value: Variant) -> void:
	GameManager.settings.time = value as float

func _on_item_changed(value: Variant, index: int) -> void:
	GameManager.settings.items[index].weight = value as float

func _on_back_button_pressed():
	GameManager.settings.save()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func sound_button_pressed():
	if AudioManager.sound_muted():
		AudioManager.set_sound_volume(1.0);
		sound_slider.editable = true;
		sound_button.text = "Sound: On";
	else:
		AudioManager.set_sound_volume(0.0);
		sound_slider.editable = false;
		sound_button.text = "Sound: Off";

func music_button_pressed():
	if AudioManager.music_muted():
		AudioManager.set_music_volume(1.0);
		music_slider.editable = true;
		music_button.text = "Music: On";
	else:
		AudioManager.set_music_volume(0.0);
		music_slider.editable = false;
		music_button.text = "Music: Off";

func init_music():
	if (AudioManager.get_music_volume() <= 0):
		music_slider.editable = false;
		music_button.text = "Music: Off";
		return;
	music_slider.value = AudioManager.get_music_volume();

func init_sound():
	if (AudioManager.get_sound_volume() <= 0):
		sound_slider.editable = false;
		sound_button.text = "Sound: Off";
		return;
	sound_slider.value = AudioManager.get_sound_volume();
