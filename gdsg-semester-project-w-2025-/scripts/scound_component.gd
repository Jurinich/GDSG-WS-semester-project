class_name SoundComponent
extends Node

@export var sounds: Array[SoundResource]
@export var audio_player_amount: int = 1;

var audio_player_pool: Array[AudioStreamPlayer];

func _ready() -> void:
	for i in range(audio_player_amount):
		var audio_player = AudioStreamPlayer.new();
		audio_player.bus = "Sounds";
		add_child(audio_player);
		audio_player_pool.push_back(audio_player);

func playSound(sound_name: StringName) -> void:
	var foundSoundResource = _findSoundResource(sound_name);
	if foundSoundResource == null:
		print("Resource with name: " + sound_name + "not found!");
		return;
	
	var foundAudioPlayer: AudioStreamPlayer = _findAvailablePlayer()
	if foundAudioPlayer == null:
		return;
	
	foundAudioPlayer.stream = foundSoundResource.audiostreams.pick_random();
	foundAudioPlayer.play();


func _findSoundResource(sound_name: StringName) -> SoundResource:
	for resource in sounds:
		if resource.name == sound_name:
			return resource;
	return null;


func _findAvailablePlayer() -> AudioStreamPlayer:
	for player in audio_player_pool:
		if !player.playing:
			return player;
	return null;
