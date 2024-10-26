extends BaseScene

@onready var beast_scene: PackedScene = preload("res://scenes/characters/enemies/beast.tscn")

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
	var spawn_area = Rect2(Vector2(400, 170), Vector2(100, 100))
	var random_x = randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x)
	var random_y = randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	return Vector2(random_x, random_y)
