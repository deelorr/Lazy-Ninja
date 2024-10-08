class_name InventoryItem
extends Resource

@export var name: String = ""
@export var texture: Texture2D
@export var max_per_stack: int


func use(player):
	pass

func can_be_used(player: Player):
	return true
	
