extends Control

@export var bounce_strength: float = 0.02
@export var bounce_speed: float = 2.0

var original_scale: Vector2

var time: float = 0.0

func _ready() -> void:
	original_scale = scale

func _process(delta: float) -> void:
	time += delta
	var bounce = abs(sin(time * bounce_speed)) * bounce_strength
	scale = original_scale + Vector2(bounce, bounce)
