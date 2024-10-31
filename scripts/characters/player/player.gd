extends CharacterBody2D
class_name Player

# =========================
# === Exported Variables ===
# Variables that can be set from the Godot editor
# =========================
@export var max_health: int = 3             # Maximum health
@export var current_health: int             # Current health of the player
@export var speed: int = 35                 # Player movement speed
@export var knockback_power: int = 500      # Power of knockback when hit
@export var inventory: Inventory            # Reference to the player's inventory

# =========================
# === Node References ===
# Nodes fetched when the scene is ready
# =========================
@onready var animations: AnimationPlayer = $AnimationPlayer      # AnimationPlayer node
@onready var effects: AnimationPlayer = $EffectsPlayer           # EffectsPlayer node for visual effects
@onready var hurt_box: Area2D = $hurt_box                        # Area2D node for detecting hurt collisions
@onready var hurt_timer: Timer = $hurt_timer                     # Timer node for invincibility frames
@onready var weapon_node: Node2D = $weapon                       # Node for weapon handling
@onready var shuriken: Area2D = $weapon/shuriken                 # Node for bow

# =========================
# === State Variables ===
# Variables to keep track of the player's state
# =========================
var current_weapon: String = "sword"        # Currently equipped weapon
var last_anim_direction: String = "down"    # Last direction the player was facing
var is_hurt: bool = false                   # Flag to check if the player is hurt
var is_attacking: bool = false              # Flag to check if the player is attacking
var is_jumping: bool = false                # Flag to check if the player is jumping
var gold: int = 50                          # Amount of gold the player has

# =========================
# === Experience Variables ===
# Variables related to experience points and leveling
# =========================
var current_xp: int = 0                     # Current experience points
var current_level: int = 1                  # Current level
var xp_for_next_level: int = 100            # Experience points needed for the next level

# =========================
# === Initialization ===
# Function called when the node enters the scene tree
# =========================
func _ready():
	current_health = max_health
	inventory.use_item.connect(use_item)  #connect the inventory's use_item signal to the use_item function
	weapon_node.disable()  #disable weapon at the start
	#effects.play("RESET")

# =========================
# === Physics Processing ===
# Function called every physics frame
# =========================
func _physics_process(_delta):
	handle_input()          # Handle player input
	move_and_slide()        # Move the player
	update_animation()      # Update animations based on movement
	# Check for collisions with enemy hitboxes if the player is not hurt
	if !is_hurt:
		for area in hurt_box.get_overlapping_areas():
			if area.name == "hit_box":
				hurt_by_enemy_area(area)

# =========================
# === Experience and Leveling ===
# Functions related to experience gain and leveling up
# =========================
func check_level_up():
	# Level up the player if they have enough experience
	while current_xp >= xp_for_next_level:
		current_xp -= xp_for_next_level
		current_level += 1
		print("Leveled Up! New Level: %d" % current_level)
		# Update the experience required for the next level
		xp_for_next_level = calculate_xp_for_level(current_level)
		
func calculate_xp_for_level(level: int) -> int:
	# Experience required increases by 50 each level
	return 100 + (level - 1) * 50

# =========================
# === Input Handling ===
# Functions to handle player input
# =========================
func handle_input():
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * speed
	if current_weapon == "shuriken":
		if Input.is_action_just_pressed("attack"):
			return
		if Input.is_action_pressed("throw_shuriken"):
			aim_shuriken()
		elif Input.is_action_just_released("throw_shuriken"):
			throw_shuriken()
		else:
			shuriken.stop_aiming()
	if Input.is_action_just_pressed("attack"):
		attack()

# =========================
# === Bow Mechanics ===
# Functions for aiming and firing the bow
# =========================

func aim_shuriken():
	var mouse_position = get_global_mouse_position()
	var hurt_box_position = hurt_box.global_position
	var direction = (mouse_position - hurt_box_position).normalized()
	# Calculate the bow's global position
	var shuriken_global_position = hurt_box_position + direction
	shuriken.global_position = shuriken_global_position
	# Rotate the bow to face the mouse
	shuriken.rotation = direction.angle()
	shuriken.aim()

func throw_shuriken():
	var mouse_position = get_global_mouse_position()
	shuriken.throw(mouse_position)
	shuriken.stop_aiming()

# =========================
# === Animation Handling ===
# Function to update the player's animations
# =========================
func update_animation():
	# If the player is attacking, don't change the animation
	if is_attacking or is_jumping:
		return

	# Stop animation if the player is not moving
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()

		if Input.is_action_just_pressed("jump"):
			is_jumping = true
			# Determine the direction for the jump animation
			if last_anim_direction == "left":
				animations.play("jump_left")
			elif last_anim_direction == "right":
				animations.play("jump_right")
			elif last_anim_direction == "up":
				animations.play("jump_up")
			else:  # Default to "down" if no direction set
				animations.play("jump_down")

			await animations.animation_finished
			is_jumping = false
			return

	else:
		# Determine the direction of movement
		var direction = "down"
		if velocity.x < 0:
			direction = "left"
		elif velocity.x > 0:
			direction = "right"
		elif velocity.y < 0:
			direction = "up"

		# Play the walking animation in the appropriate direction
		animations.play("walk_" + direction)
		last_anim_direction = direction

# =========================
# === Combat Mechanics ===
# Functions related to attacking and combat
# =========================
func attack():
	# Prevent attacking if already attacking
	if is_attacking:
		return

	is_attacking = true

	# Play the attack animation in the last direction faced
	animations.play("attack_" + last_anim_direction)

	# Enable the weapon's hitbox
	weapon_node.enable()

	# Wait for the animation to finish
	await animations.animation_finished

	# Disable the weapon's hitbox
	weapon_node.disable()
	is_attacking = false

# =========================
# === Damage and Knockback ===
# Functions for handling damage and knockback when hit
# =========================
func knockback(enemy_velocity: Vector2):
	# Calculate the knockback direction based on enemy velocity
	var knockback_direction = (enemy_velocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()

func hurt_by_enemy_area(area):
	# Reduce health when hurt by an enemy
	current_health -= 1

	# Reset health if it drops below zero (this might be a placeholder for respawning)
	if current_health < 0:
		current_health = max_health

	is_hurt = true

	# Apply knockback effect
	knockback(area.get_parent().velocity)

	# Play hurt effect
	effects.play("hurt_blink")

	# Start invincibility timer
	hurt_timer.start()

	# Wait for the invincibility period to end
	await hurt_timer.timeout

	# Reset effects and hurt state
	effects.play("RESET")
	is_hurt = false

# =========================
# === Collision Handling ===
# Function for when the player enters an area
# =========================

func _on_hurt_box_area_entered(area):
	# If the area has a collect method, collect the item
	if area.has_method("collect"):
		area.collect(inventory)

# =========================
# === Health Management ===
# Function to increase the player's health
# =========================
func increase_health(amount: int):
	# Increase current health but do not exceed max health
	current_health += amount
	current_health = min(max_health, current_health)

# =========================
# === Item Usage ===
# Function to use an item from the inventory
# =========================
func use_item(item: InventoryItem):
	# Check if the item can be used
	if not item.can_be_used(self):
		return

	# Use the item and remove it from the inventory
	item.use(self)
	inventory.remove_last_used_item()

# =========================
# === Currency Management ===
# Function to change the player's gold amount
# =========================
func change_gold(amount: int):
	gold += amount

# =========================
# === Experience Gain ===
# Function to add experience points
# =========================
func add_xp(amount: int):
	current_xp += amount
	print("Added XP: ", amount , " Total XP: " , current_xp, "/", xp_for_next_level)
	check_level_up()
