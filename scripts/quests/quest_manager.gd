extends Node
class_name QuestManager

#key is quest_id
var active_quests: Dictionary = {}

#global for dialogue
var quest_dialog_point: String = "not_started" # "not_started", started", "in_progress", "finishing", "complete"

signal quest_started(quest_id)
signal quest_updated(quest_id, status)
signal quest_completed(quest_id)
signal quest_failed(quest_id)
signal current_objective_changed(quest_id, description)

var current_objective_index: int = -1

func _ready():
	Global.connect("enemy_killed", Callable(_on_enemy_killed))

func add_quest(quest: Quest):
	if not active_quests.has(quest.quest_id):
		active_quests[quest.quest_id] = quest
		quest.connect("quest_started", Callable(self, "_on_quest_started"))
		quest.connect("quest_updated", Callable(self, "_on_quest_updated"))
		quest.connect("quest_completed", Callable(self, "_on_quest_completed"))
		quest.connect("quest_failed", Callable(self, "_on_quest_failed"))
		quest.connect("current_objective_changed", Callable(self, "_on_current_objective_changed"))
		quest.start_quest()
	else:
		print("Quest with ID %d already exists." % quest.quest_id)

func _on_quest_started(quest_id):
	emit_signal("quest_started", quest_id)

func _on_quest_updated(quest_id, status):
	emit_signal("quest_updated", quest_id, status)

func _on_quest_completed(quest_id):
	emit_signal("quest_completed", quest_id)
	#remove completed quests
	# active_quests.erase(quest_id)

func _on_quest_failed(quest_id):
	emit_signal("quest_failed", quest_id)
	#handle failed quests

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
