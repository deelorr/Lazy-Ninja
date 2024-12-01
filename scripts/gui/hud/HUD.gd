extends CanvasLayer

@onready var inventory = $InventoryGUI
@onready var battle_scene_resource = preload("res://scenes/maps/BattleScene.tscn")

func _ready():
	Global.connect("start_battle", Callable(self, "_open_battle_scene"))
	inventory.close()

func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()

func _open_battle_scene():
	get_tree().paused = true
	print("Opening battle scene")
	# Instance the battle scene
	var battle_instance = battle_scene_resource.instantiate()
	add_child(battle_instance)  # Add to the current node (CanvasLayer)
	
	# Create and start a Timer
	var timer = Timer.new()
	timer.wait_time = 4.0  # Wait for 4 seconds
	timer.one_shot = true
	add_child(timer)  # Add Timer to the current node
	timer.start()
	
	# Wait for the timer to finish
	await timer.timeout
	print("Closing battle scene")
	get_tree().paused = false
	
	# Remove battle scene and cleanup
	if is_instance_valid(battle_instance):
		battle_instance.queue_free()
	timer.queue_free()
