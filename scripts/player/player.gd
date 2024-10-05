extends CharacterBody2D

class_name Player

signal healthChanged

@export var speed = 35
@onready var animations = $AnimationPlayer

@export var max_health: int = 3
@onready var current_health: int = max_health

func _ready():
	pass

func _physics_process(_delta):
	handle_input()
	move_and_slide()
	handleCollision()
	update_animation()

func handle_input():
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * speed

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

func handleCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		#print_debug(collider.name)

func _on_hurt_box_area_entered(area:Area2D):
	if area.name == "hit_box":
		current_health -= 1
		if current_health < 0:
			current_health = max_health
		healthChanged.emit(current_health)
