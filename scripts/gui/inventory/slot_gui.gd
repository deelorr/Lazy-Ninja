extends Button

@onready var background_sprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer
@onready var inventory = preload("res://resources/inventory/player_inventory.tres")

var item_stack_gui: ItemStackGUI
var index: int

"""Inserts an ItemStackGUI into this slot and updates the inventory accordingly."""
func insert_item_stack_gui(isg: ItemStackGUI):
	item_stack_gui = isg
	background_sprite.frame = 1
	container.add_child(item_stack_gui)

	# Ensure inventory matches the slot's contents
	if item_stack_gui.inventory_slot and inventory.slots[index] != item_stack_gui.inventory_slot:
		inventory.set_slot(index, item_stack_gui.inventory_slot)

"""Removes the item from this slot and returns it."""
func remove_item_from_slot() -> ItemStackGUI:
	var taken_item = item_stack_gui
	if taken_item:
		inventory.remove_slot_by_reference(taken_item.inventory_slot)
		clear_slot()
	return taken_item

"""Checks if this slot currently holds no item."""
func is_empty() -> bool:
	return item_stack_gui == null or item_stack_gui.inventory_slot.amount == 0

"""Clears this slot visually and logically."""
func clear_slot():
	if item_stack_gui:
		container.remove_child(item_stack_gui)
		item_stack_gui = null
	background_sprite.frame = 0
