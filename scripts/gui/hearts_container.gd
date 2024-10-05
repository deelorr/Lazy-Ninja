extends HBoxContainer

@onready var hearts = preload("res://scenes/gui/heart.tscn")

func _ready():
	pass

func _process(_delta):
	pass

func set_max_hearts(max_hearts):
	for i in range(max_hearts):
		var heart = hearts.instantiate()
		add_child(heart)