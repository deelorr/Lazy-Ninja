class_name BaseScene
extends Node

@onready var local_player: Player = $Player
@onready var entrance_markers: Node2D = $entrance_markers

func _ready():
	
	if scene_manager.first_load:
		if local_player:
			if local_player:
				scene_manager.player = local_player
				scene_manager.player_changed.emit(local_player)
		scene_manager.first_load = false
	else:
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
		print_debug("last scene was empty, setting to world")
		last_scene = "world"
	print_debug("Last scene: ", last_scene)
	print_debug("Markers:", markers)
	for marker in markers:
		if marker.name == scene_manager.marker:
			local_player.global_position = marker.global_position
			print_debug("local_player moved to marker:", marker.name)
			break
