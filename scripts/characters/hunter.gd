extends CharacterBody2D

class_name HunterNPC

@export var npc_id: String = "hunter_npc"

@onready var dialogue_manager: DialogueManager = DialogueManager
@onready var quest_manager: QuestManager = QuestManager
@onready var hunter_dialogue: Resource = preload("res://dialogue/hunter.dialogue")

var kill_da_slimez = preload("res://resources/quests/kill_da_slimez.tres")

func _on_area_2d_body_entered(body: Node) -> void:
	if body is Player:
		DialogueManager.show_dialogue_balloon(hunter_dialogue, "start")
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		_interact_with_player(body)

func _on_dialogue_ended(_sresource):
	DialogueManager.dialogue_ended.disconnect(Callable(self, "_on_dialogue_ended"))
	if QuestManager.quest_dialog_point == "started":
		QuestManager.add_quest(kill_da_slimez)
		QuestManager.quest_dialog_point = "in_progress"
	if QuestManager.quest_dialog_point == "finishing":
		QuestManager.quest_dialog_point = "complete"

func _interact_with_player(_player: Player):
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
				print("Quest is completed. quest_dialog_point is '%s'" % QuestManager.quest_dialog_point)
			return
