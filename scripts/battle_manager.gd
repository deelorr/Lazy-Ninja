extends Node2D

var player_team := []
var enemy_team := []
var is_player_turn: bool

func _ready():
	# Initialize teams
	player_team = $PlayerTeam.get_children()
	enemy_team = $EnemyTeam.get_children()
	# Decide who goes first with a coin toss
	var coin_toss = randi() % 2  # Returns 0 or 1
	is_player_turn = coin_toss == 0
	if is_player_turn:
		print("Player's team goes first.")
		start_player_turn()
	else:
		print("Enemy team goes first.")
		start_enemy_turn()
