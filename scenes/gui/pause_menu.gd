extends CanvasLayer

signal zoom_changed(value)

@onready var buttons: HBoxContainer = $Control/NinePatchRect/TabContainer/Game/Buttons
@onready var zoom_slider = $Control/NinePatchRect/TabContainer/Settings/ZoomSlider

var is_paused = false

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	if is_paused:
		Global.pause_game()
		visible = true
		buttons.get_node("Resume").grab_focus()
	else:
		Global.resume_game()
		visible = false

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	get_tree().quit()

func _on_zoom_slider_value_changed(value):
	zoom_changed.emit(value)
