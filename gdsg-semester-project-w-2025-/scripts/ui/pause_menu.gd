class_name PauseMenu extends Control

@onready var sound_slider: HSlider = $content/HBoxContainer2/HSlider;
@onready var music_slider: HSlider = $content/HBoxContainer/HSlider;
@onready var sound_button: Button = $content/Button;
@onready var music_button: Button = $content/Button2;
@onready var quit_button: Button = $content/QuitButton;
@onready var continue_button: Button = $content/ContinueButton;

func _ready():
	quit_button.pressed.connect(_on_quit_button_pressed);
	continue_button.pressed.connect(_on_continue);
	sound_button.pressed.connect(sound_button_pressed);
	music_button.pressed.connect(music_button_pressed);
	sound_slider.value_changed.connect(AudioManager.set_sound_volume)
	music_slider.value_changed.connect(AudioManager.set_music_volume)
	_set_focus_sound([sound_slider, music_slider, sound_button, music_button, continue_button, quit_button])
	_init_sound()

func show_menu() -> void:
	AudioManager.playSound("pause_menu")
	get_tree().paused = true
	show()
	continue_button.grab_focus()
	print(get_viewport().gui_get_focus_owner())

func _set_focus_sound(elements: Array[Control]) -> void:
	for element in elements:
		element.focus_entered.connect(AudioManager.playSound.bind(&"menu_hover"))

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_continue():
	get_tree().paused = false;
	hide();

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		AudioManager.playSound("pause_menu")
		_on_continue();
		get_viewport().set_input_as_handled();

func sound_button_pressed():
	AudioManager.mute_sound(!AudioManager.sound_muted())
	_update_sound_button()

func music_button_pressed():
	AudioManager.mute_music(!AudioManager.music_muted())
	_update_music_buttons()

func _init_sound():
	_update_sound_button()
	_update_music_buttons()
	sound_slider.value = AudioManager.get_sound_volume();
	music_slider.value = AudioManager.get_music_volume();

func _update_music_buttons() -> void:
	var music_muted = AudioManager.music_muted()
	music_button.text = "Music: " + ("Off" if music_muted else "On")
	music_slider.editable = !music_muted
	music_slider.focus_mode = Control.FOCUS_NONE if music_muted else Control.FOCUS_ALL

func _update_sound_button() -> void:
	var sound_muted = AudioManager.sound_muted()
	sound_button.text = "Sound: " + ("Off" if sound_muted else "On")
	sound_slider.editable = !sound_muted
	sound_slider.focus_mode = Control.FOCUS_NONE if sound_muted else Control.FOCUS_ALL
