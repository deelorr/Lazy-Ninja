extends Button
class_name BattleCharacter

signal enemy_selected(enemy)
signal player_selected(player)
signal character_died(character)

var is_enemy: bool = true
var current_health: int
var max_health: int = 50
var damage: int = 10

func _ready():
	current_health = max_health
	connect("pressed",Callable(self, "_on_pressed")) # Correctly connect the 'pressed' signal

func _process(delta):
	update_health()

func initialize_stats():
	if is_enemy:
		max_health = randf_range(30, 60)
		damage = randf_range(5, 15)
	else:
		max_health = randf_range(50, 100)
		damage = randf_range(10, 20)
	current_health = max_health
	
func initialize_hero_stats():
	max_health = SceneManager.player.max_health
	damage = SceneManager.player.damage
	current_health = max_health

func _on_pressed():
	if is_enemy:
		enemy_selected.emit(self)
		#print(self.name, " selected")
	else:
		player_selected.emit(self)
		#print(self.name, " selected")

func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	if current_health == 0:
		die()

func die():
	character_died.emit(self)
	queue_free()

func update_health():
	$Health.max_value = max_health
	$Health.value = current_health
	$Health/HealthLabel.text = str(current_health) + "/" + str(max_health)
