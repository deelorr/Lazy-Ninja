extends Node2D

var weapon: Area2D
var weapons: Array
var active_weapon_index: int = 0
var bow

func _ready():
	bow = $bow
	weapons = get_children()
	if weapons.size() > 0:
		for w in weapons:
			w.disable()
		active_weapon_index = 0
		weapon = weapons[active_weapon_index]
		weapon.enable()
	else:
		weapon = null

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("switch_weapon"):
		change_active_weapon((active_weapon_index + 1) % weapons.size())
	if_bow_is_active()

func if_bow_is_active():
	if weapon == bow:
		enable()

func change_active_weapon(new_index: int):
	if new_index != active_weapon_index and new_index >= 0 and new_index < weapons.size():
		#disable the currently active weapon
		weapons[active_weapon_index].disable()
		#update to the new active weapon index
		active_weapon_index = new_index
		#enable the newly selected weapon
		weapon = weapons[active_weapon_index]
		scene_manager.player.current_weapon = weapon.name
		print("Current Weapon: ", scene_manager.player.current_weapon.capitalize())

func enable():
	if !weapon:
		return
	visible = true
	weapon.enable()

func disable():
	if !weapon:
		return
	visible = false
	weapon.disable()
