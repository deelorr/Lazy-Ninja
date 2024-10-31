extends Area2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta
	if is_out_of_bounds():
		queue_free()
		pass

func is_out_of_bounds() -> bool:
	var camera = get_viewport().get_camera_2d()
	if camera:
		var viewport_size = get_viewport_rect().size
		var screen_top_left = camera.global_position - (viewport_size * camera.zoom) * 0.5
		var screen_rect = Rect2(screen_top_left, viewport_size * camera.zoom)
		screen_rect = screen_rect.grow(100)
		return not screen_rect.has_point(global_position)
	else:
		var viewport_rect = get_viewport_rect()
		viewport_rect = viewport_rect.grow(100)
		print("no camera found")
		return not viewport_rect.has_point(global_position)
