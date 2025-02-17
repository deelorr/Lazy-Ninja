extends Node

# --------------------------------------------------------
# Signal: current_objective_changed
# Emitted when the current active objective is changed. Useful for UI updates.
# --------------------------------------------------------
signal current_objective_changed(quest_id, description)

# --------------------------------------------------------
# QuestManager Properties
# --------------------------------------------------------

# Dictionary to hold all active quests (keyed by quest_id).
var active_quests: Dictionary = {}
# Global string to represent the current quest dialogue point (e.g., "not_started", "started", "finishing").
var quest_dialog_point: String = "not_started"
# Global index that tracks the current active objective. 
# (Note: For multiple simultaneous quests, consider managing this per quest.)
var current_objective_index: int = -1

# --------------------------------------------------------
# Function: _ready
# Purpose: Called when the node is added to the scene. Sets up connections 
#          with global signals such as "enemy_killed".
# --------------------------------------------------------
func _ready():
	# Connect the global "enemy_killed" signal to the local _on_enemy_killed method.
	Global.connect("enemy_killed", Callable(_on_enemy_killed))

# --------------------------------------------------------
# Function: add_quest
# Purpose: Adds a new quest to the active quests dictionary and starts it.
# Parameter:
#   quest - The Quest resource to be added.
# --------------------------------------------------------
func add_quest(quest: Quest):
	if not active_quests.has(quest.quest_id):
		active_quests[quest.quest_id] = quest
		quest.start_quest()
	else:
		print("Quest with ID %d already exists." % quest.quest_id)

# --------------------------------------------------------
# Function: complete_objective
# Purpose: Completes a specified objective for a given quest.
# Parameters:
#   quest_id - The unique identifier for the quest.
#   objective_index - The index of the objective to mark as complete.
# --------------------------------------------------------
func complete_objective(quest_id: int, objective_index: int):
	if active_quests.has(quest_id):
		active_quests[quest_id].complete_objective(objective_index)
	else:
		print("Quest with ID %d not found." % quest_id)

# --------------------------------------------------------
# Function: fail_quest
# Purpose: Fails the quest with the given quest_id.
# Parameter:
#   quest_id - The unique identifier for the quest to fail.
# --------------------------------------------------------
func fail_quest(quest_id: int):
	if active_quests.has(quest_id):
		active_quests[quest_id].fail_quest()
	else:
		print("Quest with ID %d not found." % quest_id)
		
# --------------------------------------------------------
# Function: _on_enemy_killed
# Purpose: Global callback that is triggered when any enemy is killed.
#          It forwards the event to all active quests so they can update their progress.
# Parameter:
#   enemy_type - The type/identifier of the enemy that was killed.
# --------------------------------------------------------
func _on_enemy_killed(enemy_type):
	for quest in active_quests.values():
		quest.on_enemy_killed(enemy_type)
		
# --------------------------------------------------------
# Function: _on_current_objective_changed
# Purpose: Emits a signal to notify listeners that the current objective has changed.
# Parameters:
#   quest_id - The unique identifier for the quest.
#   description - A description of the new current objective.
# --------------------------------------------------------
func _on_current_objective_changed(quest_id, description):
	current_objective_changed.emit(quest_id, description)
