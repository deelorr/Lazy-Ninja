extends Button

var health: int = 100
var max_health: int = 100
var damage: int = 10

func take_damage(amount: int):
	health = max(health - amount, 0)
	if health == 0:
		die()

func die():
	queue_free()
