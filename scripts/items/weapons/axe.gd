extends Area2D

@onready var shape = $CollisionShape2D

func enable():
	shape.disabled = false
	#visible = true

func disable():
	shape.disabled = true
	#visible = false
