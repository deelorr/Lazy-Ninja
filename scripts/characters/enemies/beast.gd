extends "res://scripts/characters/CharacterClass.gd"
class_name Beast

@onready var direction_timer: Timer = $direction_timer

var is_chasing: bool = false
var player: Player = null

func setup_character():
	player = SceneManager.player
	velocity = Vector2.DOWN * speed
	direction_timer.start()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	if is_chasing and player:
		chase_player()
	else:
		move_and_slide()
	update_animation()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if not area.is_in_group("weapon"):
		return
	current_health -= 1
	knockback(area.global_position)
	if current_health <= 0:
		$hit_box.set_deferred("monitorable", false)
		is_dead = true
		animations.play("death")
		await animations.animation_finished
		Global.enemy_killed.emit("beast")
		Global.beast_count -= 1
		print("beast destroyed", Global.beast_count, "/", Global.max_beasts)
		SceneManager.player.progression.add_xp(10)
		queue_free()

func _on_direction_timer_timeout() -> void:
	if not is_chasing:
		var angle = randf() * 2 * PI  #random angle
		var new_direction = Vector2(cos(angle), sin(angle)).normalized()
		velocity = new_direction * speed
	direction_timer.start()

func chase_player() -> void:
	var chase_direction = (player.position - position).normalized()
	velocity = chase_direction * speed
	move_and_slide()

func _on_detection_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		is_chasing = true

func _on_detection_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		is_chasing = false
