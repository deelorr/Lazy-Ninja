extends Control

signal opened
signal closed

var isOpen = false

@onready var inventory: Inventory = preload("res://scenes/inventory/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	inventory.updated.connect(update)
	update()

func update():
	for i in range(slots.size()):
		slots[i].update(inventory.items[i])

func open():
	visible = true
	isOpen = true
	opened.emit()
	
func close():
	visible = false
	isOpen = false
	closed.emit()
