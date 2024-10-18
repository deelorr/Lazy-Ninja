extends Node2D

# Exported variables
@export var arrow_scene: PackedScene  # Drag your Arrow scene here
@export var fire_rate: float = 0.5  # Time between shots
@export var arrow_offset: Vector2 = Vector2(-5, 10)  # Position where the arrow spawns relative to the bow
@onready var shape = $CollisionShape2D

var can_fire: bool = true

func _ready():
	# Optional: Preload the arrow scene if not set via export
	arrow_scene = preload("res://scenes/items/Weapons/arrow.tscn")
	pass

func enable():
	shape.disabled = false
	visible = true

func disable():
	shape.disabled = true
	visible = false

func shoot(target_position: Vector2):
	if not can_fire:
		return

	can_fire = false
	$can_fire_timer.start(fire_rate)

	var direction = (target_position - global_position).normalized()

	var arrow = arrow_scene.instantiate()
	arrow.position = global_position + arrow_offset
	arrow.rotation = direction.angle()
	arrow.direction = direction

	get_tree().current_scene.add_child(arrow)

func _on_can_fire_timer_timeout():
	can_fire = true
