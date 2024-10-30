extends Node2D

signal arrow_count_changed(new_count: int)

@export var arrow_scene: PackedScene
@export var fire_rate: float = 0.5 
@export var arrow_offset: Vector2 = Vector2(-5, 10)

@onready var shape = $CollisionShape2D
@onready var arrow_count: int = 50

var can_fire: bool = true
var is_aiming: bool = false

func _ready():
	arrow_scene = preload("res://scenes/items/weapons/arrow.tscn")
	arrow_count_changed.emit(arrow_count)
	visible = false

func aim():
	is_aiming = true

func stop_aiming():
	is_aiming = false
	rotation = 0
	# Reset the bow's global position to its default position
	global_position = get_parent().global_position  # Assuming the parent is the player or weapon node

func enable():
	shape.disabled = false
	visible = true

func disable():
	shape.disabled = true
	visible = false

func throw(target_position: Vector2):
	if not can_fire or arrow_count <= 0:
		return
	can_fire = false
	$can_fire_timer.start(fire_rate)
	arrow_count -= 1
	emit_signal("arrow_count_changed", arrow_count)
	
	# Use Bow's global position
	var bow_global_position = global_position
	var direction = (target_position - bow_global_position).normalized()
	var arrow_spawn_offset = direction * 20
	var arrow_position = bow_global_position + arrow_spawn_offset
	
	var arrow = arrow_scene.instantiate()
	arrow.position = arrow_position
	arrow.rotation = direction.angle()
	arrow.direction = direction
	get_tree().current_scene.add_child(arrow)


func _on_can_fire_timer_timeout():
	can_fire = true
