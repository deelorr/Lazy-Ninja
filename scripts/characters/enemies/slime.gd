extends "res://scripts/characters/CharacterClass.gd"
class_name Slime

@onready var direction_timer: Timer = $direction_timer

func setup_character():
	velocity = Vector2.DOWN * speed
	direction_timer.start()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	update_animation()
	move_and_slide()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if not area.is_in_group("weapon"):
		return
	$hit_box.set_deferred("monitorable", false)
	is_dead = true
	animations.play("death")
	await animations.animation_finished
	Global.enemy_killed.emit("slime")
	Global.slime_count -= 1
	print("slime destroyed", Global.slime_count, "/", Global.max_slimes)
	SceneManager.player.progression.add_xp(5)
	queue_free()

func _on_direction_timer_timeout() -> void:
	var angle = randf() * 2 * PI  #random angle
	var new_direction = Vector2(cos(angle), sin(angle)).normalized()
	velocity = new_direction * speed
	direction_timer.start()
