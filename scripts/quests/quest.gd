extends Resource
class_name Quest

enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED,
	FAILED
}

@export var quest_id: int
@export var title: String = "New Quest"
@export var description: String = "Describe the quest here."
@export var objectives: Array[QuestObjective] = []
@export var rewards: Dictionary = {}

var status: int = Status.NOT_STARTED

func start_quest():
	if status == Status.NOT_STARTED:
		status = Status.IN_PROGRESS
		print("Quest Started: %s" % title)
		activate_next_objective()
		QuestManager.quest_dialog_point = "started"

func activate_next_objective():
	QuestManager.current_objective_index += 1
	if QuestManager.current_objective_index < objectives.size():
		var obj = objectives[QuestManager.current_objective_index]
		obj.active = true
		print("Objective %d Activated: %s" % [QuestManager.current_objective_index, obj.description])
	else:
		#all objectives completed
		complete_quest()

func complete_objective(objective_index: int):
	if status != Status.IN_PROGRESS:
		print("Quest is not in progress.")
		return

	if objective_index != QuestManager.current_objective_index:
		print("Cannot complete objective %d. Current active objective is %d." % [objective_index, QuestManager.current_objective_index])
		return

	var obj = objectives[objective_index]
	if obj.completed:
		print("Objective %d is already completed." % objective_index)
		return

	obj.completed = true
	obj.active = false
	print("Objective %d Completed: %s" % [objective_index, obj.description])

	activate_next_objective()

func fail_quest():
	if status == Status.IN_PROGRESS:
		status = Status.FAILED
		print("Quest Failed: %s" % title)

func complete_quest():
	status = Status.COMPLETED
	print("Quest Completed: %s" % title)
	grant_rewards()

func grant_rewards():
	for key in rewards.keys():
		if key == "XP":
			SceneManager.player.add_xp(rewards[key])
		elif key == "Items":
			SceneManager.player.inventory.insert(rewards[key])
			print(rewards[key].name, " inserted into Inventory")
		else:
			print("Granting %s: %s" % [key, rewards[key]])

func on_enemy_killed(enemy_type):
	if status != Status.IN_PROGRESS:
		return
	if QuestManager.current_objective_index == -1 or QuestManager.current_objective_index >= objectives.size():
		return
	var obj = objectives[QuestManager.current_objective_index]
	if obj.type == "kill" and obj.target == enemy_type and not obj.completed:
		obj.current_count += 1
		print("Objective %d progress: %d / %d" % [QuestManager.current_objective_index, obj.current_count, obj.target_count])
		if obj.current_count >= obj.target_count:
			complete_objective(QuestManager.current_objective_index)
			if QuestManager.current_objective_index >= objectives.size() -1:
				QuestManager.quest_dialog_point = "finishing"
