extends Node

signal enemy_killed(enemy_type)

var slime_count: int = 0
var max_slimes: int = 10

var beast_count: int = 0
var max_beasts: int = 3

var spider_count: int = 0
var max_spiders: int = 5

var is_game_paused = false

func pause_game():
	if is_game_paused:
		return
	is_game_paused = true

	var gameplay_nodes = get_tree().get_nodes_in_group("gameplay")
	for node in gameplay_nodes:
		if node is Node:
			node.set_process(false)
			node.set_physics_process(false)
			node.set_process_input(false)
			node.set_process_unhandled_input(false)
			node.set_process_unhandled_key_input(false)
		if node is Timer:
			node.stop()

func resume_game():
	if not is_game_paused:
		return
	is_game_paused = false

	var gameplay_nodes = get_tree().get_nodes_in_group("gameplay")
	for node in gameplay_nodes:
		if node is Node:
			node.set_process(true)
			node.set_physics_process(true)
			node.set_process_input(true)
			node.set_process_unhandled_input(true)
			node.set_process_unhandled_key_input(true)
		if node is Timer:
			node.start()
