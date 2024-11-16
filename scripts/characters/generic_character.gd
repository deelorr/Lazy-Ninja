extends Button

signal enemy_selected(enemy_node)
signal player_selected(player_node)

@export var is_enemy: bool = true  # Set this appropriately in your scene

var input_enabled: bool = false  # Control input based on turn

var health: int = 20
var max_health: int = 100
var damage: int = 10

func _ready():
	self.pressed.connect(Callable(self, "_on_pressed"))

func _on_pressed():
	if not input_enabled:
		return  # Ignore clicks when input is disabled
	if is_enemy:
		emit_signal("enemy_selected", self)
		print("Enemy clicked!")
	else:
		emit_signal("player_selected", self)
		print("Player clicked!")

func take_damage(amount: int):
	health = max(health - amount, 0)
	if health == 0:
		die()

func die():
	queue_free()
