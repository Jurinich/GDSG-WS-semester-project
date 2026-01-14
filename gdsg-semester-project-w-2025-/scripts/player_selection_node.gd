class_name PlayerSelectionNode
extends Control

@onready var left_button = $"VBoxContainer/HBoxContainer/LeftButton"
@onready var right_button = $"VBoxContainer/HBoxContainer/RightButton"
@onready var select_button = $"VBoxContainer/SelectButton"

signal ready_changed

var player_ready: bool = false


func _on_select_button_pressed():
	player_ready = !player_ready
	if (player_ready):
		select_button.text = "Ready"
		right_button.disabled = true
		left_button.disabled = true
	else:
		select_button.text = "Select"
		right_button.disabled = false
		left_button.disabled = false

	ready_changed.emit()


func _on_right_button_pressed():
	if player_ready == true:
		player_ready = false
		ready_changed.emit()

	print("player changed right (no effect yet)")


func _on_left_button_pressed():
	if player_ready == true:
		player_ready = false
		ready_changed.emit()

	print("player changed left (no effect yet)")
