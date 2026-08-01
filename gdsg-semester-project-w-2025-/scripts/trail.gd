class_name Trail extends Line2D

@export var max_points: int = 15
@export var update_time: float = 0.02
@export var ball_radius: float = 25.0

var time_until_update: float = 0.0

func _process(delta: float) -> void:
	time_until_update -= delta
	if time_until_update <= 0.0:
		time_until_update = update_time
		update_path()

func update_path() -> void:
	add_point(get_parent().global_position)
	if points.size() > max_points:
		remove_point(0)
