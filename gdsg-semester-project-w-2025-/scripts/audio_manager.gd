extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer;
@onready var sound_player: SoundComponent = $SoundPlayer;

var master_index = AudioServer.get_bus_index("Master");
var sound_index = AudioServer.get_bus_index("Sounds");
var music_index = AudioServer.get_bus_index("Music");

enum Bus {MASTER, SOUND, MUSIC}

func _ready() -> void:
	music_player.bus = "Music";
	music_player.play();

func playSound(sound_name: StringName) -> void:
	sound_player.playSound(sound_name);

func playMusic(music_name: StringName) -> void:
	music_player.get_stream_playback().switch_to_clip_by_name(music_name);

func set_volume(bus: Bus, volume: float) -> void:
	AudioServer.set_bus_volume_linear(_get_index(bus), volume);

func mute(bus: Bus, muted: bool) -> void:
	AudioServer.set_bus_mute(_get_index(bus), muted)

func get_volume(bus: Bus) -> float:
	return AudioServer.get_bus_volume_linear(_get_index(bus));

func is_mute(bus: Bus) -> bool:
	return AudioServer.is_bus_mute(_get_index(bus));

func _get_index(bus: Bus) -> int:
	match bus:
		Bus.MASTER: return master_index
		Bus.SOUND: return sound_index
		Bus.MUSIC: return music_index
	return -1
