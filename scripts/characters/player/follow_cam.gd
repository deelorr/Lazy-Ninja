extends Camera2D

@export var tilemap: TileMap
@onready var player: Player = SceneManager.player
@onready var pause_menu = get_parent().get_node("HUD").pause_menu

func _ready():
	pause_menu.zoom_changed.connect(Callable (self, "_on_zoom_changed"))
	var map_rect = tilemap.get_used_rect()
	var tile_size = tilemap.rendering_quadrant_size
	var world_size_in_pixels = map_rect.size * tile_size
	limit_right = world_size_in_pixels.x
	limit_bottom = world_size_in_pixels.y

func _process(_delta):
	global_position = player.global_position

func _on_zoom_changed(value):
	# Clamp the value to ensure it stays within zoom limits
	value = clamp(value, pause_menu.zoom_slider.min_value, pause_menu.zoom_slider.max_value)
	# Apply the value to the zoom level
	zoom = Vector2(value, value)
	
	# Print for debugging purposes
	var zoom_level = value
	print("Zoom level set to: ", zoom_level)
