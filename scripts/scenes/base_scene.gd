class_name BaseScene
extends Node

@onready var player: Player = $Player
@onready var entrance_markers: Node2D = $entrance_markers

func _ready():
	
	if scene_manager.first_load:
		if scene_manager.player:
			if player:
				player.queue_free()
			player = scene_manager.player
			add_child(player)
		scene_manager.first_load = false

	elif !scene_manager.first_load:
		if scene_manager.player:
			if player:
				player.queue_free()
			player = scene_manager.player
			add_child(player)
		position_player()

func position_player():
	var markers = entrance_markers.get_children()
	var last_scene = scene_manager.last_scene_name.to_lower().replace('_', '').replace(' ', '')
	if last_scene.is_empty():
		print_debug("last scene was empty, setting to world")
		last_scene = "world"
	print_debug("Last scene: ", last_scene)
	print_debug("Markers:", markers)
	for marker in markers:
		if marker.name == scene_manager.marker:
			player.global_position = marker.global_position
			print_debug("Player moved to marker:", marker.name)
			break
