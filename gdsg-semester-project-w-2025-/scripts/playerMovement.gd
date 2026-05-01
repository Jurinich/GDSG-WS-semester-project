extends CharacterBody2D

const SPEED := 1000
@export var isP1: bool = false
@export var paddles: Array[PackedScene]

@export var HIT_ANIMATION_DURATION = 0.1
@export var HIT_ANIMATION_SCALE = 0.1
@export var HIT_ANIMATION_ROTATION = 0.1

var fixed_x: float
var arcade_input: float
var device_id_cur: int
var paddle: CollisionShape2D
var sprite: Sprite2D
var sprite_scale: Vector2

func _ready():
	fixed_x = global_position.x

	if (isP1):
		paddle = paddles[GameManager.left_player_paddle].instantiate()
		device_id_cur = GameManager.arcade_p1_id
		paddle.scale.x = -paddle.scale.x
	else:
		paddle = paddles[GameManager.right_player_paddle].instantiate()
		device_id_cur = GameManager.arcade_p2_id
	add_child(paddle)
	sprite = paddle.get_node("Sprite2D")
	sprite_scale = sprite.scale

func getYdir() -> float:
	if GameManager.arcade_mode:
		if Input.is_joy_button_pressed(device_id_cur, JOY_BUTTON_DPAD_UP):
			return -1.0
		elif Input.is_joy_button_pressed(device_id_cur, JOY_BUTTON_DPAD_DOWN):
			return 1.0
		else:
			return 0.0

	else:
		if isP1:
			return Input.get_action_strength("downP1") - Input.get_action_strength("upP1")
		else:
			return Input.get_action_strength("downP2") - Input.get_action_strength("upP2")

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

func _physics_process(_delta: float) -> void:
	var dir:Vector2=Vector2(0, getYdir())
	velocity = dir * SPEED
	move_and_slide()
	global_position.x = fixed_x
