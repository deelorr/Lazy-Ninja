extends Resource
class_name QuestObjective

# --------------------------------------------------------
# QuestObjective Properties
# --------------------------------------------------------

# Type of objective (e.g., "kill", "collect", etc.).
@export var type: String = "kill"
# The target of the objective. For kill-type objectives, this would be the enemy type.
@export var target: String = ""
# Number of targets required to complete the objective.
@export var target_count: int = 1
# A description that explains what the objective requires.
@export var description: String = "Describe the objective here."

# Tracks the current progress (e.g., how many enemies have been killed).
var current_count: int = 0
# Flag to indicate whether the objective is completed.
var completed: bool = false
# Flag to indicate whether this objective is currently active.
var active: bool = false
