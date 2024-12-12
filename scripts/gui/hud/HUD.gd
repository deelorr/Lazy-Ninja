extends CanvasLayer

@onready var inventory = $InventoryGUI

func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.is_open:
			inventory.close()
			Global.resume_game()
		else:
			inventory.open()
			Global.pause_game()
