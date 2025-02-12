extends CharacterBody2D
class_name Character

signal health_changed(current_health, max_health)
signal mana_changed(current_mana, max_mana)

# properties for all characters
@export var max_health: int = 10
@export var max_mana: = 5
@export var speed: float = 50
@export var knockback_power: int = 500
@export var diagonal_threshold = 0.25 # Adjust sensitivity to diagonal detection

# children for all characters
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: Area2D = $hurt_box if has_node("hurt_box") else null

@onready var mana_timer: Timer = Timer.new()


# variables for all characters
var current_health: int
var current_mana: int
var mana_cost: int = 1  # Cost per spell cast
var is_hurt: bool = false
var is_dead: bool = false
var is_attacking: bool = false
var direction: String = "down"
var gold: int = 50

func _init():
	current_health = max_health
	current_mana = max_mana

func _ready():
	health_changed.emit(current_health, max_health)
	setup_character()
	
	mana_timer.wait_time = 5.0  # 5 seconds
	mana_timer.autostart = true  # Start automatically
	mana_timer.one_shot = false  # Keeps repeating
	mana_timer.timeout.connect(_on_mana_timer_timeout)  # Connect timer to function
	add_child(mana_timer)  # Attach timer to player

# subclass setup
func setup_character():
	# Override in subclasses if needed
	pass

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

func update_animation():
	if is_attacking:
		return
	
	# Stop animation if not moving
	if velocity.length() == 0:
		if animations.is_playing():
			animations.pause()  # Pause the animation instead of stopping it
			animations.seek(4.0 / animations.current_animation_length, true)
		return
	
	# Check for diagonal movement
	if abs(velocity.x) > abs(velocity.y) * diagonal_threshold and abs(velocity.y) > abs(velocity.x) * diagonal_threshold:
		if velocity.x < 0 and velocity.y < 0:
			direction = "left_up"
		elif velocity.x > 0 and velocity.y < 0:
			direction = "right_up"
		elif velocity.x < 0 and velocity.y > 0:
			direction = "left_down"
		elif velocity.x > 0 and velocity.y > 0:
			direction = "right_down"
	# Horizontal cases
	elif abs(velocity.x) > abs(velocity.y):
		if velocity.x < 0:
			direction = "left"
		elif velocity.x > 0:
			direction = "right"
	# Vertical cases
	elif abs(velocity.y) > abs(velocity.x):
		if velocity.y < 0:
			direction = "up"
		elif velocity.y > 0:
			direction = "down"

	# Check if the animation exists before playing it
	var animation_name = "walk_" + direction
	if animations.has_animation(animation_name):
		animations.play(animation_name)
	else:
		# Fallback to a default animation if diagonal animations don't exist
		animations.play("walk_" + get_fallback_direction(direction))

# Function to provide a fallback direction (defaults to horizontal/vertical movement)
func get_fallback_direction(dir: String) -> String:
	match dir:
		"left_up", "right_up": return "up"
		"left_down", "right_down": return "down"
		_: return dir


func knockback(source_position: Vector2) -> void:
	var knockback_direction = (position - source_position).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()

func increase_health(amount: int):
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	health_changed.emit(current_health, max_health)

func decrease_health(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()
	health_changed.emit(current_health, max_health)

func add_gold(amount: int):
	gold += amount

func take_gold(amount: int):
	gold -= amount
	gold = max(0, gold)

func die():
	#queue_free()
	current_health = max_health

func cast_spell():
	if current_mana >= mana_cost:
		current_mana -= mana_cost  # Deduct mana
		emit_signal("mana_changed", current_mana, max_mana)  # Update UI
		print("Spell cast! Remaining mana:", current_mana)
	else:
		print("Not enough mana!")  # Prevents casting when mana is too low

func _on_mana_timer_timeout():
	if current_mana < max_mana:
		current_mana = min(current_mana + 1, max_mana)  # Increase by 1 every 5 seconds
		emit_signal("mana_changed", current_mana, max_mana)  # Update UI
		print("Mana Regenerated: ", current_mana, "/", max_mana)  # Debug
