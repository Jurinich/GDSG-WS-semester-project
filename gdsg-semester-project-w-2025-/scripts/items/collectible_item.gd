extends Area2D


class_name CollectibleItem
@onready var sprite : Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func setup(_item_data : ItemData):
	sprite.texture = _item_data.sprite
