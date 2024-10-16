extends BaseScene

@onready var hearts_container = $CanvasLayer/hearts_container
@onready var camera = $follow_cam
@onready var stat_panel = $CanvasLayer/StatPanel

func _ready():
	super._ready()
	camera.follow_node = local_player
	hearts_container.set_max_hearts(local_player.max_health)
	hearts_container.update_hearts(local_player.current_health)
	local_player.health_changed.connect(hearts_container.update_hearts)

func _on_store_menu_gui_closed() -> void:
	get_tree().paused = false

func _on_store_menu_gui_opened() -> void:
	get_tree().paused = true
