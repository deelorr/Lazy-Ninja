extends NinePatchRect

@onready var gold_label = $VBoxContainer/Gold/gold_label
@onready var health_bar = $VBoxContainer/Health/Label2/ProgressBar

var player: Player = null

func _ready():
	#connect to player_changed signal
	scene_manager.player_changed.connect(_on_player_changed)
	#check if player is already set
	if scene_manager.player:
		_on_player_changed(scene_manager.player)
	else:
		print("StatPanel: Waiting for player_changed signal")

func _on_player_changed(new_player):
	if player and is_instance_valid(player):
		# Disconnect previous signals
		if player.health_changed.is_connected(_on_health_changed):
			player.health_changed.disconnect(_on_health_changed)
		if player.gold_changed.is_connected(_on_gold_changed):
			player.gold_changed.disconnect(_on_gold_changed)
	player = new_player
	if player:
		# Connect to player's signals using Godot 4.3 syntax
		player.health_changed.connect(_on_health_changed)
		player.gold_changed.connect(_on_gold_changed)
		# Update UI elements
		update_health(player.current_health, player.max_health)
		update_gold()
	else:
		print("StatPanel: Player reference is null in _on_player_changed")

func _on_health_changed(new_health):
	update_health(new_health, player.max_health)

func _on_gold_changed(_new_gold):
	update_gold()

func update_health(health: int, max_health: int):
	health_bar.value = health
	health_bar.max_value = max_health

func update_gold():
	if player:
		gold_label.text = str(player.gold)
