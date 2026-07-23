extends CanvasLayer

@onready var time_container: HBoxContainer = $TimeContainer
@onready var time_minutes_label: Label = $TimeContainer/TimeMinutes
@onready var time_colon_label: Label = $TimeContainer/TimeColon
@onready var time_seconds_label: Label = $TimeContainer/TimeSeconds
@onready var score_container: HBoxContainer = $HBoxContainer
@onready var score_left_label: Label = $HBoxContainer/ScoreLeft
@onready var score_right_label: Label = $HBoxContainer/ScoreRight
@onready var alarm_overlay: ColorRect = $AlarmOverlay

var alarm_threshold: int = 10
@export_range(0.0, 2.0, 0.01) var motion_strength: float = 0.8 # Intensity of wobble and shake effects
@export_range(0.0, 2.0, 0.01) var flash_speed: float = 1.0 # Speed of the flashing effect
@export var warning_color: Color = Color(1.0, 0.6, 0.6)
var current_game_time: int = 0
var current_animation_speed_factor: float = 0.0
var target_animation_speed_factor: float = 0.0
var animation_time: float = 0.0
var alarm_visual_progress: float = 0.0
var time_container_base_position: Vector2
var time_container_base_scale: Vector2
var time_container_base_rotation: float
var score_container_base_position: Vector2
var score_container_base_scale: Vector2
var score_container_base_rotation: float

func _ready():
	time_container_base_position = time_container.position
	time_container_base_scale = time_container.scale
	time_container_base_rotation = time_container.rotation
	score_container_base_position = score_container.position
	score_container_base_scale = score_container.scale
	score_container_base_rotation = score_container.rotation
	time_container.pivot_offset = time_container.size * 0.5
	score_container.pivot_offset = score_container.size * 0.5
	current_animation_speed_factor = 0.0
	target_animation_speed_factor = 0.0
	animation_time = 0.0
	alarm_visual_progress = 0.0
	_update_alarm_visuals()
	set_process(true)


func set_alarm_state(game_time: int, new_alarm_threshold: int):
	current_game_time = game_time
	alarm_threshold = new_alarm_threshold
	target_animation_speed_factor = get_animation_speed_factor()
	_update_alarm_visuals()
	_set_display_time(current_game_time)


func _set_display_time(display_time: int):
	var safe_time = display_time if display_time > 0 else 0
	@warning_ignore("integer_division")
	var minute = safe_time / 60
	var second = safe_time % 60
	time_minutes_label.text = str(minute)
	time_colon_label.text = ":"
	time_seconds_label.text = "%02d" % second


func _process(_delta: float):
	var smoothing_factor = clamp(_delta * 8.0, 0.0, 1.0)
	current_animation_speed_factor = lerp(current_animation_speed_factor, target_animation_speed_factor, smoothing_factor)
	var alarm_active = current_game_time <= alarm_threshold
	var target_alarm_progress = 1.0 if alarm_active else 0.0
	alarm_visual_progress = lerp(alarm_visual_progress, target_alarm_progress, smoothing_factor)
	animation_time += _delta * current_animation_speed_factor
	_update_alarm_visuals()


func _update_alarm_visuals():
	if alarm_visual_progress <= 0.001:
		time_container.position = time_container_base_position
		time_container.scale = time_container_base_scale
		time_container.rotation = time_container_base_rotation
		time_container.self_modulate = Color.WHITE
		time_minutes_label.self_modulate = Color.WHITE
		time_colon_label.self_modulate = Color.WHITE
		time_seconds_label.self_modulate = Color.WHITE
		score_left_label.rotation = 0.0
		score_left_label.self_modulate = Color.WHITE
		score_right_label.rotation = 0.0
		score_right_label.self_modulate = Color.WHITE
		score_container.position = score_container_base_position
		score_container.scale = score_container_base_scale
		score_container.rotation = score_container_base_rotation
		score_container.self_modulate = Color.WHITE
		alarm_overlay.color = Color(1.0, 0.1, 0.1, 0.0)
		return

	var wobble_phase = animation_time
	var flash_phase = Time.get_ticks_msec() / 120.0
	var flash = (0.5 + 0.5 * sin(flash_phase)) * flash_speed * alarm_visual_progress
	flash = clamp(flash, 0.0, 1.0)
	var warning_color_lerp = Color(1.0, 1.0, 1.0).lerp(warning_color, flash)
	var effective_motion_strength = motion_strength * alarm_visual_progress

	time_container.position = time_container_base_position + Vector2(sin(wobble_phase * 3.0) * 5.0, cos(wobble_phase * 4.0) * 2.0) * effective_motion_strength
	time_container.rotation = time_container_base_rotation + sin(wobble_phase * 4.5) * 0.03 * effective_motion_strength
	time_container.scale = time_container_base_scale
	time_container.self_modulate = warning_color_lerp
	time_minutes_label.self_modulate = warning_color_lerp
	time_colon_label.self_modulate = warning_color_lerp
	time_seconds_label.self_modulate = warning_color_lerp

	score_container.position = score_container_base_position + Vector2(sin(wobble_phase * 2.2 + 1.4) * 3.0, cos(wobble_phase * 3.2 + 0.8) * 1.0) * effective_motion_strength
	score_container.rotation = score_container_base_rotation + sin(wobble_phase * 3.4 + 0.5) * 0.015 * effective_motion_strength
	score_container.scale = score_container_base_scale
	score_container.self_modulate = warning_color_lerp
	score_left_label.rotation = sin(wobble_phase * 5.2) * 0.02 * effective_motion_strength
	score_left_label.self_modulate = warning_color_lerp
	score_right_label.rotation = -sin(wobble_phase * 5.0 + 0.3) * 0.02 * effective_motion_strength
	score_right_label.self_modulate = warning_color_lerp

	var overlay_alpha = (0.08 + flash * 0.14) * alarm_visual_progress
	alarm_overlay.color = Color(1.0, 0.12, 0.12, overlay_alpha)


func get_animation_speed_factor() -> float:
	if current_game_time > alarm_threshold:
		return 0.0

	var alarm_window = max(1, alarm_threshold)
	var alarm_progress = 1.0 - clamp(float(current_game_time) / float(alarm_window), 0.0, 1.0)
	if alarm_progress <= 0.25:
		var first_segment = alarm_progress / 0.25
		first_segment = first_segment * first_segment * (3.0 - 2.0 * first_segment)
		return lerp(0.0, 0.6, first_segment)

	if alarm_progress <= 0.60:
		var second_segment = (alarm_progress - 0.25) / 0.35
		second_segment = second_segment * second_segment * (3.0 - 2.0 * second_segment)
		return lerp(0.6, 1.2, second_segment)

	return 1.2
