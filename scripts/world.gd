extends Node2D

@onready var hearts_container = $CanvasLayer/hearts_container

func _ready():
	hearts_container.set_max_hearts(3)

func _process(_delta):
	pass
