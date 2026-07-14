extends Control

@onready var sound_slider: HSlider = $content/HBoxContainer2/HSlider;
@onready var music_slider: HSlider = $content/HBoxContainer/HSlider;
@onready var sound_button: Button = $content/Button;
@onready var music_button: Button = $content/Button2;
@onready var quit_button: Button = $content/QuitButton;
@onready var continue_button: Button = $content/ContinueButton;

func _ready():
	init_music()
	init_sound()
	quit_button.pressed.connect(_on_quit_button_pressed);
	continue_button.pressed.connect(_on_continue);
	sound_button.pressed.connect(sound_button_pressed);
	music_button.pressed.connect(music_button_pressed);
	sound_slider.drag_ended.connect(on_sound_slider_drag_end);
	music_slider.drag_ended.connect(on_music_slider_drag_end);

func _on_quit_button_pressed():
	get_tree().paused = false;
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn");

func _on_continue():
	get_tree().paused = false;
	AudioManager.playSound("pause_menu")
	hide();

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		_on_continue();
		get_viewport().set_input_as_handled();

func sound_button_pressed():
	if AudioManager.sound_muted():
		AudioManager.set_sound_volume(1.0);
		sound_slider.editable = true;
		sound_button.text = "Sound: On";
	else:
		AudioManager.set_sound_volume(0.0);
		sound_slider.editable = false;
		sound_button.text = "Sound: Off";

func music_button_pressed():
	if AudioManager.music_muted():
		AudioManager.set_music_volume(1.0);
		music_slider.editable = true;
		music_button.text = "Music: On";
	else:
		AudioManager.set_music_volume(0.0);
		music_slider.editable = false;
		music_button.text = "Music: Off";

func on_sound_slider_drag_end(_unused):
	AudioManager.set_sound_volume(sound_slider.value);

func on_music_slider_drag_end(_unused):
	AudioManager.set_music_volume(music_slider.value);

func init_music():
	if (AudioManager.get_music_volume() <= 0):
		music_slider.editable = false;
		music_button.text = "Music: Off";
		return;
	music_slider.value = AudioManager.get_music_volume();

func init_sound():
	if (AudioManager.get_sound_volume() <= 0):
		sound_slider.editable = false;
		sound_button.text = "Sound: Off";
		return;
	sound_slider.value = AudioManager.get_sound_volume();
