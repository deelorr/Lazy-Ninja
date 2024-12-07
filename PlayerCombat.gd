extends Resource
class_name PlayerCombat

var player: Player

func _init(p):
	player = p

func attack():
	if player.is_attacking:
		return
	player.is_attacking = true
	player.animations.play("attack_" + player.direction)
	player.weapon_node.enable()
	await player.animations.animation_finished
	player.weapon_node.disable()
	player.is_attacking = false

func aim_shuriken(right_stick_vector = null):
	if player.current_weapon != "shuriken":
		return

	var aim_position
	if right_stick_vector != null:
		player.last_aim_direction = right_stick_vector.normalized()
		aim_position = player.global_position + player.last_aim_direction * 100
	else:
		aim_position = player.get_aim_position()
		var direction_vector = (aim_position - player.global_position).normalized()
		player.last_aim_direction = direction_vector

	var hurt_box_position = player.hurt_box.global_position
	var direction = (aim_position - hurt_box_position).normalized()

	player.shuriken.global_position = hurt_box_position + direction
	player.shuriken.rotation = direction.angle()
	player.shuriken.aim()

	player.aim_line.visible = true
	player.aim_line.clear_points()
	player.aim_line.add_point(hurt_box_position - player.global_position)
	player.aim_line.add_point(aim_position - player.global_position)

func throw_shuriken():
	if player.current_weapon != "shuriken":
		return
	var aim_position = player.global_position + player.last_aim_direction * 100
	player.shuriken.throw(aim_position)
	player.shuriken_noise.play()
	player.animations.play("attack_" + player.direction)
	player.shuriken.stop_aiming()
	player.aim_line.visible = false

func knockback(enemy_velocity: Vector2):
	var knockback_direction = (enemy_velocity - player.velocity).normalized() * player.knockback_power
	player.velocity = knockback_direction
	player.move_and_slide()

func hurt_by_enemy_area(area):
	player.current_health -= 1
	if player.current_health < 0:
		# If health drops below 0, reset or handle differently
		player.current_health = player.max_health
	player.is_hurt = true
	knockback(area.get_parent().velocity)
	if player.effects:
		player.effects.play("hurt_blink")
	if player.hurt_timer:
		player.hurt_timer.start()
		await player.hurt_timer.timeout
		if player.effects:
			player.effects.play("RESET")
	player.is_hurt = false

func check_enemy_hits():
	# Similar logic from original code
	for area in player.hurt_box.get_overlapping_areas():
		if area.name == "hit_box":
			hurt_by_enemy_area(area)
