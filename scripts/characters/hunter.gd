extends CharacterBody2D

class_name HunterNPC

@export var npc_id: String = "hunter_npc"

var kill_da_slimez = preload("res://resources/quests/kill_da_slimez.tres")

func _on_area_2d_body_entered(body) -> void:
	if body is CharacterBody2D:
		_interact_with_player(body)
		if not quest_manager.active_quests.has(kill_da_slimez.quest_id):
			quest_manager.add_quest(kill_da_slimez)

func _interact_with_player(_player: Player):
	# Check if the player has an active quest that requires returning to this NPC
	for quest in quest_manager.active_quests.values():
		for i in range(quest.objectives.size()):
			var obj = quest.objectives[i]
			if obj.type == "return" and obj.target == npc_id and not obj.completed:
				# Mark the return objective as complete
				quest.complete_objective(i)
				print("Returned to Hunter: Objective %d completed." % (i + 1))
				# Optionally, notify the player or grant rewards
				return
