extends Resource

class_name Inventory

signal updated

@export var items: Array[InventoryItem] = []

func _init():
	var inventory_size = 15  # Adjust as needed
	items.resize(inventory_size)
	for i in range(inventory_size):
		items[i] = null

func insert(item: InventoryItem):
	for i in range(items.size()):
		if !items[i]:
			items[i] = item
			break
	updated.emit()
