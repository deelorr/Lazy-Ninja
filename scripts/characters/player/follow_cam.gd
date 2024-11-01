extends Camera2D

@export var tilemap: TileMap
@onready var follow_node: Player = SceneManager.player

# Variables for zoom limits
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_step: float = 0.1

func _ready():
	var map_rect = tilemap.get_used_rect()
	var tile_size = tilemap.rendering_quadrant_size
	var world_size_in_pixels = map_rect.size * tile_size
	limit_right = world_size_in_pixels.x
	limit_bottom = world_size_in_pixels.y

func _process(_delta):
	global_position = follow_node.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom.x > min_zoom:
			zoom -= Vector2(zoom_step, zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom.x < max_zoom:
			zoom += Vector2(zoom_step, zoom_step)
