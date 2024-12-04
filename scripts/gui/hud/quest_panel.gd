extends NinePatchRect

@onready var quest_title: Label = $Quests/HBoxContainer/quest_title
@onready var quest_objective: Label = $Quests/quest_details/quest_objective
@onready var quest_progress: ProgressBar = $Quests/quest_details/ProgressBar
@onready var player: Player = SceneManager.player

func _ready():
	if QuestManager:
		QuestManager.connect("current_objective_changed", Callable(self, "_on_current_objective_changed"))
	
func _process(_delta):
	if player:
		update_quest_panel()
	
func update_quest_panel():
	quest_progress.visible = false
	if QuestManager.active_quests.size() > 0:
		self.visible = true
		var quest = QuestManager.active_quests.values()[0]
		quest_title.text = quest.title
		if QuestManager.current_objective_index < quest.objectives.size():
			var objective = quest.objectives[QuestManager.current_objective_index]
			quest_objective.text = objective.description
			quest_progress.visible = true
			quest_progress.value = objective.current_count
			quest_progress.max_value = objective.target_count
		else:
			self.visible = false
			
func _on_current_objective_changed(quest_id, description):
	print_debug("Received current_objective_changed signal for Quest ID %d: %s" % [quest_id, description])
	quest_objective.text = description
