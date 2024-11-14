extends Node2D

var player_team: Array = []
var enemy_team: Array = []
var is_player_turn: bool = true

@onready var attack_button: Button = $CanvasLayer/battle_menu/VBoxContainer/Attack
@onready var item_button: Button = $CanvasLayer/battle_menu/VBoxContainer/Item
@onready var run_button: Button = $CanvasLayer/battle_menu/VBoxContainer/Run

func _ready():
    player_team = $player_team.get_children()
    print("got team")
    enemy_team = $enemy_team.get_children()
    print("got enemies")
    start_battle()

func start_battle():
    var coin_toss = randi() % 2
    is_player_turn = coin_toss == 0
    if is_player_turn:
        print("Player's turn")
        start_player_turn()
    else:
        print("Enemy's turn")
        start_enemy_turn()

func start_player_turn():
    # Enable buttons for the player
    attack_button.disabled = false
    item_button.disabled = false
    run_button.disabled = false
    print("Choose an action!")

func end_player_turn():
    is_player_turn = false
    attack_button.disabled = true
    item_button.disabled = true
    run_button.disabled = true
    start_enemy_turn()

func start_enemy_turn():
    print("Enemy's turn...")
    await get_tree().create_timer(1.0).timeout
    var target = player_team[randi() % player_team.size()]
    target.take_damage(10)
    print("Enemy attacked!")
    if target.health <= 0:
        check_battle_end()
    else:
        end_enemy_turn()

func end_enemy_turn():
    is_player_turn = true
    start_player_turn()

func _on_Attack_pressed():
    if is_player_turn:
        var target = enemy_team[0]  # Example: attack the first enemy
        target.take_damage(15)
        print("Attacked enemy!")
        if target.health <= 0:
            enemy_team.erase(target)
            target.queue_free()
            check_battle_end()
        end_player_turn()

func _on_Item_pressed():
    print("Item used!")
    # Add item logic here
    end_player_turn()

func _on_Run_pressed():
    print("Trying to run...")
    # Add run logic here

func check_battle_end():
    if enemy_team.size() == 0:
        print("Player wins!")
    elif player_team.size() == 0:
        print("Enemy wins!")
