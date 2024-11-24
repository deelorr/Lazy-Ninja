extends Node
class_name BaseScene

@onready var player: Player = SceneManager.player
@onready var entrance_markers: Node2D = $entrance_markers if has_node("entrance_markers") else null
@onready var camera: Camera2D = $follow_cam if has_node("follow_cam") else null

func _ready():
	if player:
		add_child(player)
		position_local_player()
		if camera:
			camera.follow_node = player

func position_local_player():
	if entrance_markers:
		var markers = entrance_markers.get_children()
		for marker in markers:
			if marker.name == SceneManager.marker:
				player.global_position = marker.global_position
				break

func _on_inventory_gui_closed() -> void:
	get_tree().paused = false

func _on_inventory_gui_opened() -> void:
	get_tree().paused = true
