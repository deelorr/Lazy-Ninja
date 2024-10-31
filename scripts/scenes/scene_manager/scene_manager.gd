extends Node

signal player_changed(new_player)

var player: Player = null
var last_scene_name: String = ""
var scene_dir_path: String = "res://scenes/maps/"
var marker: String

func _init() -> void:
	if player == null:
		player = preload("res://scenes/characters/player.tscn").instantiate()
		player.position = Vector2(150,50)

func change_scene(from_scene, to_scene, connected_marker):
	last_scene_name = from_scene.name
	marker = connected_marker
	player = from_scene.player
	player_changed.emit(player) #emit signal to update player
	player.get_parent().remove_child(player)
	var full_path = scene_dir_path + to_scene + ".tscn"
	from_scene.get_tree().call_deferred("change_scene_to_file", full_path)
