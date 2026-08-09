extends Node

signal devices_updated(p1_device: int, p2_device: int)

const ECHO_DELAY: float = 0.2
const ECHO_INTERVAL: float = 0.04

var last_events: Dictionary = {}

var p1_device: int = InputEvent.DEVICE_ID_KEYBOARD
var p2_device: int = InputEvent.DEVICE_ID_KEYBOARD

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	for event in last_events.values():
		if event == null:
			continue
		
		event["timer"] -= delta
		if event["timer"] <= 0.0:
			event["timer"] = ECHO_INTERVAL
			var echo_event: InputEventKey = event["event"].duplicate()
			echo_event.echo = true
			Input.parse_input_event(echo_event)

func _input(event: InputEvent) -> void:
	if event.device in [InputEvent.DEVICE_ID_KEYBOARD, InputEvent.DEVICE_ID_MOUSE]:
		return
	get_viewport().set_input_as_handled()
	
	var key: String = str(event.device) + "."
	var fake_event: InputEventKey = InputEventKey.new()
	fake_event.device = InputEvent.DEVICE_ID_KEYBOARD
	fake_event.pressed = event.is_pressed()
	
	if !_is_device_connected(event.device):
		if event.is_action_pressed("connect_device"):
			_connect_new_device(event.device)
		return
	
	var p1 = event.device == p1_device
	
	if event is InputEventJoypadButton:
		key += "button." + str(event.button_index)
		fake_event.keycode = _get_button_keycode(event.button_index, p1)
	elif event is InputEventJoypadMotion:
		key += "motion." + str(event.axis)
		fake_event.keycode = _get_axis_keycode(event.axis, event.axis_value > 0.0, p1)
	
	if fake_event.keycode == KEY_NONE:
		return
	
	if event.is_pressed():
		_set_event(key, fake_event)
	else:
		_remove_event(key)

func _set_event(key: String, event: InputEventKey) -> void:
	if last_events.get(key) == null:
		last_events[key] = {"event": event, "timer": ECHO_DELAY}
		Input.parse_input_event(event)
		return
	last_events[key]["event"] = event

func _remove_event(key: String) -> void:
	var entry = last_events.get(key)
	if entry != null:
		var event: InputEventKey = entry["event"].duplicate()
		event.pressed = false
		Input.parse_input_event(event)
		last_events[key] = null

func _get_button_keycode(button_index: JoyButton, p1: bool) -> Key:
	match button_index:
		JOY_BUTTON_DPAD_LEFT: return KEY_A if p1 else KEY_LEFT
		JOY_BUTTON_DPAD_RIGHT: return KEY_D if p1 else KEY_RIGHT
		JOY_BUTTON_DPAD_UP: return KEY_W if p1 else KEY_UP
		JOY_BUTTON_DPAD_DOWN: return KEY_S if p1 else KEY_DOWN
		JOY_BUTTON_A: return KEY_SPACE
		JOY_BUTTON_B: return KEY_ESCAPE
	return Key.KEY_NONE

func _get_axis_keycode(axis: JoyAxis, positive: bool, p1: bool) -> Key:
	if axis == JOY_AXIS_LEFT_X:
		if positive:
			return KEY_D if p1 else KEY_RIGHT
		else:
			return KEY_A if p1 else KEY_LEFT
	if axis == JOY_AXIS_LEFT_Y:
		if positive:
			return KEY_S if p1 else KEY_DOWN
		else:
			return KEY_W if p1 else KEY_UP
	return Key.KEY_NONE

func _connect_new_device(device_id: int) -> void:
	if p1_device == InputEvent.DEVICE_ID_KEYBOARD:
		p1_device = device_id
		devices_updated.emit(p1_device, p2_device)
	elif p2_device == InputEvent.DEVICE_ID_KEYBOARD:
		p2_device = device_id
		devices_updated.emit(p1_device, p2_device)

func _is_device_connected(device_id: int) -> bool:
	return p1_device == device_id || p2_device == device_id

func swap_controllers() -> void:
	var temp = p1_device
	p1_device = p2_device
	p2_device = temp
	devices_updated.emit(p1_device, p2_device)
