class_name EffectTimer
extends Control

signal finished(id: String)

@onready var label: Label = $"Progress/Label"
@onready var progress: TextureProgressBar = $"Progress"

@export var ANIMATION_DURATION = 0.1
@export var ANIMATION_SCALE = 0.1
@export var ANIMATION_POSITION = 10
@export var SIGNAL_DELAY = 0.2

var effect_id: String = ""
var running: bool = false
var remaining_time: float = 0

func set_duration(time: float) -> void:
	progress.max_value = time
	remaining_time = time
	running = true

func set_progress(value: float, max_value: float = 0) -> void:
	progress.value = value
	if max_value > 0:
		progress.max_value = max_value
	if value <= 0:
		emit_finished()

func set_effect(text: String) -> void:
	effect_id = text
	label.text = text

func play_bounce_animation():
	var tween_scale = create_tween()
	var offset_scale = Vector2(ANIMATION_SCALE, -ANIMATION_SCALE)
	tween_scale.tween_property(progress, "scale", Vector2.ONE + offset_scale, ANIMATION_DURATION)
	offset_scale /= -2
	tween_scale.tween_property(progress, "scale", Vector2.ONE + offset_scale, ANIMATION_DURATION)
	tween_scale.tween_property(progress, "scale", Vector2.ONE, ANIMATION_DURATION)

func emit_finished():
	var tween = create_tween()
	tween.chain().tween_interval(SIGNAL_DELAY)
	tween.chain().tween_callback(finished.emit.bind(effect_id))

func _process(delta: float) -> void:
	if running:
		remaining_time -= delta
		progress.value = remaining_time
		if progress.value <= 0:
			running = false
			emit_finished()
