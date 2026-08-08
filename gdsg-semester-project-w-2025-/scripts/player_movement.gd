class_name Player
extends CharacterBody2D

const BASE_SPEED := 1100
var current_speed: float

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D
@onready var shadow_sprite: Sprite2D = $Shadow

@export var isP1: bool = false

@export var HIT_ANIMATION_DURATION = 0.1
@export var HIT_ANIMATION_SCALE = 0.1
@export var HIT_ANIMATION_ROTATION = 0.1

@export var MOVE_ANIMATION_SPEED = 10.0
@export var MOVE_ANIMATION_SCALE = 0.03
@export var MOVE_ANIMATION_ROTATION = 0.15

var paddle: Paddle
var fixed_x: float

var device_id_cur: int
var sprite_scale: Vector2

var up_pressed: bool = false
var down_pressed: bool = false

func _ready():
	if isP1:
		collision_shape.scale.x = -collision_shape.scale.x
		paddle = GameManager.left_player_paddle
	else:
		paddle = GameManager.right_player_paddle
	sprite.texture = paddle.sprite
	if paddle.custom_shape != null:
		collision_shape.shape = paddle.shape
	fixed_x = global_position.x
	sprite_scale = sprite.scale
	current_speed = BASE_SPEED

func hide_paddle(paddle_hidden: bool) -> void:
	sprite.visible = !paddle_hidden
	shadow_sprite.visible = !paddle_hidden
	collision_layer = 0 if paddle_hidden else 2

func _unhandled_input(event: InputEvent) -> void:
	if isP1:
		if event.is_action("downP1"):
			down_pressed = event.is_pressed()
		elif event.is_action("upP1"):
			up_pressed = event.is_pressed()
	else:
		if event.is_action("downP2"):
			down_pressed = event.is_pressed()
		elif event.is_action("upP2"):
			up_pressed = event.is_pressed()

func play_hit_animation():
	var tween_scale = create_tween()
	var offset = Vector2(HIT_ANIMATION_SCALE, -HIT_ANIMATION_SCALE)
	tween_scale.tween_property(sprite, "scale", sprite_scale + offset, HIT_ANIMATION_DURATION / 2)
	offset /= -2
	tween_scale.tween_property(sprite, "scale", sprite_scale + offset, HIT_ANIMATION_DURATION)
	tween_scale.tween_property(sprite, "scale", sprite_scale, HIT_ANIMATION_DURATION)
	
	var tween_rotation = create_tween()
	tween_rotation.tween_property(sprite, "rotation", -HIT_ANIMATION_ROTATION, HIT_ANIMATION_DURATION / 2)
	tween_rotation.tween_property(sprite, "rotation", HIT_ANIMATION_ROTATION, HIT_ANIMATION_DURATION)
	tween_rotation.tween_property(sprite, "rotation", 0, HIT_ANIMATION_DURATION)

func _play_move_animation(dir: Vector2, delta: float) -> void:
	var animation_delta = delta * MOVE_ANIMATION_SPEED
	
	var target_rotation = -dir.y * MOVE_ANIMATION_ROTATION
	sprite.rotation = lerp(sprite.rotation, target_rotation, animation_delta)

	var target_scale = sprite_scale
	target_scale.x += abs(dir.y) * MOVE_ANIMATION_SCALE
	target_scale.y -= abs(dir.y) * MOVE_ANIMATION_SCALE
	sprite.scale = sprite.scale.lerp(target_scale, animation_delta)

func _physics_process(delta: float) -> void:
	var dir: Vector2 = Vector2(0, float(down_pressed) - float(up_pressed))
	velocity = dir * current_speed
	move_and_slide()
	global_position.x = fixed_x
	_play_move_animation(dir, delta)

func scale_paddle(multiplier: float, duration: float = 5.0):
	collision_shape.scale *= multiplier
	shadow_sprite.scale *= multiplier
	
	await get_tree().create_timer(duration).timeout
	
	collision_shape.scale /= multiplier
	shadow_sprite.scale /= multiplier

func change_speed(multiplier: float, duration: float = 5.0):
	current_speed = multiplier
	
	await get_tree().create_timer(duration).timeout
	
	current_speed = BASE_SPEED
