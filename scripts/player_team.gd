extends GridContainer

var player_team = []
var BattleCharacterScene = preload("res://scenes/characters/BattleCharacter.tscn")

func _ready():
	generate_player() # Generate player stats
	generate_player_team(2)  # Generate 2 additional players

func generate_player():
	var hero_instance = BattleCharacterScene.instantiate()
	hero_instance.is_enemy = false
	hero_instance.name = "Hero"
	hero_instance.initialize_hero_stats()
	add_child(hero_instance)
	player_team.append(hero_instance)

func generate_player_team(team_size):
	for i in range(team_size):
		var character_instance = BattleCharacterScene.instantiate()
		character_instance.is_enemy = false
		character_instance.name = "Player_%d" % i
		character_instance.initialize_stats()
		add_child(character_instance)
		player_team.append(character_instance)
