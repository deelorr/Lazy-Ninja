extends HBoxContainer

@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var slots: Array = get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	inventory.updated.connect(update)

func update():
	for i in range(slots.size()):
		var inventory_slot: InventorySlot = inventory.slots[i]
		slots[i].update_to_slot(inventory_slot)
