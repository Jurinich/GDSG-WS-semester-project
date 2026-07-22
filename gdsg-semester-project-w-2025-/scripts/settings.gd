class_name Settings

enum GameMode {TIME, SCORE}

const SETTINGS_FILE := "user://settings.cfg"
const ITEM_DIRECTORY: String = "res://resources/items/"

var gamemode: GameMode
var time: float
var score: int
var layout: int
var items: Array[ItemDrop]

func _load_items() -> void:
	items.clear()
	var files: PackedStringArray = ResourceLoader.list_directory(ITEM_DIRECTORY)
	for file: String in files:
		var item: ItemDrop = ItemDrop.new()
		item.item = ResourceLoader.load(ITEM_DIRECTORY + file)
		items.push_back(item)

func save() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "gamemode", gamemode)
	config.set_value("game", "time", time)
	config.set_value("game", "score", score)
	config.set_value("game", "layout", layout)
	for item: ItemDrop in items:
		config.set_value("items", item.item.power_up_effect, item.weight)
	config.save(SETTINGS_FILE)

func load() -> void:
	_load_items();
	var config := ConfigFile.new()
	if config.load(SETTINGS_FILE) != OK:
		return
	gamemode = config.get_value("game", "gamemode", GameMode.TIME)
	time = config.get_value("game", "time", 180.0)
	score = config.get_value("game", "score", 20)
	layout = config.get_value("game", "layout", -1)
	for item in items:
		var weight = config.get_value("items", item.item.power_up_effect, 10.0)
		item.weight = weight
