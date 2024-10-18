class_name InventoryItem
extends Resource  # This class extends Resource, allowing instances to be saved and reused.

# Exported variables that can be set in the editor or via code.
@export var name: String = ""  # The name of the item.
@export var texture: Texture2D  # The texture/image representing the item.
@export var max_per_stack: int  # Maximum number of items per stack.
@export var price: int  # The price of the item.

# Placeholder function to define how the item is used.
func use(_player):
	pass

# Function to check if the item can be used by the player.
func can_be_used(_player: Player):
	return true
