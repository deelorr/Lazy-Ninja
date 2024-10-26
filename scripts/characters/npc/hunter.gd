extends CharacterBody2D
class_name HunterNPC

@export var npc_id: String = "hunter_npc"

@onready var dialogue_manager: DialogueManager = DialogueManager
@onready var quest_manager: QuestManager = QuestManager
@onready var hunter_dialogue: Resource = preload("res://dialogue/hunter.dialogue")
@onready var first_quest: Quest = preload("res://resources/quests/kill_da_slimez.tres")

func _on_area_2d_body_entered(player) -> void:
	if player.is_in_group("player"):
		DialogueManager.show_dialogue_balloon(hunter_dialogue, "start")
		#connect dialogue_ended signal so when dialogue ends, _on_dialogue_ended is called
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(_resource: DialogueResource):
	#disconnect so doesnt trigger multiple times
	DialogueManager.dialogue_ended.disconnect(Callable(self, "_on_dialogue_ended"))
	if QuestManager.quest_dialog_point == "started":
		QuestManager.add_quest(first_quest)
		QuestManager.quest_dialog_point = "in_progress"
	if QuestManager.quest_dialog_point == "finishing":
		QuestManager.quest_dialog_point = "complete"
	update_quests()

func update_quests():
	for quest in QuestManager.active_quests.values():
		if quest.status == quest.Status.IN_PROGRESS:
			for i in range(quest.objectives.size()):
				var obj = quest.objectives[i]
				if obj.type == "return" and obj.target == npc_id and not obj.completed:
					quest.complete_objective(i)
					return
		elif quest.status == quest.Status.COMPLETED:
			#do not reset quest_dialog_point if it's already 'complete'
			if QuestManager.quest_dialog_point != "complete":
				print_debug("Quest completed, but quest_dialog_point is ", QuestManager.quest_dialog_point)
			return
