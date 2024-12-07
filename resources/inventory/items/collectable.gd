extends Area2D

@export var item_res: InventoryItem
@export var type: String = ""  # or "lifepot"

@onready var player = SceneManager.player

func collect(inventory: Inventory):
	print("Collecting item of type:", type)
	match type:
		"coin":
			player.change_gold(10)
		"lifepot":
			player.inventory.insert(item_res)
			player.increase_health(1)
			print("Added 1 health!")
	queue_free()
