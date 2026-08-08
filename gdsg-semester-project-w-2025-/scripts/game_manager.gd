extends Node

var ball_limit: int = 20

var left_player_paddle: Paddle
var right_player_paddle: Paddle

var settings: Settings = Settings.new()

enum Scene {
	MAIN_MENU, GAME, SETTINGS, CREDITS
}

const SCENE_FILES: Dictionary = {
	Scene.MAIN_MENU: "res://scenes/ui/main_menu.tscn",
	Scene.GAME: "res://scenes/game.tscn",
	Scene.SETTINGS: "res://scenes/ui/settings_scene.tscn",
	Scene.CREDITS: "res://scenes/ui/credits_scene.tscn"
}

func _ready() -> void:
	settings.load()

func change_scene(scene: Scene, deferred: bool = false) -> void:
	if deferred:
		get_tree().call_deferred("change_scene_to_file", SCENE_FILES[scene])
	else:
		get_tree().change_scene_to_file(SCENE_FILES[scene])

func _unhandled_input(event: InputEvent):
	#if event is InputEventKey:
		#print("keyboard: ", event.device)
	
	if event.is_action_pressed("Quit"):
		get_tree().quit()

func can_spawn_more() -> bool:
	var current_ball_count = get_tree().get_nodes_in_group("balls").size()
	return current_ball_count < ball_limit
