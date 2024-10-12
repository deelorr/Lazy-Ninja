extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("fade_in")
	await get_tree().create_timer(3).timeout
	$AnimationPlayer.play("fade_out")
	await get_tree().create_timer(3).timeout
	$AnimationPlayer.play("fade_in_title")
	await get_tree().create_timer(3).timeout
	$AnimationPlayer.play("fade_out_title")
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://scenes/maps/world.tscn")
