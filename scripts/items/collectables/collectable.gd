extends Area2D

@export var item_res: InventoryItem

func collect(inventory: Inventory):
	inventory.add_item(item_res)
	queue_free()
