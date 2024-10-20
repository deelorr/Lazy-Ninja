extends NinePatchRect

@onready var gold_label = $Stats/Gold/gold_label
@onready var health_bar = $Stats/Health/Label2/ProgressBar
@onready var quest_title = $QuestPanel/Quests/HBoxContainer/quest_title
@onready var quest_objective = $QuestPanel/Quests/quest_details/quest_objective
@onready var quest_progress = $QuestPanel/Quests/quest_details/ProgressBar
@onready var quest_panel = $QuestPanel
@onready var level_label = $Stats/Level/level_label

var player: Player = null

func _ready():
	if quest_manager:
		quest_manager.connect("current_objective_changed", Callable(self, "_on_current_objective_changed"))
		print("Connected to QuestManager's current_objective_changed signal.")
	else:
		print("Error: QuestManager node not found.")
	quest_panel.visible = false
	#connect to player_changed signal
	scene_manager.player_changed.connect(_on_player_changed)
	#check if player is already set
	if scene_manager.player:
		_on_player_changed(scene_manager.player)
	else:
		print("StatPanel: Waiting for player_changed signal")

func _process(_delta):
	update_quest_panel()
	update_level()
	#update_quest_description()

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

func update_quest_panel():
	quest_progress.visible = false
	if quest_manager.active_quests.size() > 0:
		quest_panel.visible = true
		var quest = quest_manager.active_quests.values()[0]
		quest_title.text = quest.title
		if quest_manager.current_objective_index < quest.objectives.size():
			var objective = quest.objectives[quest_manager.current_objective_index]
			quest_objective.text = objective.description
			quest_progress.visible = true
			quest_progress.value = objective.current_count
			quest_progress.max_value = objective.target_count
		else:
			quest_panel.visible = false
			
func update_level():
	level_label.text = str(player.current_level)

#func update_quest_description():
	#if quest_manager.active_quests.size() > 0:
		#var quest = quest_manager.active_quests.values()[0]
		#var objective = quest.objectives[0]
		#if quest_manager.active_quests.values()[0].objectives[0].completed == true:
			#objective = quest.objectives[1]

func _on_current_objective_changed(quest_id, description):
	print("Received current_objective_changed signal for Quest ID %d: %s" % [quest_id, description])
	quest_objective.text = description
