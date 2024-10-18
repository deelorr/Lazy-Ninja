extends Area2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta

	# Optional: Destroy the arrow if it goes off-screen
	if is_out_of_bounds():
		queue_free()
		pass

func is_out_of_bounds() -> bool:
	var camera = get_viewport().get_camera_2d()
	if camera:
		# Get the size of the viewport
		var viewport_size = get_viewport_rect().size
		# Calculate the top-left position of the visible area
		var screen_top_left = camera.global_position - (viewport_size * camera.zoom) * 0.5
		# Create the screen rectangle
		var screen_rect = Rect2(screen_top_left, viewport_size * camera.zoom)
		screen_rect = screen_rect.grow(100)  # Optional buffer
		return not screen_rect.has_point(global_position)
	else:
		# Fallback if no camera is found
		var viewport_rect = get_viewport_rect()
		viewport_rect = viewport_rect.grow(100)
		print("no camera found")
		return not viewport_rect.has_point(global_position)

func _on_body_entered(body):
	print("Arrow collided with: ", body.name)
	#if body.is_in_group("enemies"):
		# Handle enemy hit logic
		# body.take_damage(arrow_damage)
	queue_free()
