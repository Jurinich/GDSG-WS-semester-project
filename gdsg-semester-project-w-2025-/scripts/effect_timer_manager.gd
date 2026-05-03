class_name EffectTimerManager
extends VBoxContainer

var timer = preload("res://scenes/effect_timer.tscn")

@export var HIDDEN_Y: float = 500

var active_effects = {}

func slide_in(element: EffectTimer):
	element.progress.position.y = HIDDEN_Y
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(element.progress, "position:y", 0, 0.2)
	tween.chain().tween_callback(element.play_bounce_animation)

func slide_out(element: EffectTimer):
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(element.progress, "position:y", HIDDEN_Y, 0.2)
	tween.chain().tween_callback(element.queue_free)

func on_effect_finished(effect_id: String):
	var bar = active_effects[effect_id]
	active_effects.erase(effect_id)
	slide_out(bar)

func show_effect_timer(text: String, duration: float):
	var element: EffectTimer
	if active_effects.has(text):
		element = active_effects[text]
		element.play_bounce_animation()
	else:
		element = add_element(text)
	element.set_duration(duration)

func show_effect_counter(text: String, value: float, max_value: float = 0):
	var element: EffectTimer
	if active_effects.has(text):
		element = active_effects[text]
		if max_value > 0:
			element.play_bounce_animation()
	else:
		element = add_element(text)
	element.set_progress(value, max_value)

func add_element(text: String) -> EffectTimer:
	var element: EffectTimer = timer.instantiate()
	add_child(element)
	element.finished.connect(on_effect_finished)
	element.set_effect(text)
	active_effects[text] = element
	slide_in(element)
	return element
