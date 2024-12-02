extends Area2D

@onready var slime_scene: PackedScene = preload("res://scenes/characters/enemies/green_slime.tscn")

var spawn_offset: Vector2 = Vector2(0, 5)

func _on_spawn_timer_timeout() -> void:
	if Global.slime_count < Global.max_slimes:
		var new_slime = slime_scene.instantiate()
		new_slime.position = position + spawn_offset
		get_parent().add_child(new_slime)
		Global.slime_count += 1
		print("slime added ", Global.slime_count, "/", Global.max_slimes)
	else:
		print("max slimes ", Global.slime_count, "/", Global.max_slimes)
