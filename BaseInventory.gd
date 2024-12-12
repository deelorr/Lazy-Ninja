class_name BaseInventory
extends Resource

signal updated
signal use_item

@export var slots: Array[InventorySlot]
var last_used_slot_index: int = -1

"""Add an item to the inventory. If possible, stack it; otherwise, place it into an empty slot."""
func add_item(item: InventoryItem):
	if try_stack_in_existing_slot(item):
		return
	place_item_in_empty_slot(item)
	updated.emit()

"""Attempt to stack the given item into an existing slot with the same item."""
func try_stack_in_existing_slot(item: InventoryItem) -> bool:
	for slot in slots:
		if slot.item == item and slot.amount < item.max_per_stack:
			slot.amount += 1
			updated.emit()
			return true
	return false

"""Place the given item into the first available empty slot."""
func place_item_in_empty_slot(item: InventoryItem):
	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			updated.emit()
			return

"""Remove the specified slot (by reference) from the inventory."""
func remove_slot_by_reference(inventory_slot: InventorySlot):
	var index = slots.find(inventory_slot)
	if index >= 0:
		remove_item_at_index(index)

"""Remove the item at the specified index."""
func remove_item_at_index(index: int):
	if index < 0 or index >= slots.size():
		return
	slots[index] = InventorySlot.new()
	updated.emit()

"""Set a slot to a specified InventorySlot structure at a given index."""
func set_slot(index: int, inventory_slot: InventorySlot):
	if index < 0 or index >= slots.size():
		return
	slots[index] = inventory_slot
	updated.emit()

"""Emit the use_item signal for the item in the specified slot index, if valid."""
func use_item_at_index(index: int):
	if index < 0 or index >= slots.size():
		return
	var slot = slots[index]
	if slot.item:
		last_used_slot_index = index
		use_item.emit(slot.item)

"""Removes one unit of the last used item (or clears the slot if it was the last unit)."""
func remove_last_used_item():
	if last_used_slot_index < 0 or last_used_slot_index >= slots.size():
		return
	var slot = slots[last_used_slot_index]
	if slot.amount > 1:
		slot.amount -= 1
	else:
		remove_item_at_index(last_used_slot_index)
	updated.emit()
