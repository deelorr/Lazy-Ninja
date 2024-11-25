extends CharacterBody2D
class_name Player

signal player_selected(player_node)

@export var max_health: int = 100
@export var speed: int = 35
@export var knockback_power: int = 500
@export var damage: int = 25

@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var effects: AnimationPlayer = $EffectsPlayer
@onready var hurt_box: Area2D = $hurt_box
@onready var hurt_timer: Timer = $hurt_timer
@onready var weapon_node: Node2D = $weapon
@onready var shuriken: Area2D = $weapon/shuriken
@onready var shuriken_noise: AudioStreamPlayer2D = $shuriken_noise

var current_health: int = max_health
var current_weapon: String = "sword"
var last_anim_direction: String = "down"
var is_hurt: bool = false
var is_attacking: bool = false
var is_jumping: bool = false
var gold: int = 50
var current_xp: int = 0
var current_level: int = 1
var xp_for_next_level: int = 100

func _ready():
	inventory.use_item.connect(use_item)  #connect the use_item signal to use_item function
	weapon_node.disable()  #disable weapon collision at start

func _physics_process(_delta):
	#esc to quit for now
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	handle_input()
	update_animation()
	if !is_hurt:
		for area in hurt_box.get_overlapping_areas():
			if area.name == "hit_box":
				hurt_by_enemy_area(area)
	move_and_slide()

func check_level_up():
	while current_xp >= xp_for_next_level:
		current_xp -= xp_for_next_level
		current_level += 1
		print("Leveled Up! New Level: %d" % current_level)
		xp_for_next_level = calculate_xp_for_level(current_level)
		
func calculate_xp_for_level(level: int) -> int:
	return 100 + (level - 1) * 50 #experience increases by 50 each level

func handle_input():
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * speed
	if current_weapon == "shuriken":
		if Input.is_action_pressed("attack"):
			aim_shuriken()
		elif Input.is_action_just_released("attack"):
			var mouse_position = get_global_mouse_position()
			var player_position = global_position
			var direction_vector = (mouse_position - player_position).normalized()
			last_anim_direction = get_direction_from_vector(direction_vector)
			throw_shuriken()
		else:
			shuriken.stop_aiming()
	else:
		if Input.is_action_just_pressed("attack"):
			var mouse_position = get_global_mouse_position()
			var player_position = global_position
			var direction_vector = (mouse_position - player_position).normalized()
			last_anim_direction = get_direction_from_vector(direction_vector)
			attack()

func get_direction_from_vector(direction_vector: Vector2) -> String:
	if abs(direction_vector.x) > abs(direction_vector.y):
		if direction_vector.x > 0:
			return "right"
		else:
			return "left"
	else:
		if direction_vector.y > 0:
			return "down"
		else:
			return "up"

func aim_shuriken():
	var mouse_position = get_global_mouse_position()
	var hurt_box_position = hurt_box.global_position
	var direction = (mouse_position - hurt_box_position).normalized()
	var shuriken_global_position = hurt_box_position + direction
	shuriken.global_position = shuriken_global_position
	shuriken.rotation = direction.angle()
	shuriken.aim()

func throw_shuriken():
	var mouse_position = get_global_mouse_position()
	shuriken.throw(mouse_position)
	shuriken_noise.play()
	animations.play("attack_" + last_anim_direction)
	shuriken.stop_aiming()

func update_animation():
	if is_attacking or is_jumping:
		return
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	elif Input.is_action_just_pressed("jump"):
		is_jumping = true
		if last_anim_direction == "left":
			animations.play("jump_left")
		elif last_anim_direction == "right":
			animations.play("jump_right")
		elif last_anim_direction == "up":
			animations.play("jump_up")
		else:
			animations.play("jump_down")
		await animations.animation_finished
		is_jumping = false
		return
	else:
		var direction = "down"
		if velocity.x < 0:
			direction = "left"
		elif velocity.x > 0:
			direction = "right"
		elif velocity.y < 0:
			direction = "up"
		animations.play("walk_" + direction)
		last_anim_direction = direction

func attack():
	if is_attacking:
		return
	is_attacking = true
	animations.play("attack_" + last_anim_direction)
	weapon_node.enable()
	await animations.animation_finished
	weapon_node.disable()
	is_attacking = false

func knockback(enemy_velocity: Vector2):
	var knockback_direction = (enemy_velocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()

func hurt_by_enemy_area(area):
	current_health -= 1
	if current_health < 0:
		current_health = max_health
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

func use_item(item: InventoryItem):
	if not item.can_be_used(self):
		return
	item.use(self)
	inventory.remove_last_used_item()

func change_gold(amount: int):
	gold += amount

func add_xp(amount: int):
	current_xp += amount
	print("Added XP: ", amount , " Total XP: " , current_xp, "/", xp_for_next_level)
	check_level_up()

func die():
	#if self in player_team:
		#player_team.erase(self)
	#elif self in enemy_team:
		#enemy_team.erase(self)
	queue_free()  # Free the object after removal
