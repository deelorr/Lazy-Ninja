# Quest.gd
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
@export var objectives: Array = []
@export var rewards: Dictionary = {}
var status: int = Status.NOT_STARTED

# Signals
signal quest_started(quest_id)
signal quest_updated(quest_id, status)
signal quest_completed(quest_id)
signal quest_failed(quest_id)

# Methods
func start_quest():
	if status == Status.NOT_STARTED:
		status = Status.IN_PROGRESS
		emit_signal("quest_started", quest_id)
		emit_signal("quest_updated", quest_id, status)
		print("Quest Started: %s" % title)

func complete_objective(objective_index: int):
	if status != Status.IN_PROGRESS:
		print("Quest is not in progress.")
		return

	if objective_index < 0 or objective_index >= objectives.size():
		print("Invalid objective index.")
		return

	objectives[objective_index].completed = true
	print("Objective %d completed." % objective_index)

	if check_completion():
		complete_quest()

func check_completion() -> bool:
	for obj in objectives:
		if not obj.completed:
			return false
	return true

func complete_quest():
	status = Status.COMPLETED
	emit_signal("quest_completed", quest_id)
	emit_signal("quest_updated", quest_id, status)
	print("Quest Completed: %s" % title)
	grant_rewards()

func fail_quest():
	if status == Status.IN_PROGRESS:
		status = Status.FAILED
		emit_signal("quest_failed", quest_id)
		emit_signal("quest_updated", quest_id, status)
		print("Quest Failed: %s" % title)

func grant_rewards():
	# Implement reward granting logic here
	for key in rewards.keys():
		print("Granting %s: %s" % [key, rewards[key]])
	# Example: Add experience, items, etc.
