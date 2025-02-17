extends Resource
class_name Quest

# --------------------------------------------------------
# Enum: Status
# Defines the possible states a quest can be in.
# --------------------------------------------------------
enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED,
	FAILED
}

# --------------------------------------------------------
# Quest Properties
# --------------------------------------------------------

# Unique identifier for the quest.
@export var quest_id: int
# Title of the quest (displayed to the player).
@export var title: String = "New Quest"
# Detailed description of the quest.
@export var description: String = "Describe the quest here."
# Array of objectives that the player must complete.
@export var objectives: Array[QuestObjective] = []
# Dictionary of rewards to grant when the quest is completed.
@export var rewards: Dictionary = {}

# Tracks the current status of the quest.
var status: int = Status.NOT_STARTED

# --------------------------------------------------------
# Function: start_quest
# Purpose: Begins the quest by setting its status to IN_PROGRESS,
#          printing a start message, and activating the first objective.
# --------------------------------------------------------
func start_quest():
	if status == Status.NOT_STARTED:
		status = Status.IN_PROGRESS
		print("Quest Started: %s" % title)
		# Activate the first objective in the quest.
		activate_next_objective()
		# Update a global dialogue point (used for UI/dialogue updates).
		QuestManager.quest_dialog_point = "started"

# --------------------------------------------------------
# Function: activate_next_objective
# Purpose: Moves to the next objective in the quest. Increments
#          the global objective index and activates the next objective.
#          If no more objectives exist, completes the quest.
# --------------------------------------------------------
func activate_next_objective():
	# Increment the global objective index.
	QuestManager.current_objective_index += 1
	# Check if there is an objective at the new index.
	if QuestManager.current_objective_index < objectives.size():
		var obj = objectives[QuestManager.current_objective_index]
		obj.active = true  # Mark the objective as active.
		print("Objective %d Activated: %s" % [QuestManager.current_objective_index, obj.description])
	else:
		# All objectives are complete – finish the quest.
		complete_quest()

# --------------------------------------------------------
# Function: complete_objective
# Purpose: Marks a given objective as completed if it is currently active.
#          Validates the objective index and then proceeds to activate the next one.
# Parameter:
#   objective_index - The index of the objective to complete.
# --------------------------------------------------------
func complete_objective(objective_index: int):
	# Ensure the quest is currently active.
	if status != Status.IN_PROGRESS:
		print("Quest is not in progress.")
		return

	# Only allow completion if the objective index matches the current active objective.
	if objective_index != QuestManager.current_objective_index:
		print("Cannot complete objective %d. Current active objective is %d." % [objective_index, QuestManager.current_objective_index])
		return

	var obj = objectives[objective_index]
	# If this objective is already completed, do nothing.
	if obj.completed:
		print("Objective %d is already completed." % objective_index)
		return

	# Mark the objective as completed and deactivate it.
	obj.completed = true
	obj.active = false
	print("Objective %d Completed: %s" % [objective_index, obj.description])

	# Activate the next objective (if any).
	activate_next_objective()

# --------------------------------------------------------
# Function: fail_quest
# Purpose: Fails the quest by changing its status to FAILED and 
#          printing a failure message.
# --------------------------------------------------------
func fail_quest():
	if status == Status.IN_PROGRESS:
		status = Status.FAILED
		print("Quest Failed: %s" % title)

# --------------------------------------------------------
# Function: complete_quest
# Purpose: Completes the quest by setting its status to COMPLETED,
#          printing a completion message, and granting rewards.
# --------------------------------------------------------
func complete_quest():
	status = Status.COMPLETED
	print("Quest Completed: %s" % title)
	grant_rewards()

# --------------------------------------------------------
# Function: grant_rewards
# Purpose: Iterates through the rewards dictionary and grants each reward
#          to the player. Rewards may include XP, items, or other custom rewards.
# --------------------------------------------------------
func grant_rewards():
	for key in rewards.keys():
		if key == "XP":
			# Add XP to the player's progression.
			SceneManager.player.progression.add_xp(rewards[key])
		elif key == "Items":
			# Insert item(s) into the player's inventory.
			SceneManager.player.inventory.add_item(rewards[key])
			print(rewards[key].name, " inserted into Inventory")
		else:
			# Print or handle any other reward types.
			print("Granting %s: %s" % [key, rewards[key]])

# --------------------------------------------------------
# Function: on_enemy_killed
# Purpose: Called when an enemy is killed. Checks if the current active
#          objective is a kill-type objective matching the enemy_type,
#          updates progress, and completes the objective if requirements are met.
# Parameter:
#   enemy_type - The identifier/type of the enemy that was killed.
# --------------------------------------------------------
func on_enemy_killed(enemy_type):
	# Process only if the quest is active.
	if status != Status.IN_PROGRESS:
		return
	# Validate that the current objective index is within range.
	if QuestManager.current_objective_index == -1 or QuestManager.current_objective_index >= objectives.size():
		return

	var obj = objectives[QuestManager.current_objective_index]
	# Check if the active objective is a kill objective and if it targets the killed enemy.
	if obj.type == "kill" and obj.target == enemy_type and not obj.completed:
		# Increase the count of kills for this objective.
		obj.current_count += 1
		print("Objective %d progress: %d / %d" % [QuestManager.current_objective_index, obj.current_count, obj.target_count])
		# If the kill count meets or exceeds the required count, mark the objective as complete.
		if obj.current_count >= obj.target_count:
			complete_objective(QuestManager.current_objective_index)
			# If this was the final objective, update the dialogue point to indicate the quest is finishing.
			if QuestManager.current_objective_index >= objectives.size() - 1:
				QuestManager.quest_dialog_point = "finishing"
