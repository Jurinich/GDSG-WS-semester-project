extends Control

@onready var sound_slider: HSlider = $content/HBoxContainer2/HSlider
@onready var music_slider: HSlider = $content/HBoxContainer/HSlider
@onready var sound_button: Button = $content/Button
@onready var music_button: Button = $content/Button2

func _ready():
	init_music()
	init_sound()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func sound_button_pressed():
	if GameManager.sound_vol == 0:
		GameManager.change_sound(100)
		sound_slider.editable = true
		sound_button.text = "Sound: On"
	else:
		GameManager.change_sound(0)
		sound_slider.editable = false
		sound_button.text = "Sound: Off"

func music_button_pressed():
	if GameManager.music_vol == 0:
		GameManager.change_music(100)
		music_slider.editable = true
		music_button.text = "Music: On"
	else:
		GameManager.change_music(0)
		music_slider.editable = false
		music_button.text = "Music: Off"

func on_sound_slider_drag_end(_unused):
	GameManager.change_sound(int(sound_slider.value))

func on_music_slider_drag_end(_unused):
	GameManager.change_music(int(music_slider.value))

func init_music():
	if (GameManager.music_vol <= 0):
		music_slider.editable = false
		music_button.text = "Music: Off"
		return
	music_slider.value = GameManager.music_vol

func init_sound():
	if (GameManager.sound_vol <= 0):
		sound_slider.editable = false
		sound_button.text = "Sound: Off"
		return
	sound_slider.value = GameManager.sound_vol
