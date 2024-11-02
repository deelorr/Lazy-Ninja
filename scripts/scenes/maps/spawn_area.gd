extends Area2D

@onready var beast_scene: PackedScene = preload("res://scenes/characters/enemies/beast.tscn")
@onready var spider_scene: PackedScene = preload("res://scenes/characters/enemies/spider.tscn")
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

func _ready():
	randomize()
	spawn_beasts(3)
	spawn_spiders(5)

func spawn_beasts(count: int) -> void:
	#get parent node to ensure enemies are added to map
	var parent_node = self.get_parent()
	for i in range(count):
		var beast_instance = beast_scene.instantiate()
		var spawn_pos = get_random_position()
		beast_instance.position = spawn_pos
		if parent_node:
			parent_node.add_child.call_deferred(beast_instance)
			Global.beast_count += 1
		else:
			print("Error: No parent node found.")
			
func spawn_spiders(count: int) -> void:
	#get parent node to ensure enemies are added to map
	var parent_node = self.get_parent()
	for i in range(count):
		var spider_instance = spider_scene.instantiate()
		var spawn_pos = get_random_position()
		spider_instance.position = spawn_pos
		if parent_node:
			parent_node.add_child.call_deferred(spider_instance)
			Global.beast_count += 1
		else:
			print("Error: No parent node found.")

func get_random_position() -> Vector2:
	if collision_polygon and collision_polygon.polygon.size() > 0:
		var random_pos = get_random_point_in_polygon(collision_polygon.polygon)
		return random_pos
	#no valid polygon
	print("No polygon found, returning global position: ", self.global_position)
	return self.global_position

func get_random_point_in_polygon(points: Array) -> Vector2:
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
			var adjusted_point = self.global_position + random_point.rotated(self.rotation)
			print("Valid point found: ", adjusted_point)
			return adjusted_point

	# Fallback to global position if no valid point is found
	print("No valid point found, using fallback global position.")
	return self.global_position

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
