extends BaseScene

var is_player_turn: bool = true
var is_selecting_enemy: bool = false

@onready var attack_button: Button = $battle_menu/VBoxContainer/Attack
@onready var item_button: Button = $battle_menu/VBoxContainer/Item
@onready var run_button: Button = $battle_menu/VBoxContainer/Run
@onready var player_team: Array[CharacterBody2D] = [] #$player_team/GridContainer.get_children()
@onready var enemy_team: Array = $enemy_team/GridContainer.get_children()

func _ready():
	randomize()
	player_team.append(player)
	connect_signals()
	disable_buttons()
	start_battle()

func connect_signals():
	for p in player_team: #connect the player_selected signal from each player
		p.connect("player_selected",Callable(self, "_on_player_selected"))
	for e in enemy_team: #connect the enemy_selected signal from each enemy
		e.connect("enemy_selected",Callable(self, "_on_enemy_selected"))

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
	SceneManager.get_current_scenes()
	PopUpText.show_popup("Choose an action!")
	await PopUpText.popup_finished

func _on_attack_pressed():
	if is_player_turn:
		is_selecting_enemy = true
		PopUpText.show_popup("Click on an enemy to attack")
		await PopUpText.popup_finished

func _on_enemy_selected(enemy):
	if is_selecting_enemy:
		is_selecting_enemy = false
		var damage_amount = 15
		enemy.take_damage(damage_amount)  # Ensure this handles death
		if enemy.current_health <= 0:
			enemy.die()  # Call a method to handle removal
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
	var target = select_enemy_target()
	if target == null:
		check_battle_end()
		return
	var damage = 10
	target.current_health -= damage
	if target.current_health <= 0:
		target.die()  # Handle player removal
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
	var min_health = target.current_health
	for p in player_team:
		if p.current_health < min_health:
			target = player
			min_health = player.current_health
	return target

func end_enemy_turn():
	is_player_turn = true
	start_player_turn()

func check_battle_end():
	clean_up_teams()
	if enemy_team.size() == 0:
		PopUpText.show_popup("Player wins!")
		await PopUpText.popup_finished
		SceneManager.change_scene(self, SceneManager.last_scene_name, SceneManager.player_pos)
		#get_tree().quit()
		
	elif player_team.size() == 0:
		PopUpText.show_popup("Enemy wins!")
		await PopUpText.popup_finished
		SceneManager.change_scene(self, SceneManager.last_scene_name, SceneManager.player)
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
