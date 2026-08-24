extends Node2D

@onready var path: Path2D = $"Path"
@onready var dot: PathFollow2D = $"Path/Dot"
@onready var dot_sprite: Sprite2D = $"Path/Dot/Sprite"
@onready var kitty: PathFollow2D = $"Path/Kitty"
@onready var paw: KittenPaw = $"Path/Kitty/PawWrapper/Paw"
@onready var paw_wrapper: Node2D = $"Path/Kitty/PawWrapper"
@onready var sprite: Sprite2D = $"Sprite"
@onready var effects: EffectTimerManager = $"../ForegroundUILayer/EffectTimers"

@export var paths: Array[Curve2D]

@export var PAW_SPEED_MIN: float = 0.9
@export var PAW_SPEED_MAX: float = 1.4
@export var PAW_ROTATION_MIN: float = -0.4
@export var PAW_ROTATION_MAX: float = 0.5
@export var PAW_ROTATION_DURATION: float = 0.3
@export var PAW_HIDE_DURATION: float = 0.5
@export var PAW_TIMER_MIN: float = 0.2
@export var PAW_TIMER_MAX: float = 0.4

@export var POINTER_OFFSET: Vector2 = Vector2(400, 20)
@export var SPEED: float = 900
@export var SPAWN_DURATION: float = 0.3
@export var ROTATION_DURATION: float = 0.5

var kitty_speed_modifier: float = 1.0
var speed_timer: float = 0
var paw_rotation: float = 0
var laser_on: bool = false
var path_counter: int
var flip: bool = true

var pointer_position: Vector2 = POINTER_OFFSET
var pointer_hidden_óffset: Vector2 = Vector2(0, -300)

const ARENA_CENTER_X = 960
const ARENA_CENTER_Y = 540

var game_start_ignore_laser_sound: bool = true


func _ready() -> void:
	add_to_group("laser_pointer")
	turn_off_laser()

func activate(counter: int, right_player: bool) -> void:
	if path_counter <= 0:
		flip = right_player
		paw_wrapper.scale.x = -1 if flip else 1
		pointer_position = flip_point(POINTER_OFFSET) if flip else POINTER_OFFSET
		sprite.position = pointer_position + pointer_hidden_óffset
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(sprite, "position", pointer_position, SPAWN_DURATION)
		tween.tween_callback(start_next_path)
	path_counter = counter
	effects.show_effect_counter("LASER POINTER", path_counter, counter)

func deactivate() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	var hide_position = pointer_position + pointer_hidden_óffset
	tween.tween_property(sprite, "position", hide_position, SPAWN_DURATION)

func flip_point(vector: Vector2) -> Vector2:
	return Vector2(2.0 * ARENA_CENTER_X - vector.x, vector.y)

func flip_curve(curve: Curve2D) -> Curve2D:
	var new_curve = Curve2D.new()
	
	for i in range(curve.point_count):
		var pos = flip_point(curve.get_point_position(i))
		var in_handle = -1 * curve.get_point_in(i)
		var out_handle = -1 * curve.get_point_out(i)
		new_curve.add_point(pos, in_handle, out_handle)
	
	return new_curve

func hide_paw() -> void:
	paw.hit_power = 0
	var hide_y = 1.5 * ARENA_CENTER_Y
	if paw_wrapper.global_position.y < ARENA_CENTER_Y:
		hide_y *= -1.5
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(paw_wrapper, "position:y", hide_y, PAW_HIDE_DURATION)
	tween.tween_callback(start_next_path)

func start_next_path() -> void:
	effects.show_effect_counter("LASER POINTER", path_counter)
	if path_counter <= 0:
		deactivate()
	else:
		path_counter = path_counter - 1
		path.curve = paths.pick_random()
		if flip:
			path.curve = flip_curve(path.curve)
		kitty.progress = 0
		dot.progress = 0
		var hidden_y = 1.5 * ARENA_CENTER_Y
		if path.curve.get_point_position(0).y < ARENA_CENTER_Y:
			hidden_y *= -1.5
		paw_wrapper.position.y = hidden_y
		var direction = dot.global_position - sprite.global_position
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(sprite, "rotation", direction.angle(), ROTATION_DURATION)
		tween.tween_callback(turn_on_laser)
		tween.tween_property(paw_wrapper, "position:y", 0, PAW_HIDE_DURATION)

func turn_on_laser():
	AudioManager.playSound("laser_click");
	laser_on = true
	dot_sprite.show()

func turn_off_laser():
	if(!game_start_ignore_laser_sound):
		AudioManager.playSound("laser_click");
		game_start_ignore_laser_sound = false
	laser_on = false
	dot_sprite.hide()

func update_paw(delta: float) -> void:
	speed_timer = speed_timer - delta
	if speed_timer <= 0:
		speed_timer = randf_range(PAW_TIMER_MIN, PAW_TIMER_MAX)
		randomize_paw()
	var last_position = kitty.position
	if paw_wrapper.position.length() == 0:
		kitty.progress += (delta * SPEED * kitty_speed_modifier)
		if kitty.progress > dot.progress:
			kitty.progress = dot.progress
	paw.hit_direction = kitty.position - last_position

func randomize_paw() -> void:
	kitty_speed_modifier = randf_range(PAW_SPEED_MIN, PAW_SPEED_MAX)
	var weight = inverse_lerp(PAW_SPEED_MIN, PAW_SPEED_MAX, kitty_speed_modifier)
	paw.hit_power = lerp(paw.MIN_BOOST_POWER, paw.MAX_BOOST_POWER, weight)
	paw_rotation = randf_range(PAW_ROTATION_MIN, PAW_ROTATION_MAX)
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(kitty, "rotation", paw_rotation, PAW_ROTATION_DURATION)

func update_laser(delta: float) -> void:
	sprite.look_at(dot.global_position)
	dot.progress += (delta * SPEED)

func _process(delta: float) -> void:
	if laser_on:
		update_paw(delta)
		update_laser(delta)
		if kitty.progress_ratio >= 1:
			turn_off_laser()
			hide_paw()
