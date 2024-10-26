extends Node
class_name BaseScene

@onready var player: Player
@onready var entrance_markers: Node2D = $entrance_markers
@onready var scene_manager: SceneManager = SceneManager
@onready var camera: Camera2D = $follow_cam

func _ready():
	if scene_manager.player:
		if player and player != scene_manager.player:
			player.queue_free()
		player = scene_manager.player
		add_child(player)
		position_local_player()
		scene_manager.player_changed.emit(player)
		camera.follow_node = player

func position_local_player():
	var markers = entrance_markers.get_children()
	var last_scene = scene_manager.last_scene_name.to_lower().replace('_', '').replace(' ', '')
	if last_scene.is_empty():
		print_debug("last scene was empty")
	for marker in markers:
		if marker.name == scene_manager.marker:
			player.global_position = marker.global_position
			break

func _on_inventory_gui_closed() -> void:
	get_tree().paused = false

func _on_inventory_gui_opened() -> void:
	get_tree().paused = true
