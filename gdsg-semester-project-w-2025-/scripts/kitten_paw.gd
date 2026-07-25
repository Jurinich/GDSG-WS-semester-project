class_name KittenPaw
extends Area2D

@export var MIN_SWING_SPEED: float = 0.25 
@export var MAX_SWING_SPEED: float = 0.55
@export var MIN_BOOST_POWER: float = 300.0
@export var MAX_BOOST_POWER: float = 600.0

@export var RETRACT_SPEED: float = 0.15
@export var SPRITE_ROTATION_FIX: float = 90.0

var target_ball: CharacterBody2D = null
var swing_direction: Vector2 = Vector2.ZERO
var current_boost_power: float = 0.0

var swing_duration: float = 0.0
var swing_start_time: int = 0
var attacking: bool = false

var hit_direction: Vector2
var hit_power: float

const ARENA_TOP_Y = 217.0
const ARENA_BOTTOM_Y = 1018.0 

func _ready():
	body_entered.connect(_on_body_entered)

func attack(ball_ref: CharacterBody2D):
	attacking = true
	target_ball = ball_ref
	
	var actual_swing_speed = randf_range(MIN_SWING_SPEED, MAX_SWING_SPEED)
	swing_duration = actual_swing_speed
	swing_start_time = Time.get_ticks_msec()
	var weight = inverse_lerp(MAX_SWING_SPEED, MIN_SWING_SPEED, actual_swing_speed)
	current_boost_power = lerp(MIN_BOOST_POWER, MAX_BOOST_POWER, weight)
	
	var is_top_attack = target_ball.global_position.y < 617
	var hide_y_pos = 0.0
	if is_top_attack:
		hide_y_pos = ARENA_TOP_Y - 150 
	else:
		hide_y_pos = ARENA_BOTTOM_Y + 150 
	
	var spawn_x = target_ball.global_position.x
	global_position = Vector2(spawn_x, hide_y_pos) 
	
	var future_pos = target_ball.global_position + (target_ball.velocity * actual_swing_speed * 0.9)
	future_pos.x = clamp(future_pos.x, 150, 1770) 
	future_pos.y = clamp(future_pos.y, ARENA_TOP_Y, ARENA_BOTTOM_Y)
	var destination = future_pos
	
	var random_swing = randf() > 0.5
	var is_spawning_on_right = spawn_x > destination.x
	var start_deg = 0.0
	var end_deg = 0.0
	
	if is_top_attack:
		if is_spawning_on_right:
			start_deg = 45 if !random_swing else 135
			end_deg = 135 if !random_swing else 45
		else:
			start_deg = 135 if !random_swing else 45
			end_deg = 45 if !random_swing else 135
	else:
		if is_spawning_on_right:
			start_deg = -45 if !random_swing else -135
			end_deg = -135 if !random_swing else -45
		else:
			start_deg = -135 if !random_swing else -45
			end_deg = -45 if !random_swing else -135

	start_deg += SPRITE_ROTATION_FIX
	end_deg += SPRITE_ROTATION_FIX
	
	rotation_degrees = start_deg
	swing_direction = Vector2.from_angle(deg_to_rad(end_deg - SPRITE_ROTATION_FIX))
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", destination, actual_swing_speed)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", end_deg, actual_swing_speed)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_property(self, "global_position", Vector2(spawn_x, hide_y_pos), RETRACT_SPEED)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(0.1)
	tween.chain().tween_callback(queue_free)

func compute_hit_power():
	hit_direction = swing_direction
	var time_elapsed_sec = (Time.get_ticks_msec() - swing_start_time) / 1000.0
	
	if time_elapsed_sec >= (swing_duration * 0.9):
		hit_power = current_boost_power * 0.1
	else:
		hit_power = current_boost_power
	
	var is_top_attack = global_position.y < 617 
	if is_top_attack:
		if hit_direction.y < 0: hit_direction.y = 0.5 
	else:
		if hit_direction.y > 0: hit_direction.y = -0.5 

func _on_body_entered(body):
	if attacking:
		if body == target_ball:
			compute_hit_power()
			body.paw_hit(hit_direction, hit_power)
	elif body.has_method("paw_hit"):
		if hit_power != 0 && hit_direction.length() > 0:
			body.paw_hit(hit_direction, hit_power)
