extends BaseScene

@onready var hearts_container = $CanvasLayer/hearts_container
@onready var camera = $follow_cam
@onready var stat_panel = $CanvasLayer/StatPanel

func _ready():
	super._ready()
	camera.follow_node = local_player

func _process(_delta):
	pass
