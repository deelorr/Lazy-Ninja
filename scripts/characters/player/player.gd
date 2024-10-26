class_name Player
extends CharacterBody2D

# =========================
# === Exported Variables ===
# Variables that can be set from the Godot editor
# =========================
@export var speed: int = 35                 # Player movement speed
@export var max_health: int = 3             # Maximum health
@export var knockback_power: int = 500      # Power of knockback when hit
@export var inventory: Inventory            # Reference to the player's inventory

# =========================
# === Node References ===
# Nodes fetched when the scene is ready
# =========================
@onready var animations = $AnimationPlayer      # AnimationPlayer node
@onready var effects = $EffectsPlayer           # EffectsPlayer node for visual effects
@onready var hurt_box = $hurt_box               # Area2D node for detecting hurt collisions
@onready var hurt_timer = $hurt_timer           # Timer node for invincibility frames
@onready var weapon = $weapon                   # Node for weapon handling
@onready var current_health: int                # Current health of the player

# =========================
# === State Variables ===
# Variables to keep track of the player's state
# =========================
var current_weapon = ""                     # Currently equipped weapon
var bow                                     # Reference to the bow weapon
var last_anim_direction: String = "down"    # Last direction the player was facing
var is_hurt: bool = false                   # Flag to check if the player is hurt
var is_attacking: bool = false              # Flag to check if the player is attacking
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
	# Set current health to maximum health at the start
	current_health = max_health

	# Connect the inventory's use_item signal to the use_item function
	inventory.use_item.connect(use_item)

	# Disable weapon interactions at the start
	weapon.disable()

	# Reset any ongoing effects
	effects.play("RESET")

	# Get a reference to the bow weapon
	bow = weapon.bow
	if bow == null:
		print("Error: 'bow' prop not found under 'weapon' ")

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
	# Get movement input from the player
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * speed

	# Check if the attack button was just pressed
	if Input.is_action_just_pressed("attack"):
		attack()

	# Handle bow aiming and firing if the bow is equipped
	if current_weapon == "bow":
		if Input.is_action_pressed("aim_bow"):
			aim_bow()
		elif Input.is_action_just_released("aim_bow"):
			fire_bow()
		else:
			weapon.bow.stop_aiming()

# =========================
# === Bow Mechanics ===
# Functions for aiming and firing the bow
# =========================
func aim_bow():
	# Calculate the direction to aim the bow based on the mouse position
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - weapon.global_position).normalized()
	weapon.bow.rotation = direction.angle()
	weapon.bow.aim()

func fire_bow():
	# Fire the bow towards the mouse position
	var mouse_position = get_global_mouse_position()
	weapon.bow.shoot(mouse_position)
	weapon.bow.stop_aiming()

# =========================
# === Animation Handling ===
# Function to update the player's animations
# =========================
func update_animation():
	# If the player is attacking, don't change the animation
	if is_attacking:
		return

	# Stop animation if the player is not moving
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
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
	weapon.enable()

	# Wait for the animation to finish
	await animations.animation_finished

	# Disable the weapon's hitbox
	weapon.disable()
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
