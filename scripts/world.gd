extends Node2D

@onready var hearts_container = $CanvasLayer/hearts_container
@onready var player = $TileMap/Player

func _ready():
	hearts_container.set_max_hearts(player.max_health)
	hearts_container.update_hearts(player.current_health)
	player.healthChanged.connect(hearts_container.update_hearts)

func _process(_delta):
	pass

func _on_inventory_gui_closed() -> void:
	get_tree().paused = false

func _on_inventory_gui_opened() -> void:
	get_tree().paused = true
