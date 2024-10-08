class_name Inventory
extends Resource

signal updated
signal use_item

@export var slots: Array[InventorySlot]
var index_of_last_used_item: int = -1

func insert(item: InventoryItem):
	for slot in slots:
		if slot.item == item and slot.amount < item.max_per_stack:
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

#func remove_item_at_index(index: int):
	#slots[index] = InventorySlot.new()
	
func remove_slot(inventory_slot: InventorySlot):
	var index = slots.find(inventory_slot)
	if index < 0:
		return
	remove_at_index(index)
	
func remove_at_index(index: int):
	slots[index] = InventorySlot.new()
	updated.emit()


func insert_slot(index:int, inventory_slot: InventorySlot):
	#var old_index: int = slots.find(inventory_slot)
	#remove_item_at_index(old_index)
	slots[index] = inventory_slot
	updated.emit()
	
func use_item_at_index(index: int):
	if index < 0 || index >= slots.size() || !slots[index].item: return
	var slot = slots[index]
	index_of_last_used_item = index
	use_item.emit(slot.item)
	
func remove_last_used_item():
	if index_of_last_used_item < 0:
		return
	var slot = slots[index_of_last_used_item]
	
	if slot.amount > 1:
		slot.amount -= 1
		updated.emit()
		return
	
	remove_at_index(index_of_last_used_item)
