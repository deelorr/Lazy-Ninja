extends BaseInventory
class_name StoreInventory

#func insert(item: InventoryItem):
	#if try_stack_item(item):
		#return
	#place_item_in_empty_slot(item)
	#updated.emit()
#
#func try_stack_item(item: InventoryItem) -> bool:
	#for slot in slots:
		#if slot.item == item and slot.amount < item.max_per_stack:
			#slot.amount += 1
			#updated.emit()
			#return true
	#return false
#
#func place_item_in_empty_slot(item: InventoryItem):
	#for i in range(slots.size()):
		#if !slots[i].item:
			#slots[i].item = item
			#slots[i].amount = 1
			#updated.emit()
			#return
#
#func remove_slot(inventory_slot: InventorySlot):
	#var index = slots.find(inventory_slot)
	#if index >= 0:
		#remove_at_index(index)
#
#func remove_at_index(index: int):
	#slots[index] = InventorySlot.new()
	#updated.emit()
#
#func insert_slot(index: int, inventory_slot: InventorySlot):
	#slots[index] = inventory_slot
	#updated.emit()
#
#func use_item_at_index(index: int):
	#if index < 0 or index >= slots.size() or !slots[index].item:
		#return
	#var slot = slots[index]
	#last_used_slot_index = index
	#use_item.emit(slot.item)
#
#func remove_last_used_item():
	#if last_used_slot_index < 0:
		#return
	#var slot = slots[last_used_slot_index]
	#if slot.amount > 1:
		#slot.amount -= 1
	#else:
		#remove_at_index(last_used_slot_index)
	#updated.emit()
