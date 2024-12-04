extends Line2D

@export var speed: float = 300
var direction: Vector2 = Vector2.ZERO
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@export var max_distance: float = 150
var distance_traveled: float = 0

func _ready() -> void:
	if get_point_count() < 2:
		add_point(Vector2.ZERO)  # Start point
		add_point(Vector2.UP * 10)  # Initial length

	print("Laser spawned at: ", global_position)
	print("Laser direction: ", direction)

func _process(delta: float) -> void:
	# Move the laser
	var movement = direction * speed * delta

	global_position += movement
	distance_traveled += movement.length()
	if distance_traveled >= max_distance:
		queue_free()
	#extend_beam()

	# Debug the points
	print("Laser points: ", get_point_position(0), " -> ", get_point_position(1))

	# Check if out of bounds
	#if is_outside_viewport():
		#queue_free()

func extend_beam() -> void:
	if get_point_count() >= 2:
		set_point_position(1, get_point_position(1) + direction * speed * 0.1)

func is_outside_viewport() -> bool:
	return false
	#var viewport_rect = get_viewport().get_visible_rect()
	#return not viewport_rect.has_point(global_position)
