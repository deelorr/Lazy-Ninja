extends Button

signal enemy_selected(enemy_node)
signal player_selected(player_node)

@export var is_enemy: bool = true  # Set this appropriately in your scene

var current_health: int = 20
var max_health: int = 100
var damage: int = 10

func _ready():
	self.pressed.connect(Callable(self, "_on_pressed"))

func _on_pressed():
	if is_enemy:
		emit_signal("enemy_selected", self)
		print("Enemy clicked!")
	else:
		emit_signal("player_selected", self)
		print("Player clicked!")

func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	if current_health == 0:
		die()

func die():
	#if self in player_team:
		#player_team.erase(self)
	#elif self in enemy_team:
		#enemy_team.erase(self)
	queue_free()  # Free the object after removal
