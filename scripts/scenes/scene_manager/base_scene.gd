class_name BaseScene
extends Node

@onready var local_player: Player
@onready var entrance_markers: Node2D = $entrance_markers
@onready var scene_manager: SceneManager = SceneManager

func _ready():
	if scene_manager.player:
		if local_player and local_player != scene_manager.player:
			local_player.queue_free()
		local_player = scene_manager.player
		add_child(local_player)
		position_local_player()
		scene_manager.player_changed.emit(local_player)

func position_local_player():
	var markers = entrance_markers.get_children()
	var last_scene = scene_manager.last_scene_name.to_lower().replace('_', '').replace(' ', '')
	if last_scene.is_empty():
		print_debug("last scene was empty")
	for marker in markers:
		if marker.name == scene_manager.marker:
			local_player.global_position = marker.global_position
			break
