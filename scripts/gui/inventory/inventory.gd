class_name Inventory
extends Resource

signal updated

@export var slots: Array[InventorySlot]

func insert(item: InventoryItem):
	for slot in slots:
		if slot.item == item:
			slot.amount += 1
			updated.emit()
			return

	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			updated.emit()
			return

	updated.emit()

func remove_item_at_index(index: int):
	slots[index] = InventorySlot.new()
	
func insert_slot(index:int, inventory_slot: InventorySlot):
	var old_index: int = slots.find(inventory_slot)
	remove_item_at_index(old_index)
	
	slots[index] = inventory_slot
