extends "res://scripts/characters/CharacterClass.gd"
class_name BossSlime

@onready var player = SceneManager.player
@onready var direction_timer: Timer = $direction_timer
@onready var fov: Area2D = $FieldOfView
@onready var laser_duration_timer: Timer = $laser_duration
@onready var laser_beam: PackedScene = preload("res://scenes/effects/laserbeam.tscn")
@onready var laser: Line2D
@onready var cooldown_timer: Timer = $cooldown

const SPEED = 45

var player_in_fov: bool = false
var can_shoot_laser: bool = false
	
func setup_character():
	velocity = Vector2.ZERO * SPEED
	direction_timer.start()
	can_shoot_laser = false

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	update_animation()
	move_and_slide()

	# Only show laser if player is in FOV and shooting is allowed
	if player_in_fov and can_shoot_laser:
		create_laser(global_position, player.global_position)
	else:
		remove_laser()

func update_animation() -> void:
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
		return
	animations.play("idle")

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if not area.is_in_group("weapon"):
		return
	$hit_box.set_deferred("monitorable", false)
	is_dead = true
	animations.play("death")
	await animations.animation_finished
	Global.enemy_killed.emit("boss_slime")
	print("boss slime destroyed")
	SceneManager.player.progression.add_xp(50)
	queue_free()

func _on_direction_timer_timeout() -> void:
	var angle = randf() * 2 * PI
	var new_direction = Vector2(cos(angle), sin(angle)).normalized()
	velocity = new_direction * SPEED
	direction_timer.start()

func create_laser(start: Vector2, end: Vector2) -> void:
	# Create the laser instance if it doesn't exist
	if laser == null:
		laser = laser_beam.instantiate()
		get_parent().add_child(laser)

	# Update laser points
	laser.clear_points()
	laser.add_point(start)
	laser.add_point(end)
	laser.visible = true

	# Start duration timer if not running
	if laser_duration_timer.is_stopped():
		laser_duration_timer.start()
		print("Laser duration timer started")

func remove_laser() -> void:
	# Hide the laser if it exists
	if laser != null:
		laser.visible = false

func _on_field_of_view_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_fov = true
		# If not cooling down, allow shooting immediately
		if cooldown_timer.is_stopped():
			can_shoot_laser = true

func _on_field_of_view_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_fov = false

func _on_laser_duration_timeout() -> void:
	print("Laser duration ended")
	remove_laser()
	can_shoot_laser = false
	cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	# If the player is still in FOV after cooldown, resume shooting
	if player_in_fov:
		can_shoot_laser = true
