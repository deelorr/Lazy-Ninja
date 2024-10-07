class_name SceneManager
extends Node

var player: Player
var last_scene_name: String
var scene_dir_path: String = "res://scenes/maps/"

func change_scene(from_scene, to_scene_name):
	last_scene_name = from_scene.name
	player = from_scene.player
	player.get_parent().remove_child(player)
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from_scene.get_tree().call_deferred("change_scene_to_file", full_path)
