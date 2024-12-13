extends Control

signal opened
signal closed

@onready var inventory: StoreInventory = preload("res://resources/inventory/store_inventory.tres")
@onready var itemStackGUIClass = preload("res://scenes/gui/inventory/item_stack_gui.tscn")

@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var player: Player = SceneManager.player
@onready var selector: Control = $Selector

var isOpen: bool = false
var item_in_hand: ItemStackGUI
var selected_slot_index: int = 0
var grid_columns: int = 5  # Adjust based on your actual grid layout

func _ready():
	connect_slots()
	inventory.updated.connect(update)
	update()
	update_selector_position()

func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		var callable = Callable(self, "on_slot_clicked").bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		if !inventorySlot.item:
			slots[i].clear()
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
	# Reset selector position when opening
	selected_slot_index = 0
	update_selector_position()

func close():
	visible = false
	isOpen = false
	closed.emit()

func on_slot_clicked(slot):
	if slot.is_empty():
		handle_empty_slot_click(slot)
	else:
		handle_non_empty_slot_click(slot)

func handle_empty_slot_click(_slot):
	return

func handle_non_empty_slot_click(slot):
	var inventory_slot = slot.item_stack_gui.inventory_slot
	var item = inventory_slot.item
	var price = item.price
	if player.gold >= price:
		player.gold -= price
		player.inventory.add_item(item)
		inventory_slot.amount -= 1
		if inventory_slot.amount <= 0:
			slot.clear()
			inventory.remove_slot_by_reference(inventory_slot)
		else:
			slot.item_stack_gui.update()
		print("Purchased:", item.name)
	else:
		print("Not enough money to purchase:", item.name)

func move_selector(delta_row: int, delta_column: int):
	var total_slots = slots.size()
	var grid_rows = int((total_slots + grid_columns - 1) / grid_columns)

	var row = int(selected_slot_index / grid_columns)
	var column = int(selected_slot_index % grid_columns)

	row = (row + delta_row + grid_rows) % grid_rows
	column = (column + delta_column + grid_columns) % grid_columns

	var new_index = row * grid_columns + column
	if new_index >= total_slots:
		new_index = total_slots - 1
	selected_slot_index = new_index
	update_selector_position()

func update_selector_position():
	var slot = slots[selected_slot_index]
	selector.position = slot.position

func _unhandled_input(event):
	if isOpen:
		if event.is_action_pressed("ui_left"):
			move_selector(0, -1)
		elif event.is_action_pressed("ui_right"):
			move_selector(0, 1)
		elif event.is_action_pressed("ui_up"):
			move_selector(-1, 0)
		elif event.is_action_pressed("ui_down"):
			move_selector(1, 0)
		elif event.is_action_pressed("ui_accept"):
			var slot = slots[selected_slot_index]
			on_slot_clicked(slot)
