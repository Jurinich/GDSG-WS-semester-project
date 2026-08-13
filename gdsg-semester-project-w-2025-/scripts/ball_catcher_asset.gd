class_name VacuumCleaner extends Area2D

@onready var air_sprite: Sprite2D = $Air
@onready var air_material: ShaderMaterial = $Air.material
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

const TRANSITION_TIME = 0.4

var caught_balls: Array[Ball] = []
var is_shooting: bool = false
var paddle_owner: CharacterBody2D
var shoot_direction: Vector2 = Vector2.RIGHT

var collection_timer: Timer
var shoot_timer: Timer

var active: bool = false
var shake_strength: float = 0.0
var inactive_position: Vector2 = Vector2(-200, 0)

@export var catch_time : float = 5.0
@export var shoot_delay : float = 0.25
@export var shoot_angle : float = 10.0

@export var sounds : SoundResource

func _ready() -> void:
	if paddle_owner and not paddle_owner.isP1:
		shoot_direction = Vector2.LEFT
		inactive_position *= -1

	position = inactive_position
	
	collection_timer = Timer.new()
	collection_timer.wait_time = catch_time
	collection_timer.one_shot = true
	collection_timer.timeout.connect(_on_collection_timeout)
	add_child(collection_timer)
	collection_timer.start()

	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(_on_shoot_tick)
	add_child(shoot_timer)

	body_entered.connect(_on_body_entered)
	
	_play_spawn_animation()

func _process(_delta) -> void:
	if !active:
		return
	var offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	offset *= 2 * shake_strength if is_shooting else shake_strength
	position = offset

func _on_body_entered(body: Node2D) -> void:
	if is_shooting: return
	if body is Ball:
		catch_ball(body)

func catch_ball(ball: Ball) -> void:
	_play_collect_animation()
	
	caught_balls.append(ball)
	ball.set_physics_process(false)
	ball.visible = false
	ball.collision_shape.set_deferred("disabled", true)
	ball.velocity = Vector2.ZERO
	if caught_balls.size() == get_tree().get_node_count_in_group("balls"):
		var remaining_time = min(collection_timer.time_left, 0.5)
		collection_timer.stop()
		collection_timer.start(remaining_time)

func set_shader_value(value: Variant, property: StringName) -> void:
	air_material.set_shader_parameter(property, value);

func _on_collection_timeout() -> void:
	_play_turn_off_animation().tween_callback(_start_shooting)

func _start_shooting() -> void:
	if caught_balls.is_empty():
		_play_despawn_animation().tween_callback(queue_free)
		return
	
	is_shooting = true
	_play_shooting_animation().tween_callback(shoot_timer.start)

func _on_shoot_tick() -> void:
	if caught_balls.is_empty():
		shoot_timer.stop()
		_on_collection_timeout()
		return
	
	var ball = caught_balls.pop_front()
	shoot_ball(ball)

func shoot_ball(ball: Ball) -> void:
	_play_collect_animation()
	AudioManager.playSound(&"Canon")
	
	ball.visible = true
	ball.collision_shape.set_deferred("disabled", false)
	ball.set_physics_process(true)
	
	ball.global_position = global_position 
	
	var spread_rad = deg_to_rad(randf_range(-shoot_angle, shoot_angle))
	var final_dir = shoot_direction.rotated(spread_rad)
	
	ball.velocity = final_dir * ball.BASE_SPEED
	ball.current_speed = ball.BASE_SPEED
	ball.last_hit_by = paddle_owner

func _play_turn_off_animation() -> Tween:
	var tween = create_tween()
	tween.tween_callback(_play_stop_sound)
	tween.tween_method(set_shader_value.bind(&"line_color"), Color.WHITE, Color.TRANSPARENT, TRANSITION_TIME)
	tween.parallel().tween_property(self, "shake_strength", 0.0, TRANSITION_TIME)
	return tween

func _play_spawn_animation() -> void:
	var tween = create_tween()
	tween.tween_callback(_play_start_sound)
	tween.tween_property(self, "position", Vector2.ZERO, 0.1)
	tween.tween_callback(get_parent().hide_paddle.bind(true))
	tween.tween_property(self, "active", true, 0.0)
	tween.tween_method(set_shader_value.bind(&"line_color"), Color.TRANSPARENT, Color.WHITE, 1.0)
	tween.parallel().tween_property(self, "shake_strength", 2.0, 1.0)

func _play_despawn_animation() -> Tween:
	var tween = create_tween()
	tween.tween_property(self, "active", false, 0.0)
	tween.tween_callback(get_parent().hide_paddle.bind(false))
	tween.tween_property(self, "position", inactive_position, 0.1)
	return tween

func _play_shooting_animation() -> Tween:
	audio_player.pitch_scale = 1.5
	var tween = create_tween()
	tween.tween_callback(_play_start_sound)
	tween.tween_method(set_shader_value.bind(&"line_color"), Color.TRANSPARENT, Color.WHITE, TRANSITION_TIME)
	tween.parallel().tween_method(set_shader_value.bind(&"speed"), -25.0, -35.0, TRANSITION_TIME)
	tween.parallel().tween_property(self, "shake_strength", 2.0, TRANSITION_TIME)
	return tween

func _play_collect_animation() -> void:
	var original_scale = scale
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * 1.1, 0.05)
	tween.tween_property(self, "scale", original_scale, 0.1)

func _play_sound(index: int) -> void:
	audio_player.stream = sounds.audiostreams[index]
	audio_player.play()

func _play_start_sound() -> void:
	var tween = create_tween()
	tween.tween_callback(_play_sound.bind(0))
	tween.tween_await(audio_player.finished)
	tween.tween_callback(_play_sound.bind(1))
	
func _play_stop_sound() -> void:
	_play_sound(2)
