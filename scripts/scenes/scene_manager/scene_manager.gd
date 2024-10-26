#class_name SceneManager
extends Node

#added signal for player change
signal player_changed(new_player)

var player: Player
var last_scene_name: String
var scene_dir_path: String = "res://scenes/maps/"
var marker: String

var first_load: bool = true

func _init() -> void:
	if player == null:
		player = preload("res://scenes/characters/player.tscn").instantiate()
		player.position = Vector2(150,50)

func change_scene(from_scene, to_scene_name, connected_marker):
	last_scene_name = from_scene.name
	marker = connected_marker
	player = from_scene.player
	#emit signal to update player
	player_changed.emit(player)
	player.get_parent().remove_child(player)
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from_scene.get_tree().call_deferred("change_scene_to_file", full_path)
