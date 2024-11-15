extends Button

signal enemy_selected(enemy_node)

var health: int = 100
var max_health: int = 100
var damage: int = 10

func _ready():
	self.pressed.connect(Callable(self, "_on_pressed"))

func _on_pressed():
	emit_signal("enemy_selected", self)
	print("Enemy clicked!")

func take_damage(amount: int):
	health = max(health - amount, 0)
	if health == 0:
		die()

func die():
	queue_free()
