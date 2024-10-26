extends Control

signal opened
signal closed

@onready var inventory: StoreInventory = preload("res://resources/inventory/store_inventory.tres")
@onready var itemStackGUIClass: PackedScene = preload("res://scenes/gui/store_inventory/store_item_stack_gui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var isOpen: bool = false
var item_in_hand: StoreItemStackGUI
var player: Player = null
var player_inventory: Inventory = null

func _ready():
	connect_slots()
	inventory.updated.connect(update)
	update()
	
	if SceneManager.player != null:
		player = SceneManager.player
		player_inventory = player.inventory
	else:
		print_debug("no player found, waiting for signal")
		SceneManager.player_changed.connect(_on_player_changed)

func _on_player_changed(new_player):
	player = new_player
	player_inventory = player.inventory
	print_debug("Player inventory updated:", player_inventory)

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
	if slot.is_empty():
		handle_empty_slot_click(slot)
	else:
		handle_non_empty_slot_click(slot)

func handle_empty_slot_click(_slot):
	print("empty slot")
	return

func handle_non_empty_slot_click(slot):
	var inventory_slot = slot.item_stack_gui.inventory_slot
	var item = inventory_slot.item
	var price = item.price
	if player.gold >= price:
		player.gold -= price
		player_inventory.insert(item)
		inventory_slot.amount -= 1
		if inventory_slot.amount <= 0:
			slot.clear()
			inventory.remove_slot(inventory_slot)
		else:
			slot.item_stack_gui.update()
		print("Purchased:", item.name)
	else:
		print("Not enough money to purchase:", item.name)
