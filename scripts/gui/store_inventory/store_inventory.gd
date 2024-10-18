class_name StoreInventory
extends Resource  # Manages the store's inventory as a resource.

# Signals to notify about inventory changes.
signal updated
signal use_item

@export var slots: Array[StoreInventorySlot]  # Array of inventory slots.
var index_of_last_used_item: int = -1  # Tracks the last used item index.

# Inserts an item into the inventory.
func insert(item: InventoryItem):
	if try_stack_item(item):  # Attempt to stack the item.
		return
	place_item_in_empty_slot(item)  # Place in a new slot if stacking fails.
	updated.emit()  # Emit signal to update the inventory display.

# Attempts to stack the item in an existing slot.
func try_stack_item(item: InventoryItem) -> bool:
	for slot in slots:
		if slot.item == item and slot.amount < item.max_per_stack:
			slot.amount += 1
			updated.emit()
			return true  # Item stacked successfully.
	return false  # Item could not be stacked.

# Places the item in the first empty slot found.
func place_item_in_empty_slot(item: InventoryItem):
	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			updated.emit()
			return

# Removes the specified slot from the inventory.
func remove_slot(inventory_slot: StoreInventorySlot):
	var index = slots.find(inventory_slot)
	if index >= 0:
		remove_at_index(index)

# Removes the item at a specific index.
func remove_at_index(index: int):
	slots[index] = StoreInventorySlot.new()
	updated.emit()

# Inserts a slot into the inventory at a specific index.
func insert_slot(index: int, inventory_slot: StoreInventorySlot):
	slots[index] = inventory_slot
	updated.emit()

# Uses the item at the specified index.
func use_item_at_index(index: int):
	if index < 0 or index >= slots.size() or !slots[index].item:
		return
	var slot = slots[index]
	index_of_last_used_item = index
	use_item.emit(slot.item)

# Removes the last used item from the inventory.
func remove_last_used_item():
	if index_of_last_used_item < 0:
		return
	var slot = slots[index_of_last_used_item]
	if slot.amount > 1:
		slot.amount -= 1
	else:
		remove_at_index(index_of_last_used_item)
	updated.emit()
