class_name ItemStackGUI
extends Panel

@onready var item_sprite: Sprite2D = $item
@onready var amount_label: Label = $Label
@onready var price_label: Label = $price_label

var inventory_slot: InventorySlot

"""Updates the visual representation of the item stack."""
func update():
	if not inventory_slot or not inventory_slot.item:
		item_sprite.visible = false
		amount_label.visible = false
		return

	item_sprite.visible = true
	item_sprite.texture = inventory_slot.item.texture

	if inventory_slot.amount > 1:
		amount_label.visible = true
		amount_label.text = str(inventory_slot.amount)
	else:
		amount_label.visible = false
		
	price_label.visible = true
	price_label.text = "$" + str(inventory_slot.item.price)
