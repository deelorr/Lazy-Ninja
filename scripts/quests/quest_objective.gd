# QuestObjective.gd
extends Resource
class_name QuestObjective

enum ObjectiveType {
	KILL,
	COLLECT,
	TALK,
}

@export var type: String = "kill"  # e.g., "kill", "collect", etc.
@export var target: String = ""
@export var target_count: int = 1
var current_count: int = 0
var completed: bool = false
var active: bool = false
@export var description: String = "Describe the objective here."


func activate():
	# Logic when the objective becomes active
	pass
