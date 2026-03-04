extends AudioStreamPlayer

func _ready():
	GameManager.sound_changed.connect(set_volume_percentage)
	set_volume_percentage()


func set_volume_percentage():
	var linear_value = GameManager.sound_vol / 100.0
	var db_value = linear_to_db(linear_value)
	volume_db = db_value