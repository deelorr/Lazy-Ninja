extends Area2D
class_name SceneTrigger

@export var connected_scene: String
@export var connected_marker: String

var scene_folder: String = "res://scenes/maps/"

func _on_body_entered(body):
	if body is Player:
		SceneManager.change_scene(get_tree().current_scene, connected_scene, connected_marker)
