extends Node

signal current_objective_changed(quest_id, description)

var active_quests: Dictionary = {} #key is quest_id
var quest_dialog_point: String = "not_started"
var current_objective_index: int = -1

func _ready():
	Global.connect("enemy_killed", Callable(_on_enemy_killed))

func add_quest(quest: Quest):
	if not active_quests.has(quest.quest_id):
		active_quests[quest.quest_id] = quest
		quest.start_quest()
	else:
		print("Quest with ID %d already exists." % quest.quest_id)

func complete_objective(quest_id: int, objective_index: int):
	if active_quests.has(quest_id):
		active_quests[quest_id].complete_objective(objective_index)
	else:
		print("Quest with ID %d not found." % quest_id)

func fail_quest(quest_id: int):
	if active_quests.has(quest_id):
		active_quests[quest_id].fail_quest()
	else:
		print("Quest with ID %d not found." % quest_id)
		
func _on_enemy_killed(enemy_type):
	for quest in active_quests.values():
		quest.on_enemy_killed(enemy_type)
		
func _on_current_objective_changed(quest_id, description):
	current_objective_changed.emit(quest_id, description)
