extends Node2D

var speed: float = 800  # Speed of the arrow in pixels per second
var direction: Vector2 = Vector2.RIGHT  # Initial direction

func _physics_process(delta):
	# Move the arrow in the given direction
	position += direction * speed * delta

	# Optional: Destroy the arrow if it goes off-screen
	if is_out_of_bounds():
		queue_free()

func is_out_of_bounds() -> bool:
	var viewport_rect = get_viewport().get_visible_rect()
	return not viewport_rect.has_point(global_position)

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		# Handle enemy hit logic
		#body.take_damage(arrow_damage)
		queue_free()
