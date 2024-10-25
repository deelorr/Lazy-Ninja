class_name BaseScene
extends Node

@onready var local_player: Player = $Player
@onready var entrance_markers: Node2D = $entrance_markers

func _ready():
	if SceneManager.first_load:
		if local_player:
			SceneManager.player = local_player
			SceneManager.player_changed.emit(local_player)
		SceneManager.first_load = false
	else:
		if SceneManager.player:
			if local_player and local_player != SceneManager.player:
				local_player.queue_free()
			local_player = SceneManager.player
			add_child(local_player)
		position_local_player()
		SceneManager.player_changed.emit(local_player)


func position_local_player():
	var markers = entrance_markers.get_children()
	var last_scene = SceneManager.last_scene_name.to_lower().replace('_', '').replace(' ', '')
	if last_scene.is_empty():
		#print_debug("last scene was empty, setting to world")
		last_scene = "world"
	#print_debug("Last scene: ", last_scene)
	#print_debug("Markers:", markers)
	for marker in markers:
		if marker.name == SceneManager.marker:
			local_player.global_position = marker.global_position
			#print_debug("local_player moved to marker:", marker.name)
			break
