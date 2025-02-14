extends Weapon

#signal ninja_star_count_changed(new_count: int)

@onready var shuriken_scene: PackedScene = preload("res://scenes/items/weapons/shuriken_star.tscn")
@onready var can_fire_timer: Timer = $can_throw_timer
@onready var star: Area2D = $shuriken_star
@onready var player: Player = SceneManager.player

var can_throw: bool = true
var is_aiming: bool = false
var fire_rate: float = 0.3 
var shuriken_spawn_offset: int = 15 #distance from center

func _ready():
	star.disable() #disable star at start
	#ninja_star_count_changed.emit(player.combat.ninja_star_count)

func aim():
	is_aiming = true

func stop_aiming():
	is_aiming = false

func throw(target_position: Vector2):
	if not can_throw or player.combat.ninja_star_count <= 0:
		return
	can_throw = false
	can_fire_timer.start(fire_rate)
	player.combat.ninja_star_count -= 1
	#emit_signal("ninja_star_count_changed", player.combat.ninja_star_count)
	
	#get direction and position for the shuriken
	var direction = (target_position - global_position).normalized()
	var spawn_offset = direction * shuriken_spawn_offset
	var shuriken_position = global_position + spawn_offset
	var shuriken_star = shuriken_scene.instantiate()
	shuriken_star.position = shuriken_position
	shuriken_star.look_at(target_position)
	shuriken_star.direction = direction
	get_tree().current_scene.add_child(shuriken_star)

func _on_can_throw_timer_timeout():
	can_throw = true
