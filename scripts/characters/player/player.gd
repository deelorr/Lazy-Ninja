extends "res://scripts/characters/CharacterClass.gd"
class_name Player

@onready var inventory: Inventory = preload("res://resources/inventory/player_inventory.tres")
@onready var combat = preload("res://scripts/characters/player/PlayerCombat.gd").new(self)
@onready var input_handler = preload("res://scripts/characters/player/PlayerInput.gd").new(self)
@onready var progression = preload("res://scripts/characters/player/PlayerProgression.gd").new(self)
@onready var effects: AnimationPlayer = $EffectsPlayer
@onready var hurt_timer: Timer = $hurt_timer
@onready var weapon_node: Node2D = $weapon
@onready var shuriken: Area2D = $weapon/shuriken
@onready var shuriken_noise: AudioStreamPlayer2D = $shuriken_noise
@onready var aim_line = $AimLine

func setup_character():
	speed = 100
	inventory.use_item.connect(use_item)  # Connect the use_item signal to the use_item function
	weapon_node.disable()  # Disable weapon collision at start

func _physics_process(_delta):
	input_handler.handle_input()
	update_animation()
	if !is_hurt:
		combat.check_enemy_hits()
	move_and_slide()

func use_item(item: InventoryItem):
	if not item.can_be_used(self):
		return
	item.use(self)
	inventory.remove_last_used_item()

func _on_hurt_box_area_entered(area):
	if area.has_method("collect"):
		area.collect(inventory)
