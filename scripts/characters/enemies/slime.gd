extends CharacterBody2D

@export var speed: int = 50
@export var limit: float = 0.5
@export var end_marker: Marker2D

@onready var animations = $AnimationPlayer

var start_position: Vector2
var target_position: Vector2
var is_dead: bool = false

func _ready():
	start_position = position
	target_position = end_marker.global_position

func _physics_process(_delta):
	if is_dead:
		return
	update_velocity()
	move_and_slide()
	update_animation()

func update_velocity():
	var move_direction = (target_position - position)
	if move_direction.length() < limit:
		change_direction()
	velocity = move_direction.normalized() * speed

func update_animation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
		return
	animations.play("walk_" + get_direction())

func get_direction() -> String:
	if velocity.x < 0:
		return "left"
	elif velocity.x > 0:
		return "right"
	elif velocity.y < 0:
		return "up"
	else:
		return "down"

func change_direction():
	var temp = target_position
	target_position = start_position
	start_position = temp

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area == $hit_box:
		return
	$hit_box.set_deferred("monitorable", false)
	is_dead = true
	animations.play("death")
	await animations.animation_finished
	Global.enemy_killed.emit("slime")
	scene_manager.player.add_xp(5)
	queue_free()
