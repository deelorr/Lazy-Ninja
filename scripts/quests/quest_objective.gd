extends Resource
class_name QuestObjective

@export var type: String = "kill"
@export var target: String = ""
@export var target_count: int = 1
@export var description: String = "Describe the objective here."

var current_count: int = 0
var completed: bool = false
var active: bool = false
