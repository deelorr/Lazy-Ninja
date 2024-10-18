class_name StoreItemStackGUI
extends Panel  # Base node for the item stack GUI.

# References to child nodes.
@onready var item_sprite: Sprite2D = $item  # Sprite displaying the item's texture.
@onready var amount_label: Label = $amount_label  # Label showing the item's amount.
@onready var price_label: Label = $price_label

var inventory_slot  # The inventory slot this GUI represents.

# Updates the GUI elements based on the inventory slot data.
func update():
	if not inventory_slot or not inventory_slot.item:
		return

	# Display the item's texture.
	item_sprite.visible = true
	item_sprite.texture = inventory_slot.item.texture

	# Display the amount if more than one.
	if inventory_slot.amount > 1:
		amount_label.visible = true
		amount_label.text = str(inventory_slot.amount)
	else:
		amount_label.visible = false
	
	#update prices
	price_label.visible = true
	price_label.text = "$" + str(inventory_slot.item.price)
