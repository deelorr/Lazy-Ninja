extends Resource
class_name PlayerInventory

var player: Player

func _init(p):
	player = p

func connect_signals():
	if player.inventory:
		player.inventory.use_item.connect(use_item)

func use_item(item: InventoryItem):
	if not item.can_be_used(player):
		return
	item.use(player)
	player.inventory.remove_last_used_item()

func increase_health(amount: int):
	player.current_health = min(player.max_health, player.current_health + amount)

func change_gold(amount: int):
	player.gold += amount
