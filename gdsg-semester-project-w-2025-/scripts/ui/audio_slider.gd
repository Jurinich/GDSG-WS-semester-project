@tool
class_name AudioSlider extends VBoxContainer

@onready var label: Label = $LabelContainer/Label
@onready var slider: CustomSlider = $SliderContainer/Slider
@onready var mute_menu: LoopingSelection = $LabelContainer/LoopingSelection
@onready var icon: AtlasTexture = $SliderContainer/Icon.texture

@export var bus: AudioManager.Bus = AudioManager.Bus.SOUND:
	set(value):
		bus = value
		if is_node_ready():
			_update_label()

func _ready() -> void:
	if Engine.is_editor_hint():
		await ready
		_update_label()
		return
	slider.slider.value = AudioManager.get_volume(bus)
	mute_menu.select_value(AudioManager.is_mute(bus))
	mute_menu.value_changed.connect(_on_mute)
	mute_menu.focus_entered.connect(_on_focus_entered)
	mute_menu.focus_exited.connect(_on_focus_exited)
	slider.focus_entered.connect(AudioManager.playSound.bind(&"menu_hover"))
	slider.slider.value_changed.connect(_on_slider_changed)
	_update_label()
	_update()

func _update_label() -> void:
	match bus:
		AudioManager.Bus.MASTER: label.text = "Master:"
		AudioManager.Bus.MUSIC: label.text = "Music:"
		AudioManager.Bus.SOUND: label.text = "Sound:"

func _on_focus_entered() -> void:
	mute_menu.custom_minimum_size = Vector2(150.0, 0.0)

func _on_focus_exited() -> void:
	mute_menu.custom_minimum_size = Vector2(100.0, 0.0)

func _update() -> void:
	var music_muted = AudioManager.is_mute(bus)
	slider.slider.editable = !music_muted
	slider.focus_mode = Control.FOCUS_NONE if music_muted else Control.FOCUS_ALL
	var volume = AudioManager.get_volume(bus)
	if volume > 1.5:
		icon.region.position.x = 0
	elif volume > 0.5:
		icon.region.position.x = 128
	elif volume > 0.0:
		icon.region.position.x = 256
	else:
		icon.region.position.x = 384

func _on_mute(value: bool) -> void:
	AudioManager.mute(bus, value)
	_update()

func _on_slider_changed(value: float) -> void:
	AudioManager.set_volume(bus, value)
	_update()
