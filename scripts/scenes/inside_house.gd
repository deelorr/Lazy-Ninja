extends BaseScene

@onready var hearts_container = $CanvasLayer/hearts_container
@onready var camera = $follow_cam

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	camera.follow_node = player
	hearts_container.set_max_hearts(player.max_health)
	hearts_container.update_hearts(player.current_health)
	player.health_changed.connect(hearts_container.update_hearts)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
