extends CharacterBody2D

const SPEED := 1000
@export var isP1: bool = false
@export var paddles: Array[PackedScene]

var fixed_x: float


func _ready():
	fixed_x = global_position.x
	
	var paddle: CollisionPolygon2D
	if (isP1):
		paddle = paddles[GameManager.left_player_paddle].instantiate()
	else:
		paddle = paddles[GameManager.right_player_paddle].instantiate()
		paddle.scale.x = -paddle.scale.x

	add_child(paddle)

func getYdir() -> float:
	if isP1:
		return Input.get_action_strength("downP1") - Input.get_action_strength("upP1")
	else:
		return Input.get_action_strength("downP2") - Input.get_action_strength("upP2")

func _physics_process(_delta: float) -> void:
	var dir:Vector2=Vector2(0, getYdir())
	velocity = dir * SPEED
	move_and_slide()
	global_position.x = fixed_x
