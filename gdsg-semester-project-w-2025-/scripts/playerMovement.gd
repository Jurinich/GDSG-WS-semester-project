extends CharacterBody2D

const SPEED := 1000
@export var isP1: bool = false
@export var paddles: Array[PackedScene]

var fixed_x: float
var arcade_input: float
var device_id_cur: int

func _ready():
	fixed_x = global_position.x

	var paddle: CollisionShape2D
	if (isP1):
		paddle = paddles[GameManager.left_player_paddle].instantiate()
		device_id_cur = GameManager.arcade_p1_id
		paddle.scale.x = -paddle.scale.x
	else:
		paddle = paddles[GameManager.right_player_paddle].instantiate()
		device_id_cur = GameManager.arcade_p2_id

	add_child(paddle)

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

func _physics_process(_delta: float) -> void:
	var dir:Vector2=Vector2(0, getYdir())
	velocity = dir * SPEED
	move_and_slide()
	global_position.x = fixed_x
