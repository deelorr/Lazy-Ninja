class_name StoreInventorySlot
extends Resource  # Allows saving/loading of inventory slots.

# Exported variables for editor access.
@export var item: InventoryItem  # The item in the slot.
@export var amount: int  # Quantity of the item in the slot.
