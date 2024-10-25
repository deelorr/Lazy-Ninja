extends Area2D

@export var slime: PackedScene

func _on_spawn_timer_timeout() -> void:
	if not slime:
		print("Slime PackedScene is not assigned.")
		return
	if Global.slime_count < Global.max_slimes:
		var new_slime = slime.instantiate()
		var spawn_position = Vector2(265, 50) #spawn cave
		new_slime.position = spawn_position
		get_parent().add_child(new_slime)
		Global.slime_count += 1
		print("slime added", Global.slime_count, "/", Global.max_slimes)
	else:
		print("too many slimes")
