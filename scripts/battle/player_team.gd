extends GridContainer

const ALLY_TYPES = preload("res://scripts/characters/battle/CharacterTypes.gd").ALLY_TYPES
var player_team = []

var BattleCharacterScene = preload("res://scenes/battle/BattleCharacter.tscn")

func _ready():
	generate_player_team(2)

func generate_player_team(team_size):
	#first spot is always the player
	var player_instance = BattleCharacterScene.instantiate()
	configure_player_instance(player_instance)

	#shuffle to avoid duplicates
	var available_allies = ALLY_TYPES.duplicate()
	available_allies.shuffle()

	for i in range(min(team_size - 1, available_allies.size())):  #don't exceed available allies
		var ally_data = available_allies[i]
		var ally_instance = BattleCharacterScene.instantiate()
		configure_ally_instance(ally_data, ally_instance)
		add_child(ally_instance)
		player_team.append(ally_instance)
		
func configure_player_instance(player_instance):
	player_instance.initialize_hero_stats()
	add_child(player_instance)
	player_team.append(player_instance)

func configure_ally_instance(ally_data, ally_instance):
	ally_instance.is_enemy = false
	ally_instance.name = ally_data["name"]
	ally_instance.character_icon = ally_data["icon"]
	ally_instance.max_health = ally_data["max_health"]
	ally_instance.damage = ally_data["damage"]
