class_name HealthItem
extends InventoryItem

@export var health_increase: int = 1

func use(player: Player):
	player.increase_health(health_increase)
	
func can_be_used(player: Player):
	return player.current_health < player.max_health
	
