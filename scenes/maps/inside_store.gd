extends BaseScene

@onready var hearts_container = $CanvasLayer/hearts_container
@onready var camera = $follow_cam

func _ready():
	super._ready()
	camera.follow_node = player
	hearts_container.set_max_hearts(player.max_health)
	hearts_container.update_hearts(player.current_health)
	player.health_changed.connect(hearts_container.update_hearts)

func _process(_delta):
	pass
