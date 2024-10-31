extends Area2D
class_name Weapon

@onready var shape = $CollisionShape2D

func enable():
	shape.disabled = false
	visible = true

func disable():
	shape.disabled = true
	visible = false
