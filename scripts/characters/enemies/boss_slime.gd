extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_timer: Timer = $direction_timer
@onready var fov: Area2D = $FieldOfView  # The Area2D node for the field of view
@onready var shoot_timer: Timer = $ShootTimer  # A timer to control the shooting rate
@onready var LaserScene: PackedScene = preload("res://laser.tscn")  # Reference to laser scene

var speed: int = 45
var is_dead: bool = false
var player_in_fov: bool = false  # Tracks if the player is inside the FOV

func _ready() -> void:
	velocity = Vector2.DOWN * speed
	direction_timer.start()
	shoot_timer.stop()  # Prevent shooting until the player is in the FOV

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	update_animation()
	move_and_slide()

	# Handle shooting if the player is in the FOV
	if player_in_fov and not shoot_timer.is_stopped():
		shoot_laser()

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
	velocity = new_direction * speed
	direction_timer.start()

func shoot_laser() -> void:
	if not is_instance_valid(SceneManager.player):
		return  # Avoid errors if the player is removed
	var player_position = SceneManager.player.global_position
	var direction = (player_position - global_position).normalized()

	# Create and shoot the laser
	var laser = LaserScene.instantiate()
	get_parent().add_child(laser)
	laser.global_position = global_position
	laser.direction = direction  # Set the laser's direction
	laser.z_index = 10  # Ensure laser is rendered above other elements

func _on_field_of_view_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Replace with your player's node name or group
		player_in_fov = true
		shoot_timer.start()  # Start shooting when the player enters the FOV

func _on_field_of_view_body_exited(body: Node) -> void:
	if body.is_in_group("player"):  # Replace with your player's node name or group
		player_in_fov = false
		shoot_timer.stop()  # Stop shooting when the player exits the FOV
