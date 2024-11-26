extends GridContainer

const ENEMY_TYPES = preload("res://CharacterTypes.gd").ENEMY_TYPES
var enemy_team: Array = []
var enemy_counts: Dictionary = {}

var BattleCharacterScene = preload("res://scenes/characters/BattleCharacter.tscn")

func _ready():
	generate_enemy_team(2)

func generate_enemy_team(team_size: int) -> void:
	for i in team_size:
		var enemy_data = ENEMY_TYPES[randi() % ENEMY_TYPES.size()]
		var enemy_instance = BattleCharacterScene.instantiate()
		configure_enemy_instance(enemy_instance, enemy_data)
		add_child(enemy_instance)
		enemy_team.append(enemy_instance)

func configure_enemy_instance(enemy_instance, enemy_data: Dictionary) -> void:
	var enemy_name = enemy_data["name"]
	enemy_counts[enemy_name] = enemy_counts.get(enemy_name, 0)
	var enemy_count = enemy_counts[enemy_name]
	enemy_instance.is_enemy = true
	enemy_instance.name = enemy_name if enemy_count == 0 else enemy_name + " " + str(enemy_count + 1)
	enemy_instance.character_icon = enemy_data["icon"]
	enemy_instance.max_health = enemy_data["max_health"]
	enemy_instance.damage = enemy_data["damage"]
	enemy_counts[enemy_name] += 1
