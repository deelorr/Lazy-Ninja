extends InventoryItem
class_name HealthItem

@export var health_increase: int

func use(player: Player):
	player.increase_health(health_increase)
	
func can_be_used(player: Player):
	return player.current_health < player.max_health
	
