class_name StoreInventory
extends Resource

signal updated
signal use_item

@export var slots: Array[StoreInventorySlot]
var index_of_last_used_item: int = -1

# Insert an item into the inventory, either stacking it or placing it in a new slot
func insert(item: StoreInventoryItem):
	if try_stack_item(item):
		return
	place_item_in_empty_slot(item)

	updated.emit()

# Tries to stack the item in an existing slot
func try_stack_item(item: StoreInventoryItem) -> bool:
	for slot in slots:
		if slot.item == item and slot.amount < item.max_per_stack:
			slot.amount += 1
			updated.emit()
			return true
	return false

# Finds an empty slot and places the item there
func place_item_in_empty_slot(item: StoreInventoryItem):
	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			updated.emit()
			return

# Remove the item from the specified slot
func remove_slot(inventory_slot: StoreInventorySlot):
	var index = slots.find(inventory_slot)
	if index >= 0:
		remove_at_index(index)

# Removes the item at a specific index
func remove_at_index(index: int):
	slots[index] = StoreInventorySlot.new()
	updated.emit()

# Insert an item at a specific index in the inventory
func insert_slot(index: int, inventory_slot: StoreInventorySlot):
	slots[index] = inventory_slot
	updated.emit()

# Use the item in the specified slot
func use_item_at_index(index: int):
	if index < 0 or index >= slots.size() or !slots[index].item:
		return
	var slot = slots[index]
	index_of_last_used_item = index
	use_item.emit(slot.item)

# Remove the last used item from the inventory
func remove_last_used_item():
	if index_of_last_used_item < 0:
		return
	var slot = slots[index_of_last_used_item]
	if slot.amount > 1:
		slot.amount -= 1
	else:
		remove_at_index(index_of_last_used_item)
	updated.emit()
