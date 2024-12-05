#extends Node2D
#
#@export var speed: float = 150
#
#@onready var collision_shape: CollisionShape2D = $Laser/Area2D/CollisionShape2D
#@onready var laserbeam = $Laser
#
#var max_distance: float = 250
#var distance_traveled: float = 0
#
#func _process(delta: float) -> void:
	## Move the laser
	#var movement = speed * delta
#
	#global_position += movement
	#distance_traveled += movement.length()
	#if distance_traveled >= max_distance:
		#queue_free()
