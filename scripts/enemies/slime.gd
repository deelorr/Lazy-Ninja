extends CharacterBody2D

@export var speed: int = 50
@export var limit: float = 0.5
@export var end_point: Marker2D

@onready var animations = $AnimationPlayer

var start_position
var end_position

var isDead = false

func _ready():
	start_position = position
	end_position = end_point.global_position

func change_direction():
	var temp_end = end_position
	end_position = start_position
	start_position = temp_end

func update_velocity():
	var move_direction = (end_position - position)
	if move_direction.length() < limit:
		change_direction()
	velocity = move_direction.normalized() * speed

func update_animation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "down"
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"

		animations.play("walk_" + direction)

func _physics_process(_delta):
	if isDead: return
	update_velocity()
	move_and_slide()
	update_animation()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area == $hit_box:
		return
	$hit_box.set_deferred("monitorable", false)
	isDead = true
	animations.play("death")
	await animations.animation_finished
	queue_free()
