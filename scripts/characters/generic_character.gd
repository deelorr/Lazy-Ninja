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

func _on_attack_pressed():
	print("attacking enemy")

func _on_item_pressed():
	print("using item")

func _on_run_pressed():
	print("trying to run away")
