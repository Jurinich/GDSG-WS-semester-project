class_name Settings

enum GameMode {TIME, SCORE}
enum ItemSpawns {NONE, STANDARD, CUSTOM}

const SETTINGS_FILE: String = "user://settings.cfg"
const DEBUG_SETTINGS: String = "res://settings.cfg"
const ITEM_DIRECTORY: String = "res://resources/items/"

var gamemode: GameMode
var spawn_rates: ItemSpawns
var time: float
var score: int
var layout: int
var items: Array[ItemDrop]
var items_standard: Array[ItemDrop]

func _load_items() -> void:
	items.clear()
	items_standard.clear()
	var files: PackedStringArray = ResourceLoader.list_directory(ITEM_DIRECTORY)
	for file: String in files:
		var item: ItemDrop = ItemDrop.new()
		item.item = ResourceLoader.load(ITEM_DIRECTORY + file)
		items.push_back(item)
		items_standard.push_back(item.duplicate())
	items.sort_custom(_sort_by_category)
	items_standard.sort_custom(_sort_by_category)

func _sort_by_category(a, b) -> bool:
	return a.item.category < b.item.category

func get_item_drops() -> Array[ItemDrop]:
	if spawn_rates == ItemSpawns.CUSTOM:
		return items
	if spawn_rates == ItemSpawns.STANDARD:
		return items_standard
	return []

func save() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "gamemode", gamemode)
	config.set_value("game", "time", time)
	config.set_value("game", "score", score)
	config.set_value("game", "layout", layout)
	config.set_value("game", "spawn_rates", spawn_rates)
	for item: ItemDrop in items:
		config.set_value("items", item.item.power_up_effect, item.weight)
	_save_audio_settings(config)
	config.save(DEBUG_SETTINGS if OS.is_debug_build() else SETTINGS_FILE)

func _save_audio_settings(config: ConfigFile) -> void:
	for bus: AudioManager.Bus in AudioManager.Bus.values():
		var key: String = AudioManager.Bus.keys()[bus].to_lower()
		config.set_value("audio", key + "_volume", AudioManager.get_volume(bus))
		config.set_value("audio", key + "_mute", AudioManager.is_mute(bus))

func load() -> void:
	_load_items();
	var config := ConfigFile.new()
	config.load(DEBUG_SETTINGS if OS.is_debug_build() else SETTINGS_FILE)
	gamemode = config.get_value("game", "gamemode", GameMode.TIME)
	time = config.get_value("game", "time", 180.0)
	score = config.get_value("game", "score", 20)
	layout = config.get_value("game", "layout", -1)
	spawn_rates = config.get_value("game", "spawn_rates", ItemSpawns.STANDARD)
	for i in range(items.size()):
		var weight = config.get_value("items", items[i].item.power_up_effect, 10.0)
		items_standard[i].weight = 10.0
		items[i].weight = weight
	_load_audio_settings(config)

func _load_audio_settings(config: ConfigFile) -> void:
	for bus: AudioManager.Bus in AudioManager.Bus.values():
		var key: String = AudioManager.Bus.keys()[bus].to_lower()
		AudioManager.set_volume(bus, config.get_value("audio", key + "_volume", 1.0))
		AudioManager.mute(bus, config.get_value("audio", key + "_mute", false))
