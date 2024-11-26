extends GridContainer

const ENEMY_TYPES = preload("res://CharacterTypes.gd").ENEMY_TYPES

var enemy_team = []
var BattleCharacterScene = preload("res://scenes/characters/BattleCharacter.tscn")

func _ready():
	var min_enemies = 1
	var max_enemies = 5
	var team_size = randi_range(min_enemies, max_enemies)
	generate_enemy_team(team_size)

func generate_enemy_team(team_size):
	if ENEMY_TYPES.size() == 0:
		print("No enemy types defined!")
		return

	for i in range(team_size):
		var enemy_data = ENEMY_TYPES[randi() % ENEMY_TYPES.size()]
		if enemy_data == null:
			continue  # Skip if no valid data
		var character_instance = BattleCharacterScene.instantiate()
		character_instance.is_enemy = true
		character_instance.name = enemy_data["name"] + " %d" % (i + 1)
		character_instance.initialize_stats()
		character_instance.character_icon = enemy_data["icon"]
		add_child(character_instance)
		enemy_team.append(character_instance)
