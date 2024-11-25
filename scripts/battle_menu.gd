extends VBoxContainer

signal attack_pressed
signal item_pressed
signal run_pressed

@onready var attack: Button = $Attack/Button
@onready var use_item: Button = $Item/Button
@onready var run: Button = $Run/Button

func enable_buttons():
	attack.disabled = false
	use_item.disabled = false
	run.disabled = false

func disable_buttons():
	attack.disabled = true
	use_item.disabled = true
	run.disabled = true

func _on_attack_button_pressed():
	attack_pressed.emit()

func _on_item_button_pressed():
	item_pressed.emit()

func _on_run_button_pressed():
	run_pressed.emit()
