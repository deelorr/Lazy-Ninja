extends CharacterBody2D
class_name Player

#region === EXPORTS ===
@export var max_health: int = 3
@export var speed: int = 35
@export var knockback_power: int = 500
#endregion

#region === ONREADYS ===
@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var effects: AnimationPlayer = $EffectsPlayer
@onready var hurt_box: Area2D = $hurt_box
@onready var hurt_timer: Timer = $hurt_timer
@onready var weapon_node: Node2D = $weapon
@onready var shuriken: Area2D = $weapon/shuriken
@onready var shuriken_noise: AudioStreamPlayer2D = $shuriken_noise
@onready var aim_line = $AimLine
#endregion

#region === VARIABLES ===
var current_health: int = max_health
var current_weapon: String = "sword"
var last_anim_direction: String = "down"
var last_aim_direction = Vector2.ZERO
var is_hurt: bool = false
var is_attacking: bool = false
var is_jumping: bool = false
var is_aiming_with_stick: bool = false

var gold: int = 50
var current_xp: int = 0
var current_level: int = 1
var xp_for_next_level: int = 100
#endregion

#region === INITIALIZATION ===
func _ready():
	inventory.use_item.connect(use_item)  # Connect the use_item signal to the use_item function
	weapon_node.disable()  # Disable weapon collision at start
#endregion

#region === PHYSICS AND INPUT ===
func _physics_process(_delta):
	# Escape to quit for now
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	handle_input()
	update_animation()

	if !is_hurt:
		for area in hurt_box.get_overlapping_areas():
			if area.name == "hit_box":
				hurt_by_enemy_area(area)

	move_and_slide()

func handle_input():
	var move_direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = move_direction * speed

	var right_stick_vector = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	)

	var right_stick_magnitude = right_stick_vector.length()
	var stick_threshold = 0.1  # Threshold to consider the stick as moved

	# Handle right stick aiming
	if current_weapon == "shuriken":
		if right_stick_magnitude > stick_threshold:
			if not is_aiming_with_stick:
				is_aiming_with_stick = true  # Start aiming
			aim_shuriken(right_stick_vector)
		elif is_aiming_with_stick:
			is_aiming_with_stick = false  # Stop aiming
			throw_shuriken()
		else:
			# Reset aiming visuals if the stick is not moved
			shuriken.stop_aiming()
			aim_line.visible = false  # Hide the aim line
	else:
		# Mouse input handling or other weapons
		if Input.is_action_just_pressed("attack"):
			attack()
#endregion

#region === COMBAT AND ATTACKING ===
func attack():
	if is_attacking:
		return
	is_attacking = true
	animations.play("attack_" + last_anim_direction)
	weapon_node.enable()
	await animations.animation_finished
	weapon_node.disable()
	is_attacking = false

func aim_shuriken(right_stick_vector = null):
	if current_weapon != "shuriken":
		return  # Prevent throwing shuriken if it's not the current weapon
	
	var aim_position
	if right_stick_vector != null:
		last_aim_direction = right_stick_vector.normalized()  # Reverse the stick direction
		aim_position = global_position + last_aim_direction * 100  # Adjust as needed
	else:
		aim_position = get_aim_position()
		var direction_vector = (aim_position - global_position).normalized()
		last_aim_direction = direction_vector

	var hurt_box_position = hurt_box.global_position
	var direction = (aim_position - hurt_box_position).normalized()

	# Set shuriken position and rotation based on the aiming direction
	var shuriken_global_position = hurt_box_position + direction
	shuriken.global_position = shuriken_global_position
	shuriken.rotation = direction.angle()
	shuriken.aim()

	# Draw the aiming line
	aim_line.visible = true
	aim_line.clear_points()
	aim_line.add_point(hurt_box_position - global_position)
	aim_line.add_point(aim_position - global_position)



func throw_shuriken():
	if current_weapon != "shuriken":
		return  # Prevent throwing shuriken if it's not the current weapon
		
	var aim_position = global_position + last_aim_direction * 100  # Adjust as needed
	shuriken.throw(aim_position)
	shuriken_noise.play()
	last_anim_direction = get_direction_from_vector(last_aim_direction)
	animations.play("attack_" + last_anim_direction)
	shuriken.stop_aiming()
	aim_line.visible = false  # Hide the aim line

func knockback(enemy_velocity: Vector2):
	var knockback_direction = (enemy_velocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()
#endregion

#region === PLAYER STATE ===
func hurt_by_enemy_area(area):
	current_health -= 1
	if current_health < 0:
		current_health = max_health
	is_hurt = true
	knockback(area.get_parent().velocity)
	effects.play("hurt_blink")
	hurt_timer.start()
	await hurt_timer.timeout
	effects.play("RESET")
	is_hurt = false

func increase_health(amount: int):
	current_health += amount
	current_health = min(max_health, current_health)

func change_gold(amount: int):
	gold += amount
#endregion

#region === EXPERIENCE AND LEVELING ===
func add_xp(amount: int):
	current_xp += amount
	print("Added XP: ", amount, " Total XP: ", current_xp, "/", xp_for_next_level)
	check_level_up()

func check_level_up():
	while current_xp >= xp_for_next_level:
		current_xp -= xp_for_next_level
		current_level += 1
		print("Leveled Up! New Level: %d" % current_level)
		xp_for_next_level = calculate_xp_for_level(current_level)

func calculate_xp_for_level(level: int) -> int:
	return 100 + (level - 1) * 50  # Experience increases by 50 each level
#endregion

#region === ANIMATIONS ===
func update_animation():
	if is_attacking or is_jumping:
		return
	
	# Stop animation if not moving
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
		return
	
	# Handle jumping animation
	if Input.is_action_just_pressed("jump"):
		is_jumping = true
		if last_anim_direction == "left":
			animations.play("jump_left")
		elif last_anim_direction == "right":
			animations.play("jump_right")
		elif last_anim_direction == "up":
			animations.play("jump_up")
		else:
			animations.play("jump_down")
		await animations.animation_finished
		is_jumping = false
		return
	
	# Direction detection with threshold
	var direction = "down"
	var diagonal_threshold = 0.5  
	# Adjust for sensitivity to diagonal detection
	# Lower values (e.g., 0.3) make diagonal detection harder.
	# Higher values (e.g., 0.7) make it easier to prioritize "up" or "down."
	# Check for diagonal directions
	if abs(velocity.x) > abs(velocity.y) * diagonal_threshold:
		if velocity.x < 0:
			direction = "left"
		elif velocity.x > 0:
			direction = "right"
	elif abs(velocity.y) > abs(velocity.x) * diagonal_threshold:
		if velocity.y < 0:
			direction = "up"
		elif velocity.y > 0:
			direction = "down"
	else:  # Diagonal cases
		if velocity.x < 0 and velocity.y < 0:
			direction = "left"
		elif velocity.x > 0 and velocity.y < 0:
			direction = "right"
		elif velocity.x < 0 and velocity.y > 0:
			direction = "left"
		elif velocity.x > 0 and velocity.y > 0:
			direction = "right"
	
	animations.play("walk_" + direction)
	last_anim_direction = direction
#endregion

#region === INVENTORY ===
func use_item(item: InventoryItem):
	if not item.can_be_used(self):
		return
	item.use(self)
	inventory.remove_last_used_item()

func _on_hurt_box_area_entered(area):
	if area.has_method("collect"):
		area.collect(inventory)
#endregion

#region === UTILITIES ===
func get_aim_position() -> Vector2:
	return get_global_mouse_position()

func get_direction_from_vector(direction_vector: Vector2) -> String:
	if abs(direction_vector.x) > abs(direction_vector.y):
		if direction_vector.x > 0:
			return "right"
		else:
			return "left"
	else:
		if direction_vector.y > 0:
			return "down"
		else:
			return "up"
#endregion
