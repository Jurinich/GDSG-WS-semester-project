extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer;
@onready var sound_player: SoundComponent = $SoundPlayer;

var master_index = AudioServer.get_bus_index("Master");
var sound_index = AudioServer.get_bus_index("Sounds");
var music_index = AudioServer.get_bus_index("Music");

func _ready() -> void:
	music_player.bus = "Music";
	music_player.play();

func playSound(sound_name: StringName) -> void:
	sound_player.playSound(sound_name);

func playMusic(music_name: StringName) -> void:
	music_player.get_stream_playback().switch_to_clip_by_name(music_name);

func set_master_volume(volume: float) -> void:
	AudioServer.set_bus_volume_linear(master_index, volume);

func set_sound_volume(volume: float) -> void:
	AudioServer.set_bus_volume_linear(sound_index, volume);

func set_music_volume(volume: float) -> void:
	AudioServer.set_bus_volume_linear(music_index, volume);

func mute_sound(mute: bool) -> void:
	AudioServer.set_bus_mute(sound_index, mute)

func mute_music(mute: bool) -> void:
	AudioServer.set_bus_mute(music_index, mute)

func get_master_volume() -> float:
	return AudioServer.get_bus_volume_linear(master_index);

func get_sound_volume() -> float:
	return AudioServer.get_bus_volume_linear(sound_index);

func get_music_volume() -> float:
	return AudioServer.get_bus_volume_linear(music_index);

func sound_muted() -> bool:
	return AudioServer.is_bus_mute(sound_index);

func music_muted() -> bool:
	return AudioServer.is_bus_mute(music_index);
