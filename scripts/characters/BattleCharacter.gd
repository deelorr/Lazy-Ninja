extends Button
class_name BattleCharacter

signal enemy_selected(enemy)
signal player_selected(player)
signal character_died(character)

@export var is_enemy: bool = true
@export var character_icon: Texture
@export var max_health: int = 50

@onready var player: Player = SceneManager.player
@onready var name_label: Label = $Name

var current_health: int
var damage: int = 10

func _ready():
	name_label.text = self.name
	current_health = max_health
	connect("pressed",Callable(self, "_on_pressed"))
	if character_icon:
		icon = character_icon
	else:
		icon = null

func _process(_delta):
	update_healthbar()

func initialize_hero_stats():
	is_enemy = false
	name = SceneManager.player.player_name
	max_health = SceneManager.player.max_health
	current_health = max_health
	damage = SceneManager.player.damage
	character_icon = preload("res://art/characters/player/player_face.png")

func _on_pressed():
	if is_enemy:
		enemy_selected.emit(self)
	else:
		player_selected.emit(self)

func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	if current_health == 0:
		die()

func die():
	character_died.emit()
	#emit_signal("character_died")
	queue_free()

func update_healthbar():
	$Health.max_value = max_health
	$Health.value = current_health
	$Health/HealthLabel.text = str(current_health) + "/" + str(max_health)
