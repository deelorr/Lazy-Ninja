extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var itemStackGUIClass = preload("res://scenes/gui/inventory/item_stack_gui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var item_in_hand: ItemStackGUI

func _ready():
	connect_slots()
	inventory.updated.connect(update)
	update()

func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if !inventorySlot.item:
			continue
		
		var itemStackGUI: ItemStackGUI = slots[i].items_stack_gui
		if !itemStackGUI:
			itemStackGUI = itemStackGUIClass.instantiate()
			slots[i].insert(itemStackGUI)
			
		itemStackGUI.inventory_slot = inventorySlot
		itemStackGUI.update()

func open():
	visible = true
	isOpen = true
	opened.emit()
	
func close():
	visible = false
	isOpen = false
	closed.emit()

func on_slot_clicked(slot):
	if slot.is_empty() && item_in_hand:
		insert_item_in_slot(slot)
		return
	if !item_in_hand:
		take_item_from_slot(slot)
	
func take_item_from_slot(slot):
	item_in_hand = slot.take_item()
	add_child(item_in_hand)
	update_item_in_hand()
	
func insert_item_in_slot(slot):
	var item = item_in_hand
	remove_child(item_in_hand)
	item_in_hand = null
	slot.insert(item)

func update_item_in_hand():
	if !item_in_hand:
		return
	item_in_hand.global_position = get_global_mouse_position() - item_in_hand.size / 2

func _input(event):
	update_item_in_hand()
	
		
		
