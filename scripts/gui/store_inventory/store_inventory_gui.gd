extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: StoreInventory = preload("res://resources/store_inventory/store_inventory.tres")
@onready var itemStackGUIClass = preload("res://scenes/gui/store_inventory/store_item_stack_gui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var item_in_hand: StoreItemStackGUI
var old_index: int = -1
var locked: bool = false

var player = null
var player_inventory: Inventory = null

func _ready():
	connect_slots()
	inventory.updated.connect(update)
	update()
	
	if scene_manager.player != null:
		player = scene_manager.player
		player_inventory = player.inventory
		print("Player inventory initialized:", player_inventory)
	else:
		print("no player found, waiting for signal")
		scene_manager.player_changed.connect(_on_player_changed)
		
func _on_player_changed(new_player):
	player = new_player
	player_inventory = player.inventory
	print("Player inventory updated:", player_inventory)
	
func _process(delta: float) -> void:
	print(player.inventory)

func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(self, "on_slot_clicked").bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: StoreInventorySlot = inventory.slots[i]
		
		if !inventorySlot.item:
			slots[i].clear()
			continue
		
		var itemStackGUI: StoreItemStackGUI = slots[i].item_stack_gui
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
	if locked:
		return

	if slot.is_empty():
		handle_empty_slot_click(slot)
	else:
		handle_non_empty_slot_click(slot)

func handle_empty_slot_click(slot):
	if item_in_hand:
		insert_item_in_slot(slot)

func handle_non_empty_slot_click(slot):
	if not item_in_hand:
		take_item_from_slot(slot)
	elif can_stack_items(slot):
		stack_items(slot)
	else:
		swap_item(slot)

func can_stack_items(slot) -> bool:
	return slot.item_stack_gui.inventory_slot.item.name == item_in_hand.inventory_slot.item.name

func take_item_from_slot(slot):
	item_in_hand = slot.take_item()
	add_child(item_in_hand)
	update_item_in_hand()
	old_index = slot.index

func insert_item_in_slot(slot):
	var item = item_in_hand
	remove_child(item_in_hand)
	item_in_hand = null
	slot.insert(item)
	old_index = -1

func swap_item(slot):
	var temp_item = slot.take_item()
	insert_item_in_slot(slot)
	item_in_hand = temp_item
	add_child(item_in_hand)
	update_item_in_hand()

func stack_items(slot):
	var slot_item: StoreItemStackGUI = slot.item_stack_gui
	var total_amount = slot_item.inventory_slot.amount + item_in_hand.inventory_slot.amount
	var max_amount = slot_item.inventory_slot.item.max_per_stack

	if slot_item.inventory_slot.amount == max_amount:
		swap_item(slot)
		return

	add_items_to_slot(slot_item, total_amount, max_amount)
	slot_item.update()
	if item_in_hand:
		item_in_hand.update()

func add_items_to_slot(slot_item, total_amount, max_amount):
	if total_amount <= max_amount:
		slot_item.inventory_slot.amount = total_amount
		remove_child(item_in_hand)
		item_in_hand = null
		old_index = -1
	else:
		slot_item.inventory_slot.amount = max_amount
		item_in_hand.inventory_slot.amount = total_amount - max_amount

func update_item_in_hand():
	if !item_in_hand:
		return
	item_in_hand.global_position = get_global_mouse_position() - item_in_hand.size / 2

func put_item_back():
	locked = true
	if old_index < 0:
		var empty_slots = slots.filter(func(slot): return slot.is_empty())
		if empty_slots.is_empty():
			locked = false  # Unlock before returning
			return
		old_index = empty_slots[0].index
	
	var target_slot = slots[old_index]
	
	var tween = create_tween()
	var target_position = target_slot.global_position + target_slot.size / 2
	tween.tween_property(item_in_hand, "global_position", target_position, 0.2)
	await tween.finished
	
	insert_item_in_slot(target_slot)
	locked = false  # Unlock after operation is complete

func _input(_event):
	if item_in_hand && !locked && Input.is_action_just_pressed("right_click"):
		put_item_back()
		
	update_item_in_hand()
