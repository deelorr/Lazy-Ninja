extends NinePatchRect

@onready var health_bar: ProgressBar = $Stats/Health/Label2/ProgressBar
@onready var level_label: Label = $Stats/Level/level_label
@onready var level_progress: ProgressBar = $Stats/Level/Label/ProgressBar
@onready var player: Player = SceneManager.player

func _process(_delta):
	if player:
		update_level_progress(player.current_xp, player.xp_for_next_level)
		update_health(player.current_health, player.max_health)

func update_health(health: int, max_health: int):
	health_bar.value = health
	health_bar.max_value = max_health

func update_level_progress(current_xp: int, xp_for_next_level: int):
	level_progress.value = current_xp
	level_progress.max_value = xp_for_next_level
	level_label.text = str(player.current_level)
