extends CharacterBody2D
class_name Character

# properties for all characters
@export var max_health: int = 10
@export var speed: float = 50
@export var knockback_power: int = 500
@export var diagonal_threshold = 0.5 # Adjust sensitivity to diagonal detection

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

func update_animation():
	if is_attacking:
		return
	# Stop animation if not moving
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
		return
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

func increase_health(amount: int):
	current_health += amount
	current_health = min(max_health, current_health)

func decrease_health(amount: int):
	current_health -= amount
	current_health = max(max_health, current_health)

func add_gold(amount: int):
	gold += amount
	
func take_gold(amount: int):
	gold -= amount
	gold = max(0, gold)
