extends Node2D

var is_player_turn: bool = true
var is_selecting_enemy: bool = false

@onready var attack_button: Button = $battle_menu/VBoxContainer/Attack
@onready var item_button: Button = $battle_menu/VBoxContainer/Item
@onready var run_button: Button = $battle_menu/VBoxContainer/Run
@onready var player_team: Array = $player_team/GridContainer.get_children()
@onready var enemy_team: Array = $enemy_team/GridContainer.get_children()

func _ready():
	randomize()
	connect_signals()
	disable_buttons()
	start_battle()

func connect_signals():
	for player in player_team: #connect the player_selected signal from each player
		player.connect("player_selected",Callable(self, "_on_player_selected"))
	for enemy in enemy_team: #connect the enemy_selected signal from each enemy
		enemy.connect("enemy_selected",Callable(self, "_on_enemy_selected"))

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
	enable_buttons()
	PopUpText.show_popup("Choose an action!")
	await PopUpText.popup_finished

func _on_attack_pressed():
	if is_player_turn:
		is_selecting_enemy = true
		PopUpText.show_popup("Click on an enemy to attack")
		await PopUpText.popup_finished

func _on_enemy_selected(enemy):
	print("selected", enemy)
	if is_selecting_enemy:
		is_selecting_enemy = false
		var damage_amount = 15
		enemy.take_damage(damage_amount)
		PopUpText.show_popup(["Attacked", enemy.name, "for", damage_amount, "damage!"])
		await PopUpText.popup_finished
		clean_up_teams()
		check_battle_end()
		end_player_turn()

func _on_item_pressed():
	PopUpText.show_popup("Item used!")
	await PopUpText.popup_finished
	#item logic
	end_player_turn()

func _on_run_pressed():
	PopUpText.show_popup("Trying to run...")
	await PopUpText.popup_finished
	# Add run logic here
	end_player_turn()

func end_player_turn():
	is_player_turn = false
	disable_buttons()
	start_enemy_turn()

func start_enemy_turn():
	PopUpText.show_popup("Enemy's turn...")
	await PopUpText.popup_finished
	# Decide on the target
	var target = select_enemy_target()
	print("selected", target)

	if target == null:
		check_battle_end()
		return
	# Example: Perform a normal attack
	var damage = 10  # AI's base attack damage
	target.take_damage(damage)
	# Display feedback
	PopUpText.show_popup(["Enemy attacked", target.name, "for", damage, "damage!"])
	await PopUpText.popup_finished
	clean_up_teams()
	check_battle_end()
	end_enemy_turn()

func select_enemy_target():
	# Clean up player_team
	player_team = player_team.filter(func(player):
		return is_instance_valid(player))

	if player_team.is_empty():
		return null  # No valid players left

	# Now proceed to select the target
	var target = player_team[0]
	var min_health = target.health
	for player in player_team:
		if player.health < min_health:
			target = player
			min_health = player.health
	return target

func end_enemy_turn():
	is_player_turn = true
	start_player_turn()

func check_battle_end():
	clean_up_teams()
	if enemy_team.size() == 0:
		PopUpText.show_popup("Player wins!")
		await PopUpText.popup_finished
		#get_tree().quit()
		
	elif player_team.size() == 0:
		PopUpText.show_popup("Enemy wins!")
		await PopUpText.popup_finished
		#get_tree().quit()

func enable_buttons():
	attack_button.disabled = false
	item_button.disabled = false
	run_button.disabled = false

func disable_buttons():
	attack_button.disabled = true
	item_button.disabled = true
	run_button.disabled = true

func clean_up_teams():
	player_team = player_team.filter(func(player):
		return is_instance_valid(player))
	enemy_team = enemy_team.filter(func(enemy):
		return is_instance_valid(enemy))
