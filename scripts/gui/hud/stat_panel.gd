extends NinePatchRect

@onready var health_bar: ProgressBar = $Stats/Health/Label2/ProgressBar
@onready var quest_title: Label = $QuestPanel/Quests/HBoxContainer/quest_title
@onready var quest_objective: Label = $QuestPanel/Quests/quest_details/quest_objective
@onready var quest_progress: ProgressBar = $QuestPanel/Quests/quest_details/ProgressBar
@onready var quest_panel: NinePatchRect = $QuestPanel
@onready var level_label: Label = $Stats/Level/level_label

var player: Player = null

func _ready():
	player = SceneManager.player
	if QuestManager:
		QuestManager.connect("current_objective_changed", Callable(self, "_on_current_objective_changed"))
	else:
		print_debug("Error: QuestManager node not found.")
	quest_panel.visible = false

func _process(_delta):
	if player:
		update_quest_panel()
		update_level()
		update_health(player.current_health, player.max_health)

func update_health(health: int, max_health: int):
	health_bar.value = health
	health_bar.max_value = max_health

func update_quest_panel():
	quest_progress.visible = false
	if QuestManager.active_quests.size() > 0:
		quest_panel.visible = true
		var quest = QuestManager.active_quests.values()[0]
		quest_title.text = quest.title
		if QuestManager.current_objective_index < quest.objectives.size():
			var objective = quest.objectives[QuestManager.current_objective_index]
			quest_objective.text = objective.description
			quest_progress.visible = true
			quest_progress.value = objective.current_count
			quest_progress.max_value = objective.target_count
		else:
			quest_panel.visible = false

func update_level():
	if player:
		level_label.text = str(player.current_level)

func _on_current_objective_changed(quest_id, description):
	print_debug("Received current_objective_changed signal for Quest ID %d: %s" % [quest_id, description])
	quest_objective.text = description
