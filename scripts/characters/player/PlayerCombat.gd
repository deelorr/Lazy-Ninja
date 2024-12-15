extends Resource
class_name PlayerCombat

var player: Player
var last_aim_direction: Vector2
var current_weapon: String = "sword"

func _init(p):
	player = p

func check_enemy_hits():
	for area in player.hurt_box.get_overlapping_areas():
		if area.name == "hit_box":
			hurt_by_enemy_area(area)

func hurt_by_enemy_area(area):
	player.decrease_health(1)
	player.is_hurt = true
	player.knockback(area.get_parent().velocity)
	player.effects.play("hurt_blink")
	player.hurt_timer.start()
	await player.hurt_timer.timeout
	player.effects.play("RESET")
	player.is_hurt = false

func attack():
	if player.is_attacking:
		return
	player.is_attacking = true
	if current_weapon == "spear":
		player.animations.play("stab_" + player.direction)
	else:
		player.animations.play("attack_" + player.direction)
	player.weapon_node.enable()
	await player.animations.animation_finished
	player.weapon_node.disable()
	player.is_attacking = false

func aim_shuriken(right_stick_vector = null):
	if current_weapon != "shuriken":
		return

	var aim_position
	if right_stick_vector != null:
		last_aim_direction = right_stick_vector.normalized()
		aim_position = player.global_position + last_aim_direction * 100
	else:
		aim_position = player.get_aim_position()
		var direction_vector = (aim_position - player.global_position).normalized()
		last_aim_direction = direction_vector

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
	if current_weapon != "shuriken":
		return
	var aim_position = player.global_position + last_aim_direction * 100
	player.shuriken.throw(aim_position)
	player.shuriken_noise.play()
	player.animations.play("attack_" + player.direction)
	player.shuriken.stop_aiming()
	player.aim_line.visible = false
