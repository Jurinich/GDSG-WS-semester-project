@tool
# It is a tool script in order to have the textures updated in the editor.
# Engine.is_editor_hint() returns true if you are currently in the editor, 
# so things that should only be happening during the game must check that
# Engine.is_editor_hint() is false.
extends CharacterBody2D

const SPEED := 500
@export var playerTexture: Texture2D
@export var isP1: bool = false

func _process(delta) -> void:
	if Engine.is_editor_hint():
		$MeshInstance2D.texture = playerTexture
	
func _ready() -> void:
	if not Engine.is_editor_hint():
		$MeshInstance2D.texture = playerTexture

		
func getYdir() -> float:
	if isP1:
		return Input.get_action_strength("downP1") - Input.get_action_strength("upP1")
	else:
		return Input.get_action_strength("downP2") - Input.get_action_strength("upP2")

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint(): 
		var dir:Vector2=Vector2(0, getYdir())
		velocity = dir * SPEED
		move_and_slide()
