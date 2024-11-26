extends BaseScene

@onready var BattleMenu: VBoxContainer = $BattleMenu
@onready var PlayerTeam: GridContainer = $PlayerTeam
@onready var EnemyTeam: GridContainer = $EnemyTeam

var is_player_turn: bool = false
var is_selecting_enemy: bool = false
var player_team: Array[BattleCharacter]
var current_player_index: int = 0
var enemy_team: Array[BattleCharacter]
var current_enemy_index: int = 0
var BattleCharacterScene = preload("res://scenes/characters/BattleCharacter.tscn")
var battle_over: bool

func _ready():
	BattleMenu.disable_buttons()

	player_team = []
	for node in PlayerTeam.get_children():
		if node is BattleCharacter:
			var character = node as BattleCharacter
			player_team.append(character)
	
	enemy_team = []
	for node in EnemyTeam.get_children():
		if node is BattleCharacter:
			var character = node as BattleCharacter
			enemy_team.append(character)
	
	randomize()
	connect_signals()
	start_battle()

func connect_signals():
	for p in player_team: #connect the player_selected signal from each player
		p.connect("player_selected",Callable(self, "_on_player_selected"))
		p.connect("character_died",Callable(self, "_on_character_died"))
	for e in enemy_team: #connect the enemy_selected signal from each enemy
		e.connect("enemy_selected",Callable(self, "_on_enemy_selected"))
		e.connect("character_died",Callable(self, "_on_character_died"))
		
	BattleMenu.connect("attack_pressed",Callable(self, "_on_attack_pressed"))
	BattleMenu.connect("item_pressed",Callable(self, "_on_item_pressed"))
	BattleMenu.connect("run_pressed",Callable(self, "_on_run_pressed"))

func start_battle():
	PopUpText.show_popup("Flipping Coin...")
	await PopUpText.popup_finished
	var coin_toss = randi() % 2
	if coin_toss == 0:
		is_player_turn = true
	else:
		is_player_turn = false
		
	if is_player_turn:
		PopUpText.show_popup("Heads! Player Goes First!")
		await PopUpText.popup_finished
		start_player_turn()
	else:
		PopUpText.show_popup("Tails! Enemy Goes First!")
		await PopUpText.popup_finished
		start_enemy_turn()

func start_player_turn():
	is_player_turn = true
	current_player_index = 0
	BattleMenu.enable_buttons()
	prompt_player_action()
	
func prompt_player_action():
	# Skip any invalid (dead) players
	while current_player_index < player_team.size() and not is_instance_valid(player_team[current_player_index]):
		current_player_index += 1

	if current_player_index < player_team.size():
		var current_player = player_team[current_player_index]
		PopUpText.show_popup("Choose an action for " + current_player.name)
		await PopUpText.popup_finished
	else:
		end_player_turn()

func _on_attack_pressed():
	if is_player_turn:
		is_selecting_enemy = true
		var current_player = player_team[current_player_index]
		PopUpText.show_popup("Click on an enemy to attack with " + current_player.name)
		await PopUpText.popup_finished

func _on_item_pressed():
	if is_player_turn:
		var current_player = player_team[current_player_index]
		PopUpText.show_popup(current_player.name + " used an item!")
		await PopUpText.popup_finished
		# Implement item logic here
		current_player_index += 1
		prompt_player_action()

func _on_run_pressed():
	if is_player_turn:
		var current_player = player_team[current_player_index]
		PopUpText.show_popup(current_player.name + " is trying to run...")
		await PopUpText.popup_finished
		# Implement run logic here
		current_player_index += 1
		prompt_player_action()

func _on_enemy_selected(enemy):
	if battle_over:
		return
	print(enemy.name, " clicked!")
	if is_selecting_enemy:
		is_selecting_enemy = false
		var current_player = player_team[current_player_index]
		enemy.take_damage(current_player.damage)
		PopUpText.show_popup([current_player.name, " attacked ", enemy.name, " for ", str(current_player.damage), " damage!"])
		await PopUpText.popup_finished
		clean_up_teams()
		check_battle_end()
		current_player_index += 1
		prompt_player_action()

func _on_player_selected(selected_player):
	print(selected_player.name, " clicked!")

func end_player_turn():
	is_player_turn = false
	BattleMenu.disable_buttons()
	start_enemy_turn()

func start_enemy_turn():
	is_player_turn = false
	current_enemy_index = 0
	process_enemy_action()

func process_enemy_action():
	# Skip any invalid (dead) enemies
	while current_enemy_index < enemy_team.size() and not is_instance_valid(enemy_team[current_enemy_index]):
		current_enemy_index += 1

	if current_enemy_index < enemy_team.size():
		var current_enemy = enemy_team[current_enemy_index]
		PopUpText.show_popup("Enemy's turn: " + current_enemy.name)
		await PopUpText.popup_finished
		var target = select_enemy_target()
		if target == null:
			check_battle_end()
			return
		var damage = current_enemy.damage
		target.take_damage(damage)
		PopUpText.show_popup([current_enemy.name, " attacked ", target.name, " for ", str(damage), " damage!"])
		await PopUpText.popup_finished
		clean_up_teams()
		check_battle_end()
		current_enemy_index += 1
		process_enemy_action()
	else:
		end_enemy_turn()

func select_enemy_target():
	var valid_players = get_valid_team(player_team)
	if valid_players.is_empty():
		return null
	return valid_players[randi() % valid_players.size()]

	
func get_valid_team(team):
	return team.filter(is_instance_valid)


func end_enemy_turn():
	is_player_turn = true
	start_player_turn()

func check_battle_end():
	clean_up_teams()
	if enemy_team.size() == 0:
		battle_over = true
		PopUpText.show_popup("Player wins!")
		await PopUpText.popup_finished
		return_to_overworld()
	elif player_team.size() == 0:
		battle_over = true
		PopUpText.show_popup("Enemy wins!")
		await PopUpText.popup_finished
		return_to_overworld()

func return_to_overworld():
	Global.overworld_position = player.position
	SceneManager.change_scene(get_tree().current_scene, "world", null)

func clean_up_teams():
	player_team = get_valid_team(player_team)
	enemy_team = get_valid_team(enemy_team)

func _on_character_died():
	clean_up_teams()
	check_battle_end()
