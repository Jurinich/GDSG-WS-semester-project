extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer;
@onready var sound_player: SoundComponent = $SoundPlayer;

func _ready() -> void:
	music_player.bus = "Music";
	music_player.play();


func playSound(sound_name: StringName) -> void:
	sound_player.playSound(sound_name);


func playMusic(music_name: StringName) -> void:
	music_player.get_stream_playback().switch_to_clip_by_name(music_name);
