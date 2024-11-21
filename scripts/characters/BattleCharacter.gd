extends CharacterBody2D
class_name BattleCharacter

signal enemy_selected(enemy_node)
signal player_selected(player_node)

@export var is_enemy: bool = true  #set in scene

var current_health: int
var max_health: int = 50
var damage: int = 10

func _ready():
	current_health = max_health
	$Button.pressed.connect(Callable(self, "_on_pressed"))
	
func _process(delta):
	update_health()

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
	
func update_health():
	$ProgressBar.max_value = max_health
	$ProgressBar.value = current_health
