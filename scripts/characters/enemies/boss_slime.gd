extends CharacterBody2D

@onready var player = SceneManager.player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_timer: Timer = $direction_timer
@onready var fov: Area2D = $FieldOfView  # The Area2D node for the field of view
@onready var shoot_timer: Timer = $ShootTimer  # A timer to control the shooting rate
@onready var laser_beam: PackedScene = preload("res://laserbeam.tscn")  # Reference to laser scene

const SPEED = 45
const LASER_DURATION = 0.03

var is_dead: bool = false
var player_in_fov: bool = false  # Tracks if the player is inside the FOV

func _ready() -> void:
	velocity = Vector2.DOWN * SPEED
	direction_timer.start()
	shoot_timer.stop()  # Prevent shooting until the player is in the FOV

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	update_animation()
	move_and_slide()
	if player_in_fov and not shoot_timer.is_stopped():
		create_laser(global_position, player.global_position)

func update_animation() -> void:
	if velocity.length() == 0:
		if animation_player.is_playing():
			animation_player.stop()
		return
	animation_player.play("idle")

func get_direction() -> String:
	if abs(velocity.x) > abs(velocity.y):
		return "left" if velocity.x < 0 else "right"
	else:
		return "up" if velocity.y < 0 else "down"

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if not area.is_in_group("weapon"):
		return
	$hit_box.set_deferred("monitorable", false)
	is_dead = true
	animation_player.play("death")
	await animation_player.animation_finished
	Global.enemy_killed.emit("boss_slime")
	print("boss slime destroyed")
	SceneManager.player.add_xp(50)
	queue_free()

func _on_direction_timer_timeout() -> void:
	var angle = randf() * 2 * PI  # Random angle
	var new_direction = Vector2(cos(angle), sin(angle)).normalized()
	velocity = new_direction * SPEED
	direction_timer.start()
	
func create_laser(start: Vector2, end: Vector2) -> void:
	var laser = laser_beam.instantiate()
	laser.clear_points()
	laser.add_point(start)
	laser.add_point(end)
	get_parent().add_child(laser)

	# Cleanup timer to remove laser after a short duration
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = 0.05
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(laser.queue_free)
	add_child(cleanup_timer)
	cleanup_timer.start()

func _on_field_of_view_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Replace with your player's node name or group
		player_in_fov = true
		shoot_timer.start()  # Start shooting when the player enters the FOV

func _on_field_of_view_body_exited(body: Node) -> void:
	if body.is_in_group("player"):  # Replace with your player's node name or group
		player_in_fov = false
		shoot_timer.stop()  # Stop shooting when the player exits the FOV
