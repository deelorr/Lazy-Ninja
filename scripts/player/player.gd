class_name Player
extends CharacterBody2D

signal healthChanged

@export var speed: int = 35
@export var max_health: int = 3
@export var knockback_power: int = 500
@export var inventory: Inventory

@onready var animations = $AnimationPlayer
@onready var effects = $EffectsPlayer
@onready var hurt_box = $hurt_box
@onready var hurt_timer = $hurt_timer
@onready var weapon = $weapon
@onready var current_health: int = max_health

var last_anim_direction: String = "down"
var isHurt: bool = false
var isAttacking: bool = false

func _ready():
	effects.play("RESET")

func _physics_process(_delta):
	handle_input()
	move_and_slide()
	update_animation()
	
	if !isHurt:
		for area in hurt_box.get_overlapping_areas():
			if area.name == "hit_box":
				hurt_by_enemy_area(area)

func handle_input():
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * speed
	
	if Input.is_action_just_pressed("attack"):
		attack()

func attack():
	animations.play("attack_" + last_anim_direction)
	isAttacking = true
	weapon.enable()
	await animations.animation_finished
	weapon.disable()
	isAttacking = false

func update_animation():
	if isAttacking:
		return
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "down"
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"
		
		animations.play("walk_" + direction)
		last_anim_direction = direction

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
