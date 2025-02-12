extends CharacterBody2D
class_name HunterNPC

@export var npc_id: String = "hunter_npc"

@onready var dialogue_manager: DialogueManager = DialogueManager
@onready var quest_manager: QuestManager = QuestManager
@onready var hunter_dialogue: Resource = preload("res://dialogue/hunter.dialogue")
@onready var first_quest: Quest = preload("res://resources/quests/kill_da_slimez.tres")
@onready var animations: AnimationPlayer = $AnimationPlayer

var player_in_area: bool = false
var dialogue_active: bool = false  # New flag to prevent multiple dialogues

func _physics_process(_delta):
	if player_in_area and Input.is_action_just_pressed("action") and not dialogue_active:
		start_dialogue()

func _on_area_2d_body_entered(player) -> void:
	if player.is_in_group("player"):
		player_in_area = true
		animations.play("bubble_pop_up")

func start_dialogue():
	if dialogue_active:
		return  # Prevent multiple instances from being triggered

	dialogue_active = true  # Set flag before starting dialogue
	Global.pause_game()
	DialogueManager.show_dialogue_balloon(hunter_dialogue, "start")

	# Ensure signal is only connected once
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(_resource: DialogueResource):
	# Disconnect signal to prevent stacking
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

	dialogue_active = false  # Allow new dialogue to start after finishing

	if QuestManager.quest_dialog_point == "started":
		QuestManager.add_quest(first_quest)
		QuestManager.quest_dialog_point = "in_progress"
	elif QuestManager.quest_dialog_point == "finishing":
		QuestManager.quest_dialog_point = "complete"

	update_quests()
	Global.resume_game()

func update_quests():
	for quest in QuestManager.active_quests.values():
		if quest.status == quest.Status.IN_PROGRESS:
			for i in range(quest.objectives.size()):
				var obj = quest.objectives[i]
				if obj.type == "return" and obj.target == npc_id and not obj.completed:
					quest.complete_objective(i)
					return
		elif quest.status == quest.Status.COMPLETED:
			if QuestManager.quest_dialog_point != "complete":
				print_debug("Quest completed, but quest_dialog_point is ", QuestManager.quest_dialog_point)
			return

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		animations.play("bubble_pop_down")
