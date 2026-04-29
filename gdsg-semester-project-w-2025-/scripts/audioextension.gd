extends AudioStreamPlayer

var master_index = AudioServer.get_bus_index("Master")
var sounds_index = AudioServer.get_bus_index("Sounds")
var music_index = AudioServer.get_bus_index("Music")

func _ready():
	GameManager.sound_changed.connect(set_volume_percentage)
	set_volume_percentage()

func set_volume_percentage():
	set_volume(sounds_index, GameManager.sound_vol)
	set_volume(music_index, GameManager.music_vol)

func set_volume(bus_index, linear_volume):
	var db_value = linear_to_db(linear_volume / 100.0)
	AudioServer.set_bus_volume_db(bus_index, db_value)
