class_name ScoreOverlay extends Control

@onready var timer: TextureRect = $Timer
@onready var minutes: Label = $Timer/Minutes
@onready var seconds: Label = $Timer/Seconds
@onready var colon: Label = $Timer/Colon
@onready var score_left: Label = $Score/ScoreLeft
@onready var score_right: Label = $Score/ScoreRight
@onready var alarm_overlay: ColorRect = $AlarmOverlay

@onready var timer_rotation: float = timer.rotation

@export var ALARM_COLOR: Color

@export var SCORE_ALARM_SPEED: float = 0.005
@export var SCORE_ALARM_SCALE: float = 0.1

@export var TIMER_ALARM_SPEED: float = 0.01
@export var TIMER_ALARM_ROTATION: float = 0.04

@export var ALARM_FLASH_SPEED: float = 0.005

@export var alarm_timer_threshold: int = 15
@export var alarm_score_threshold: int = 3

var score_alarm_threshold: int = -1
var time_alarm_threshold: int = -1
var alarm_visual_progress: float = 0.0

var time_alarm: bool = false
var score_alarm_left: bool = false
var score_alarm_right: bool = false

func _ready() -> void:
	GameManager.score_changed.connect(set_score)
	if GameManager.settings.gamemode == Settings.GameMode.SCORE:
		minutes.visible = false
		seconds.visible = false
		score_alarm_threshold = GameManager.settings.score - alarm_score_threshold
	elif GameManager.settings.gamemode == Settings.GameMode.TIME:
		time_alarm_threshold = alarm_timer_threshold

func _process(delta: float) -> void:
	if score_alarm_left || score_alarm_right || time_alarm:
		var smoothing_factor = clamp(delta * 2.0, 0.0, 1.0)
		alarm_visual_progress = lerp(alarm_visual_progress, 1.0, smoothing_factor)
		
		var alpha_delta = sin(Time.get_ticks_msec() * ALARM_FLASH_SPEED)
		alarm_overlay.color.a = (0.1 + alpha_delta * 0.1) * alarm_visual_progress
		
		if score_alarm_left:
			_animate_score(score_left)
		if score_alarm_right:
			_animate_score(score_right)
		if time_alarm:
			_animate_timer()

func _animate_score(label: Label) -> void:
	var delta = sin(Time.get_ticks_msec() * SCORE_ALARM_SPEED)
	label.scale = Vector2.ONE * (1 + (SCORE_ALARM_SCALE * delta * alarm_visual_progress))
	var weight = (1.0 - (0.4 * (delta * 0.5 + 0.5))) * alarm_visual_progress
	label.self_modulate = Color.WHITE.lerp(ALARM_COLOR, weight)

func _animate_timer() -> void:
	var delta = sin(Time.get_ticks_msec() * TIMER_ALARM_SPEED)
	timer.rotation = timer_rotation + (delta * TIMER_ALARM_ROTATION * alarm_visual_progress)
	var weight = (1.0 - (0.4 * (delta * 0.5 + 0.5))) * alarm_visual_progress
	var color = Color.WHITE.lerp(ALARM_COLOR, weight)
	minutes.self_modulate = color
	seconds.self_modulate = color
	colon.self_modulate = color

func set_time(time: int) -> void:
	@warning_ignore("integer_division")
	var minute = time / 60
	var second = time % 60
	minutes.text = str(minute)
	seconds.text = "%02d" % second
	colon.visible = !colon.visible
	time_alarm = time <= time_alarm_threshold

func set_score(left: int, right: int) -> void:
	if left > 99:
		score_left.add_theme_font_size_override("font_size", 40)
	score_left.text = str(left)
	if right > 99:
		score_right.add_theme_font_size_override("font_size", 40)
	score_right.text = str(right)
	score_alarm_left = score_alarm_threshold > 0 && left >= score_alarm_threshold
	score_alarm_right = score_alarm_threshold > 0 && right >= score_alarm_threshold
