extends Control

@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var itemStackGUIClass = preload("res://scenes/gui/inventory/item_stack_gui.tscn")
@onready var hotbar_slots: Array = $NinePatchRect/HBoxContainer.get_children()
@onready var slots: Array = hotbar_slots + $NinePatchRect/GridContainer.get_children()
@onready var player: Player = SceneManager.player
@onready var gold_label: Label = $NinePatchRect/VBoxContainer/Gold/gold_label
@onready var selector: Control = $Selector

var item_in_hand: ItemStackGUI
var old_index: int = -1
var locked: bool = false
var isOpen: bool = false

var selected_slot_index: int = 0
var is_using_controller: bool = false

func _ready():
	connect_slots()
	inventory.updated.connect(update)
	update()
	update_selector_position()
	
func _process(_delta):
	update_gold()
	update_item_in_hand()
	
func update_gold():
	if player:
		gold_label.text = str(player.gold)

func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(self, "on_slot_clicked").bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if not inventorySlot.item:
			slots[i].clear()
			continue
		
		var itemStackGUI: ItemStackGUI = slots[i].item_stack_gui
		if not itemStackGUI:
			itemStackGUI = itemStackGUIClass.instantiate()
			slots[i].insert(itemStackGUI)
			
		itemStackGUI.inventory_slot = inventorySlot
		itemStackGUI.update()
	update_selector_position()

func update_selector_position():
	var slot = slots[selected_slot_index]
	selector.global_position = slot.global_position

func open():
	visible = true
	isOpen = true

func close():
	visible = false
	isOpen = false

func on_slot_clicked(slot):
	if locked:
		return

	if slot.is_empty():
		handle_empty_slot_click(slot)
	else:
		handle_non_empty_slot_click(slot)

func on_slot_selected():
	var slot = slots[selected_slot_index]
	on_slot_clicked(slot)

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
	#update_item_in_hand()
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
	#update_item_in_hand()

func stack_items(slot):
	var slot_item: ItemStackGUI = slot.item_stack_gui
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
	if not item_in_hand:
		return
	if is_using_controller:
		item_in_hand.global_position = selector.global_position + (selector.size - item_in_hand.size) / 2
	else:
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

func _input(event):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		is_using_controller = false

func _unhandled_input(event):
	if isOpen:
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
			
		elif item_in_hand and not locked and event.is_action_pressed("use_item"):
			put_item_back()
			is_using_controller = true

func move_selector(delta_row: int, delta_column: int):
	var grid_columns = 5  # Adjust based on your actual grid
	var total_slots = slots.size()
	var grid_rows = int(total_slots / grid_columns)
	
	var row = int(selected_slot_index / grid_columns)
	var column = selected_slot_index % grid_columns
	
	row = (row + delta_row + grid_rows) % grid_rows
	column = (column + delta_column + grid_columns) % grid_columns
	
	selected_slot_index = row * grid_columns + column
	update_selector_position()
