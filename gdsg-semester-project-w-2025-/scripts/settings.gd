class_name Settings

enum GameMode {TIME, SCORE}

const ITEM_DIRECTORY: String = "res://resources/items/"

var gamemode: GameMode = GameMode.TIME
var time: float = 180.0
var score: int = 20
var items: Array[ItemDrop] = []

func load_items() -> void:
	items.clear()
	var files: PackedStringArray = ResourceLoader.list_directory(ITEM_DIRECTORY)
	for file: String in files:
		var item: ItemDrop = ItemDrop.new()
		item.item = ResourceLoader.load(ITEM_DIRECTORY + file)
		items.push_back(item)
