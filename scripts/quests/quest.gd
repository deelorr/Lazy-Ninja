extends Resource
class_name Quest

# Enumeration for quest status
enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED,
	FAILED
}

# Quest properties
@export var quest_id: int
@export var title: String = "New Quest"
@export var description: String = "Describe the quest here."
@export var objectives: Array[QuestObjective] = []
@export var rewards: Dictionary = {}
var status: int = Status.NOT_STARTED

# Track the current objective index
var current_objective_index: int = -1  # -1 indicates no objective is active yet

# Signals
signal quest_started(quest_id)
signal quest_updated(quest_id, status)
signal quest_completed(quest_id)
signal quest_failed(quest_id)


signal current_objective_changed(quest_id, description)


# Methods
func start_quest():
	if status == Status.NOT_STARTED:
		status = Status.IN_PROGRESS
		emit_signal("quest_started", quest_id)
		emit_signal("quest_updated", quest_id, status)
		print("Quest Started: %s" % title)
		activate_next_objective()

func activate_next_objective():
	current_objective_index += 1
	if current_objective_index < objectives.size():
		var obj = objectives[current_objective_index]
		obj.active = true
		print("Objective %d Activated: %s" % [current_objective_index + 1, obj.description])
		emit_signal("current_objective_changed", quest_id, obj.description)  # Emit quest_id
	else:
		# All objectives completed
		complete_quest()

func complete_objective(objective_index: int):
	if status != Status.IN_PROGRESS:
		print("Quest is not in progress.")
		return

	if objective_index != current_objective_index:
		print("Cannot complete objective %d. Current active objective is %d." % [objective_index, current_objective_index])
		return

	var obj = objectives[objective_index]
	if obj.completed:
		print("Objective %d is already completed." % objective_index)
		return

	obj.completed = true
	obj.active = false
	print("Objective %d Completed: %s" % [objective_index + 1, obj.description])

	emit_signal("quest_updated", quest_id, status)

	activate_next_objective()

func fail_quest():
	if status == Status.IN_PROGRESS:
		status = Status.FAILED
		emit_signal("quest_failed", quest_id)
		emit_signal("quest_updated", quest_id, status)
		print("Quest Failed: %s" % title)

func complete_quest():
	status = Status.COMPLETED
	emit_signal("quest_completed", quest_id)
	emit_signal("quest_updated", quest_id, status)
	print("Quest Completed: %s" % title)
	grant_rewards()

func grant_rewards():
	# Implement reward granting logic here
	for key in rewards.keys():
		if key == "XP":
			scene_manager.player.add_xp(rewards[key])
		print("Granting %s: %s" % [key, rewards[key]])
	# Example: Add experience, items, etc.

func on_enemy_killed(enemy_type):
	# Check if the quest is currently active
	if status != Status.IN_PROGRESS:
		return  # If the quest is not in progress, there's no need to update anything
	if current_objective_index == -1 or current_objective_index >= objectives.size():
		return  # No active objective
	var obj = objectives[current_objective_index]
	if obj.type == "kill" and obj.target == enemy_type and not obj.completed:
		obj.current_count += 1
		print("Objective %d progress: %d / %d" % [current_objective_index + 1, obj.current_count, obj.target_count])
		if obj.current_count >= obj.target_count:
			complete_objective(current_objective_index)
