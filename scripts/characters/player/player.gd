class_name Player
extends CharacterBody2D

signal health_changed(new_health: int)
signal gold_changed(new_gold: int)

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

var current_weapon = ""

var bow

var last_anim_direction: String = "down"
var is_hurt: bool = false
var is_attacking: bool = false

var gold: int = 150

func _ready():
	inventory.use_item.connect(use_item)
	weapon.disable()
	effects.play("RESET")
	bow = weapon.bow
	if bow == null:
		print("Error: 'bow' prop not found under 'weapon' ")

func _physics_process(_delta):
	handle_input()
	move_and_slide()
	update_animation()
	
	if !is_hurt:
		for area in hurt_box.get_overlapping_areas():
			if area.name == "hit_box":
				hurt_by_enemy_area(area)

func handle_input():
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * speed
	
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if current_weapon == "bow":
		if Input.is_action_pressed("ranged_attack"):
			var mouse_position = get_global_mouse_position()
			bow.shoot(mouse_position)

func update_animation():
	if is_attacking:
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

func attack():
	
	if is_attacking:
		return
		
	is_attacking = true
	animations.play("attack_" + last_anim_direction)
	#is_attacking = true
	weapon.enable()
	await animations.animation_finished
	weapon.disable()
	is_attacking = false

func knockback(enemy_velocity: Vector2):
	var knockback_direction = (enemy_velocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()

func hurt_by_enemy_area(area):
	current_health -= 1
	if current_health < 0:
		current_health = max_health
	health_changed.emit(current_health)
	is_hurt = true
	knockback(area.get_parent().velocity)
	effects.play("hurt_blink")
	hurt_timer.start()
	await hurt_timer.timeout
	effects.play("RESET")
	is_hurt = false

func _on_hurt_box_area_entered(area):
	if area.has_method("collect"):
		area.collect(inventory)
		
func increase_health(amount: int):
	current_health += amount
	current_health = min(max_health, current_health)
	
	health_changed.emit(current_health)
	
func use_item(item: InventoryItem):
	if not item.can_be_used(self):
		return
	item.use(self)
	inventory.remove_last_used_item()

func change_health(amount: int):
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	health_changed.emit(current_health)

func change_gold(amount: int):
	gold += amount
	gold_changed.emit(gold)

#func _unhandled_input(event):
	#if event.is_action_pressed("action"):
		#change_gold(10)
