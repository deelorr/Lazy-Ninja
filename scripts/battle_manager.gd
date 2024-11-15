extends Node2D

var is_player_turn: bool = true
var is_selecting_enemy: bool = false

@onready var attack_button: Button = $battle_menu/VBoxContainer/Attack
@onready var item_button: Button = $battle_menu/VBoxContainer/Item
@onready var run_button: Button = $battle_menu/VBoxContainer/Run
@onready var player_team: Array = $player_team/GridContainer.get_children()
@onready var enemy_team:Array = $enemy_team/GridContainer.get_children()

func _ready():
	attack_button.disabled = true
	item_button.disabled = true
	run_button.disabled = true
	randomize()
	# Connect the enemy_selected signal from each enemy
	for enemy in enemy_team:
		enemy.connect("enemy_selected",Callable(self, "_on_enemy_selected"))
	start_battle()

func start_battle():
	PopUpText.show_popup("Flipping Coin")
	await PopUpText.popup_finished
	var coin_toss = randi() % 2
	is_player_turn = coin_toss == 0
	if is_player_turn:
		PopUpText.show_popup("Player Goes First!")
		await PopUpText.popup_finished
		start_player_turn()
	else:
		PopUpText.show_popup("Enemy Goes First!")
		await PopUpText.popup_finished
		start_enemy_turn()

func start_player_turn():
	# Enable buttons for the player
	enable_buttons()
	PopUpText.show_popup("Choose an action!")
	await PopUpText.popup_finished

func end_player_turn():
	is_player_turn = false
	disable_buttons()
	start_enemy_turn()

func start_enemy_turn():
	PopUpText.show_popup("Enemy's turn...")
	await PopUpText.popup_finished

	await get_tree().create_timer(1.0).timeout
	var target = player_team[randi() % player_team.size()]
	target.take_damage(10)
	
	PopUpText.show_popup("Enemy attacked!")
	await PopUpText.popup_finished
	
	if target.health <= 0:
		check_battle_end()
	else:
		end_enemy_turn()

func end_enemy_turn():
	is_player_turn = true
	start_player_turn()

func check_battle_end():
	if enemy_team.size() == 0:
		print("Player wins!")
	elif player_team.size() == 0:
		print("Enemy wins!")

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
		if enemy.health <= 0:
			enemy_team.erase(enemy)
			enemy.queue_free()
		check_battle_end()
		end_player_turn()

func _on_item_pressed():
	PopUpText.show_popup("Item used!")
	await PopUpText.popup_finished
	# Add item logic here
	end_player_turn()

func _on_run_pressed():
	PopUpText.show_popup("Trying to run...")
	await PopUpText.popup_finished
	# Add run logic here
	end_player_turn()

func enable_buttons():
	attack_button.disabled = false
	item_button.disabled = false
	run_button.disabled = false
	
func disable_buttons():
	attack_button.disabled = true
	item_button.disabled = true
	run_button.disabled = true
	
