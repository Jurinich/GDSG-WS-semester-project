class_name KittenSpawner
extends Node

@export_group("Settings")
@export var paw_scene: PackedScene
@export_range(0.0, 1.0) var hit_chance: float = 0.3

@export_group("References")
@export var triggers: Array[Area2D] 
@onready var paw_swiff_sound: AudioStreamPlayer = $"../paw swiff sound"
@onready var effects: EffectTimerManager = $"../ForegroundUILayer/EffectTimers"

var base_hit_chance: float
var frenzy_timer: Timer

func _ready():
	add_to_group("kitten_spawner")
	base_hit_chance = hit_chance
	frenzy_timer = Timer.new()
	frenzy_timer.one_shot = true
	frenzy_timer.timeout.connect(_on_frenzy_timeout)
	add_child(frenzy_timer)
	
	for i in range(triggers.size()):
		var trigger = triggers[i]
		if trigger:
			if !trigger.body_entered.is_connected(_on_trigger_entered):
				trigger.body_entered.connect(_on_trigger_entered)

func _on_trigger_entered(body):
	if body is Ball:
		attempt_kitten_spawn(body)

func attempt_kitten_spawn(target_ball: Ball):
	var roll = randf()
	if roll > hit_chance:
		return 

		# max 1 paw
	if get_tree().get_node_count_in_group("KittenPaws") > 0:
		return

	call_deferred("spawn_paw", target_ball)

func spawn_paw(target_ball: Ball):
	if paw_scene:
		paw_swiff_sound.play()
		var paw = paw_scene.instantiate()
		paw.add_to_group("KittenPaws")
		get_tree().current_scene.add_child(paw)
		paw.attack(target_ball)

func activate_frenzy(duration: float):
	print("Paw Frenzy 100% chance for ", duration, " seconds")
	hit_chance = 1.0
	frenzy_timer.start(duration)
	effects.show_effect_timer("PAW FRENZY", duration)

func _on_frenzy_timeout():
	print("Paw Frenzy over")
	hit_chance = base_hit_chance
