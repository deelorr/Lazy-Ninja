extends BaseScene

@onready var beast_scene: PackedScene = preload("res://scenes/characters/enemies/beast.tscn")
@onready var spawn_area: Area2D = $spawn_area
@onready var collision_polygon: CollisionPolygon2D = $spawn_area/CollisionPolygon2D

func _ready():
	super._ready()
	randomize()
	spawn_enemies(3)

func spawn_enemies(count: int) -> void:
	for i in range(count):
		var beast_instance = beast_scene.instantiate()
		beast_instance.position = get_random_position()
		add_child(beast_instance)
		Global.beast_count += 1

func get_random_position() -> Vector2:
	if collision_polygon and collision_polygon.polygon.size() > 0:
		return get_random_point_in_polygon(collision_polygon.polygon)

	#no polygon, return the spawn_area position
	return spawn_area.global_position

func get_random_point_in_polygon(points: Array) -> Vector2:
	# Calculate a random point within the polygon using a bounding box approach
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	# Find the bounding box of the polygon
	for point in points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)

	# Attempt to generate a random point within the polygon
	for i in range(100):  # Try 100 times to find a valid point
		var random_point = Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)

		if is_point_in_polygon(random_point, points):
			return spawn_area.global_position + random_point.rotated(spawn_area.rotation)

	# Fallback to spawn_area position if no valid point is found
	return spawn_area.global_position

func is_point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var n = polygon.size()
	var inside = false
	var j = n - 1
	
	for i in range(n):
		var vi = polygon[i]
		var vj = polygon[j]
		if ((vi.y > point.y) != (vj.y > point.y)) and \
		   (point.x < (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y) + vi.x):
			inside = not inside
		j = i

	return inside
