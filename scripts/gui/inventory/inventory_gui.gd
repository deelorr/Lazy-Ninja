extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var itemStackGUIClass = preload("res://scenes/gui/inventory/item_stack_gui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	connect_slots()
	inventory.updated.connect(update)
	update()

func connect_slots():
	for slot in slots:
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
	pass
