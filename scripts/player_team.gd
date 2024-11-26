extends GridContainer

var player_team = []
var BattleCharacterScene = preload("res://scenes/characters/BattleCharacter.tscn")

const ALLY_TYPES = preload("res://CharacterTypes.gd").ALLY_TYPES

func _ready():
	generate_player_team(3)

func generate_player_team(team_size):
	# First character is always the main player
	var player_instance = BattleCharacterScene.instantiate()
	player_instance.initialize_hero_stats()
	add_child(player_instance)
	player_team.append(player_instance)
	print(player_team)
	
	# Add additional allies randomly
	for i in range(team_size - 1):  # Subtract 1 since the first is the main player
		var ally_data = ALLY_TYPES[randi() % ALLY_TYPES.size()]
		var ally_instance = BattleCharacterScene.instantiate()
		ally_instance.is_enemy = false
		ally_instance.name = ally_data["name"] + " Ally %d" % (i + 1)
		ally_instance.initialize_stats()
		ally_instance.character_icon = ally_data["icon"]
		add_child(ally_instance)
		player_team.append(ally_instance)
