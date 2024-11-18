extends Node

var player: Player = null
var current_scene_name: String = ""
var last_scene_name: String = ""
var marker: String

func _init() -> void:
	if player == null:
		player = preload("res://scenes/characters/player.tscn").instantiate()
		player.position = Vector2(150,50)
		current_scene_name = "inside_house"

func change_scene(from_scene, to_scene, connected_marker):
	last_scene_name = from_scene.name
	current_scene_name = to_scene
	marker = connected_marker
	player = from_scene.player
	player.get_parent().remove_child(player)
	var full_path = "res://scenes/maps/" + to_scene + ".tscn"
	from_scene.get_tree().call_deferred("change_scene_to_file", full_path)
	
func get_current_scenes():
	print(last_scene_name, current_scene_name)
