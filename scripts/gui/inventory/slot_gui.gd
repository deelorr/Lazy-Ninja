extends Button

@onready var background_sprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer
@onready var inventory = preload("res://resources/inventory/player_inventory.tres")

var items_stack_gui: ItemStackGUI
var index: int

func insert(isg: ItemStackGUI):
	items_stack_gui = isg
	background_sprite.frame = 1
	container.add_child(items_stack_gui)
	
	if !items_stack_gui.inventory_slot || inventory.slots[index] == items_stack_gui.inventory_slot:
		return
		
	inventory.insert_slot(index, items_stack_gui.inventory_slot)

func take_item():
	var item = items_stack_gui
	
	container.remove_child(items_stack_gui)
	items_stack_gui = null
	background_sprite.frame = 0
	
	return item

func is_empty():
	return !items_stack_gui
