extends Resource
class_name QuestObjective

@export var description: String = ""
@export var completed: bool = false
@export var type: String = ""  # e.g., "kill", "collect", "return"
@export var target: String = ""  # e.g., "slime", "hunter_npc"
@export var target_count: int = 0  # Relevant for "kill" type
var current_count: int = 0  # Relevant for "kill" type

# For "return" type, you might not need current_count
