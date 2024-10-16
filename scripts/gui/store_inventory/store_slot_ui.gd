extends Button

@onready var background_sprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer
@onready var inventory = preload("res://resources/inventory/store_inventory.tres")

var item_stack_gui: StoreItemStackGUI
var index: int

func insert(isg: StoreItemStackGUI):
	item_stack_gui = isg
	background_sprite.frame = 1
	container.add_child(item_stack_gui)
	
	if !item_stack_gui.inventory_slot || inventory.slots[index] == item_stack_gui.inventory_slot:
		return
		
	inventory.insert_slot(index, item_stack_gui.inventory_slot)

func take_item():
	var item = item_stack_gui
	
	inventory.remove_slot(item_stack_gui.inventory_slot)
	
	clear()
	
	return item

func is_empty():
	return item_stack_gui == null || item_stack_gui.inventory_slot.amount == 0

func clear():
	if item_stack_gui:
		container.remove_child(item_stack_gui)
		item_stack_gui = null
	background_sprite.frame = 0
