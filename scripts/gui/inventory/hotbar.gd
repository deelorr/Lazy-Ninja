extends Panel

@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/HBoxContainer.get_children()
@onready var selector: Sprite2D = $Selector

var currently_selected: int = 0

func _ready():
	update()
	inventory.updated.connect(update)

func update():
	for i in range(slots.size()):
		var inventory_slot: InventorySlot = inventory.slots[i]
		slots[i].update_to_slot(inventory_slot)

func move_selector(direction: int):
	# direction should be 1 (right) or -1 (left)
	currently_selected = (currently_selected + direction + slots.size()) % slots.size()
	selector.global_position = slots[currently_selected].global_position

func _unhandled_input(event):
	if event.is_action_pressed("use_item"):
		inventory.use_item_at_index(currently_selected)
	elif event.is_action_pressed("move_selector_right"):
		move_selector(1)  # Move right
	elif event.is_action_pressed("move_selector_left"):
		move_selector(-1)  # Move left
