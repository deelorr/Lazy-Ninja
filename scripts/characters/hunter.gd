extends CharacterBody2D

var kill_da_slimez = preload("res://resources/quests/kill_da_slimez.tres")

func _on_area_2d_body_entered(body) -> void:
	if body is CharacterBody2D:
		quest_manager.add_quest(kill_da_slimez)
		print("Goal 1:", quest_manager.active_quests[0].objectives[0].description)
		print("Done", quest_manager.active_quests[0].objectives[0].completed)
		print("Goal 2:", quest_manager.active_quests[0].objectives[1].description)
		print("Done", quest_manager.active_quests[0].objectives[1].completed)
		print("Rewards:", quest_manager.active_quests[0].rewards)

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
