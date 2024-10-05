extends Panel

@onready var sprite = $Sprite2D

func _ready():
	pass

func _process(_delta):
	pass

func update(whole: bool):
	if whole:
		sprite.frame = 4
	else:
		sprite.frame = 0
