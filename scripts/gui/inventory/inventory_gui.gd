extends Control
class_name InventoryUI

@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var ItemStackGUIScene = preload("res://scenes/gui/inventory/item_stack_gui.tscn")

@onready var hotbar_slots: Array = $NinePatchRect/HBoxContainer.get_children()
@onready var slots: Array = hotbar_slots + $NinePatchRect/GridContainer.get_children()

@onready var player: Player = SceneManager.player
@onready var gold_label: Label = $NinePatchRect/VBoxContainer/Gold/gold_label
@onready var selector: Control = $Selector

var currently_held_item: ItemStackGUI
var original_slot_index: int = -1
var locked: bool = false
var is_open: bool = false

var selected_slot_index: int = 0
var is_using_controller: bool = false

func _ready():
	connect_slot_buttons()
	inventory.updated.connect(update_inventory_display)
	update_inventory_display()
	update_selector_position()

func _process(_delta):
	update_gold_display()
	update_held_item_position()

"""Updates the displayed amount of gold."""
func update_gold_display():
	if player:
		gold_label.text = str(player.gold)

"""Connects each slot's button press signal to a single handler."""
func connect_slot_buttons():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		var callable = Callable(self, "on_slot_pressed").bind(slot)
		slot.pressed.connect(callable)

"""Synchronizes the UI with the current state of the inventory."""
func update_inventory_display():
	var count = min(inventory.slots.size(), slots.size())
	for i in range(count):
		var inv_slot: InventorySlot = inventory.slots[i]

		if not inv_slot.item:
			slots[i].clear_slot()
			continue

		var gui: ItemStackGUI = slots[i].item_stack_gui
		if not gui:
			gui = ItemStackGUIScene.instantiate()
			slots[i].insert_item_stack_gui(gui)

		gui.inventory_slot = inv_slot
		gui.update()

	update_selector_position()

"""Positions the selector (UI highlight) over the currently selected slot."""
func update_selector_position():
	var slot = slots[selected_slot_index]
	selector.global_position = slot.global_position

"""Opens the inventory UI."""
func open():
	visible = true
	is_open = true

"""Closes the inventory UI."""
func close():
	visible = false
	is_open = false

"""Called when a slot is pressed. Determines which action to take based on 
what's currently in the slot and what's in the player's hand."""
func on_slot_pressed(slot):
	if locked:
		return
	if slot.is_empty():
		handle_click_empty_slot(slot)
	else:
		handle_click_occupied_slot(slot)

"""Called when a slot is selected via controller input."""
func on_slot_selected():
	var slot = slots[selected_slot_index]
	on_slot_pressed(slot)

"""Handle the case where the clicked slot is empty."""
func handle_click_empty_slot(slot):
	if currently_held_item:
		place_held_item_in_slot(slot)

"""Handle the case where the clicked slot has an item."""
func handle_click_occupied_slot(slot):
	if not currently_held_item:
		pick_up_item_from_slot(slot)
	elif can_stack_with_slot(slot):
		stack_held_item_into_slot(slot)
	else:
		swap_held_item_with_slot(slot)

"""Check if the currently held item can be stacked into the clicked slot."""
func can_stack_with_slot(slot) -> bool:
	return currently_held_item and slot.item_stack_gui and \
		slot.item_stack_gui.inventory_slot.item.name == currently_held_item.inventory_slot.item.name

"""Pick up the item from the slot into the 'hand'."""
func pick_up_item_from_slot(slot):
	currently_held_item = slot.remove_item_from_slot()
	add_child(currently_held_item)
	original_slot_index = slot.index

"""Place the held item into an empty slot."""
func place_held_item_in_slot(slot):
	var item_to_place = currently_held_item
	remove_child(currently_held_item)
	currently_held_item = null
	slot.insert_item_stack_gui(item_to_place)
	original_slot_index = -1

"""Swap the held item with the slot's item."""
func swap_held_item_with_slot(slot):
	var temp_item = slot.remove_item_from_slot()
	place_held_item_in_slot(slot)
	currently_held_item = temp_item
	add_child(currently_held_item)

"""Stack items when both held and slot items are stackable and identical."""
func stack_held_item_into_slot(slot):
	var slot_gui: ItemStackGUI = slot.item_stack_gui
	var total_amount = slot_gui.inventory_slot.amount + currently_held_item.inventory_slot.amount
	var max_stack = slot_gui.inventory_slot.item.max_per_stack

	if slot_gui.inventory_slot.amount == max_stack:
		swap_held_item_with_slot(slot)
		return

	distribute_items_for_stacking(slot_gui, total_amount, max_stack)
	slot_gui.update()
	if currently_held_item:
		currently_held_item.update()

"""Distribute items between the held item and the slot when stacking."""
func distribute_items_for_stacking(slot_gui: ItemStackGUI, total_amount: int, max_stack: int):
	if total_amount <= max_stack:
		slot_gui.inventory_slot.amount = total_amount
		remove_child(currently_held_item)
		currently_held_item = null
		original_slot_index = -1
	else:
		slot_gui.inventory_slot.amount = max_stack
		currently_held_item.inventory_slot.amount = total_amount - max_stack

"""Updates the position of the currently held item to follow mouse or selector."""
func update_held_item_position():
	if not currently_held_item:
		return
	if is_using_controller:
		currently_held_item.global_position = selector.global_position + (selector.size - currently_held_item.size) / 2
	else:
		currently_held_item.global_position = get_global_mouse_position() - currently_held_item.size / 2

"""Returns the held item to a slot if possible, animating it back."""
func return_held_item_to_slot():
	locked = true
	if original_slot_index < 0:
		# If we don't have a previous slot, try to find an empty one
		var empty_slots = slots.filter(func(s): return s.is_empty())
		if empty_slots.is_empty():
			locked = false
			return
		original_slot_index = empty_slots[0].index

	var target_slot = slots[original_slot_index]
	var tween = create_tween()
	var target_position = target_slot.global_position + target_slot.size / 2
	tween.tween_property(currently_held_item, "global_position", target_position, 0.2)
	await tween.finished

	place_held_item_in_slot(target_slot)
	locked = false

func _input(event):
	# Detect mouse input to switch to mouse mode
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		is_using_controller = false

"""Handle controller navigation and actions."""
func _unhandled_input(event):
	if is_open:
		if event.is_action_pressed("move_selector_up"):
			move_selector(-1, 0)
			is_using_controller = true
		elif event.is_action_pressed("move_selector_down"):
			move_selector(1, 0)
			is_using_controller = true
		elif event.is_action_pressed("move_selector_left"):
			move_selector(0, -1)
			is_using_controller = true
		elif event.is_action_pressed("move_selector_right"):
			move_selector(0, 1)
			is_using_controller = true
		elif event.is_action_pressed("select_item"):
			on_slot_selected()
			is_using_controller = true
		elif currently_held_item and not locked and event.is_action_pressed("use_item"):
			return_held_item_to_slot()
			is_using_controller = true

"""Moves the selector through the slots, wrapping around."""
func move_selector(row_delta: int, column_delta: int):
	var grid_columns = 5  # Adjust as needed
	var total_slots = slots.size()
	var grid_rows = int(total_slots / grid_columns)

	var current_row = int(selected_slot_index / grid_columns)
	var current_column = selected_slot_index % grid_columns

	current_row = (current_row + row_delta + grid_rows) % grid_rows
	current_column = (current_column + column_delta + grid_columns) % grid_columns

	selected_slot_index = current_row * grid_columns + current_column
	update_selector_position()
