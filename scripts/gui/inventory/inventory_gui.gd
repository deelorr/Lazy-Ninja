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
	#for i in range(slots.size()):
		#var slot = slots[i]
		#slot.index = i
		#
		#var callable = Callable(on_slot_clicked)
		#callable = callable.bind(slot)
		#slot.pressed.connect(callable)
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(self, "on_slot_clicked").bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if !inventorySlot.item:
			continue
		
		var itemStackGUI: ItemStackGUI = slots[i].item_stack_gui
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
	if slot.is_empty():
		if !item_in_hand:
			return
		insert_item_in_slot(slot)
		return
		
	if !item_in_hand:
		take_item_from_slot(slot)
		return
		
	if slot.item_stack_gui.inventory_slot.item.name == item_in_hand.inventory_slot.item.name:
		stack_items(slot)
		return
	
	swap_item(slot)
	
func take_item_from_slot(slot):
	item_in_hand = slot.take_item()
	add_child(item_in_hand)
	update_item_in_hand()
	
func insert_item_in_slot(slot):
	var item = item_in_hand
	remove_child(item_in_hand)
	item_in_hand = null
	slot.insert(item)
	
func swap_item(slot):
	var temp_item = slot.take_item()
	
	insert_item_in_slot(slot)
	
	item_in_hand = temp_item
	add_child(item_in_hand)
	update_item_in_hand()
	
func stack_items(slot):
	var slot_item: ItemStackGUI = slot.item_stack_gui
	var max_amount = slot_item.inventory_slot.item.max_per_stack
	var total_amount = slot_item.inventory_slot.amount + item_in_hand.inventory_slot.amount
	
	if slot_item.inventory_slot.amount == max_amount:
		swap_item(slot)
		return
		
	if total_amount <= max_amount:
		slot_item.inventory_slot.amount = total_amount
		remove_child(item_in_hand)
		item_in_hand = null
	
	else:
		slot_item.inventory_slot.amount = max_amount
		item_in_hand.inventory_slot.amount = total_amount - max_amount
	
	slot_item.update()
	if item_in_hand:
			item_in_hand.update()
	
func update_item_in_hand():
	if !item_in_hand:
		return
	item_in_hand.global_position = get_global_mouse_position() - item_in_hand.size / 2

func _input(event):
	update_item_in_hand()
