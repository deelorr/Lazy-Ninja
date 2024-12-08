extends Resource
class_name PlayerInput

var player: Player

func _init(p):
	player = p

func handle_input():
	# Movement
	var move_direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	player.velocity = move_direction * player.speed

	# Aim logic for shuriken
	var right_stick_vector = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	)
	var right_stick_magnitude = right_stick_vector.length()
	var stick_threshold = 0.1

	if player.combat.current_weapon == "shuriken":
		if right_stick_magnitude > stick_threshold:
			if not player.combat.is_aiming_with_stick:
				player.combat.is_aiming_with_stick = true
			player.combat.aim_shuriken(right_stick_vector)
		elif player.combat.is_aiming_with_stick:
			player.combat.is_aiming_with_stick = false
			player.combat.throw_shuriken()
		else:
			# Reset aiming visuals if the stick is not moved
			player.shuriken.stop_aiming()
			player.aim_line.visible = false
	else:
		if Input.is_action_just_pressed("attack"):
			player.combat.attack()
