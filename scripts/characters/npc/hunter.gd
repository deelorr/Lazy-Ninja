extends CharacterBody2D
class_name HunterNPC

@export var npc_id: String = "hunter_npc"

@onready var dialogue_manager: DialogueManager = DialogueManager
@onready var quest_manager: QuestManager = QuestManager
@onready var hunter_dialogue: Resource = preload("res://dialogue/hunter.dialogue")
@onready var first_quest: Quest = preload("res://resources/quests/kill_da_slimez.tres")
@onready var animations: AnimationPlayer = $AnimationPlayer

var player_in_area: bool = false

#func _ready() -> void:
	#set_process(true)  # Ensure _process is called
	
func _physics_process(_delta):
	if player_in_area and Input.is_action_just_pressed("action"):
		start_dialogue()
		Global.pause_game()

func _on_area_2d_body_entered(player) -> void:
	if player.is_in_group("player"):
		player_in_area = true
		animations.play("bubble_pop_up")

func start_dialogue():
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
			#do not reset quest_dialog_point if it's already 'complete'
			if QuestManager.quest_dialog_point != "complete":
				print_debug("Quest completed, but quest_dialog_point is ", QuestManager.quest_dialog_point)
			return

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		animations.play("bubble_pop_down")
