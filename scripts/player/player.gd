extends CharacterBody2D

class_name Player

signal healthChanged

@export var speed = 35
@onready var animations = $AnimationPlayer
@onready var effects = $EffectsPlayer
@onready var hurt_box = $hurt_box
@onready var hurt_timer = $hurt_timer

@export var max_health: int = 3
@onready var current_health: int = max_health

@export var knockback_power = 500

@export var inventory: Inventory

var isHurt = false

func _ready():
	effects.play("RESET")

func _physics_process(_delta):
	handle_input()
	move_and_slide()
	handleCollision()
	update_animation()
	if !isHurt:
		for area in hurt_box.get_overlapping_areas():
			if area.name == "hit_box":
				hurt_by_enemy_area(area)

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
		print_debug(collider.name)
		
func knockback(enemy_velocity: Vector2):
	var knockback_direction = (enemy_velocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()
	
func hurt_by_enemy_area(area):
	current_health -= 1
	if current_health < 0:
		current_health = max_health
	healthChanged.emit(current_health)
	isHurt = true
	knockback(area.get_parent().velocity)
	effects.play("hurt_blink")
	hurt_timer.start()
	await hurt_timer.timeout
	effects.play("RESET")
	isHurt = false
	

func _on_hurt_box_area_entered(area:Area2D):
	if area.has_method("collect"):
		area.collect(inventory)


func _on_hurt_box_area_exited(area: Area2D):
	pass
