extends Weapon

signal ninja_star_count_changed(new_count: int)

@onready var ninja_star_scene: PackedScene = preload("res://scenes/items/weapons/ninja_star.tscn")
@onready var can_fire_timer: Timer = $can_throw_timer

var can_throw: bool = true
var is_aiming: bool = false
var ninja_star_count: int = 10
var fire_rate: float = 0.3 

func _ready():
	ninja_star_count_changed.emit(ninja_star_count)

func aim():
	is_aiming = true

func stop_aiming():
	is_aiming = false

func throw(target_position: Vector2):
	if not can_throw or ninja_star_count <= 0:
		return
	can_throw = false
	can_fire_timer.start(fire_rate)
	ninja_star_count -= 1
	emit_signal("ninja_star_count_changed", ninja_star_count)
	
	# Use Bow's global position
	var ninja_star_weapon_global_position = global_position
	var direction = (target_position - ninja_star_weapon_global_position).normalized()
	var ninja_star_spawn_offset = direction * 15
	var ninja_star_position = ninja_star_weapon_global_position + ninja_star_spawn_offset
	
	var ninja_star = ninja_star_scene.instantiate()
	ninja_star.position = ninja_star_position
	ninja_star.rotation = direction.angle()
	ninja_star.direction = direction
	get_tree().current_scene.add_child(ninja_star)

func _on_can_throw_timer_timeout():
	can_throw = true
