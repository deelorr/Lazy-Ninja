extends CharacterBody2D

class_name HunterNPC

@export var npc_id: String = "hunter_npc"

var kill_da_slimez = preload("res://resources/quests/kill_da_slimez.tres")

func _on_area_2d_body_entered(body) -> void:
	if body is CharacterBody2D:
		quest_manager.add_quest(kill_da_slimez)

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
