extends CanvasLayer

@onready var buttons: HBoxContainer = $Control/NinePatchRect/TabContainer/Game/Buttons

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
