extends GridContainer

var enemy_team = []
var BattleCharacterScene = preload("res://scenes/characters/BattleCharacter.tscn")

func _ready():
	generate_enemy_team(3)   # Generate 3 enemies

func generate_enemy_team(team_size):
	for i in range(team_size):
		var character_instance = BattleCharacterScene.instantiate()
		character_instance.is_enemy = true
		character_instance.name = "Enemy_%d" % i
		character_instance.initialize_stats()
		add_child(character_instance)
		enemy_team.append(character_instance)
