extends VBoxContainer

signal attack_pressed
signal item_pressed
signal run_pressed

@onready var attack_button: Button = $Attack/Button
@onready var item_button: Button = $Item/Button
@onready var run_button: Button = $Run/Button

func enable_buttons():
	attack_button.disabled = false
	item_button.disabled = false
	run_button.disabled = false

func disable_buttons():
	attack_button.disabled = true
	item_button.disabled = true
	run_button.disabled = true

func _on_attack_button_pressed():
	attack_pressed.emit()

func _on_item_button_pressed():
	item_pressed.emit()

func _on_run_button_pressed():
	run_pressed.emit()
