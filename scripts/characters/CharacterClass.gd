extends CharacterBody2D
class_name Character

# properties for all characters
@export var max_health: int = 10
@export var speed: float = 50
@export var knockback_power: int = 500
@export var diagonal_threshold = 0.25 # Adjust sensitivity to diagonal detection

# children for all characters
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: Area2D = $hurt_box if has_node("hurt_box") else null


# variables for all characters
var current_health: int
var is_hurt: bool = false
var is_dead: bool = false
var is_attacking: bool = false
var direction: String = "down"
var gold: int = 50

var anim_name
var fallback_anim

func _ready():
	current_health = max_health
	setup_character()

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
#
#func update_animation():
	#if is_attacking:
		#return
	## Stop animation if not moving
	#if velocity.length() == 0:
		#if animations.is_playing():
			#animations.stop()
		#return
	#
	## Check for diagonal movement
	#if abs(velocity.x) > abs(velocity.y) * diagonal_threshold and abs(velocity.y) > abs(velocity.x) * diagonal_threshold:
		#if velocity.x < 0 and velocity.y < 0:
			#direction = "left_up"
		#elif velocity.x > 0 and velocity.y < 0:
			#direction = "right_up"
		#elif velocity.x < 0 and velocity.y > 0:
			#direction = "left_down"
		#elif velocity.x > 0 and velocity.y > 0:
			#direction = "right_down"
	## Horizontal cases
	#elif abs(velocity.x) > abs(velocity.y):
		#if velocity.x < 0:
			#direction = "left"
		#elif velocity.x > 0:
			#direction = "right"
	## Vertical cases
	#elif abs(velocity.y) > abs(velocity.x):
		#if velocity.y < 0:
			#direction = "up"
		#elif velocity.y > 0:
			#direction = "down"
	#
	#animations.play("walk_" + direction)
	#print(direction)
	
func update_animation():
	if is_attacking:
		return
	# Stop animation if not moving
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
		return
	
	# Determine the direction
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
	
	# Construct the animation name and check if it exists
	anim_name = "walk_" + direction
	if animations.has_animation(anim_name):
		animations.play(anim_name)
	else:
		# Fallback to horizontal or vertical
		if "up" in direction or "down" in direction:
			fallback_anim = "walk_" + ("up" if "up" in direction else "down")
		else:
			fallback_anim = "walk_" + ("left" if "left" in direction else "right")
		animations.play(fallback_anim)
		#print("Using fallback animation:", fallback_anim)

func knockback(source_position: Vector2) -> void:
	var knockback_direction = (position - source_position).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()

func increase_health(amount: int):
	current_health += amount
	if current_health > max_health:
		current_health = max_health

func decrease_health(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func add_gold(amount: int):
	gold += amount

func take_gold(amount: int):
	gold -= amount
	gold = max(0, gold)

func die():
	#queue_free()
	current_health = max_health
