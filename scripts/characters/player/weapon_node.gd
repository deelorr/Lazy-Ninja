extends Node2D

var weapon: Area2D
var weapons: Array
var active_weapon_index: int = 0

func _ready():
	weapons = get_children()
	if weapons.size() > 0:
		#disable all weapons initially
		for w in weapons:
			w.disable()
		#set the first weapon as active
		active_weapon_index = 0
		weapon = weapons[active_weapon_index]
		weapon.enable()
	else:
		weapon = null

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("switch_weapon"):
		change_active_weapon((active_weapon_index + 1) % weapons.size())

func change_active_weapon(new_index: int):
	if new_index != active_weapon_index and new_index >= 0 and new_index < weapons.size():
		#disable the currently active weapon
		weapons[active_weapon_index].disable()
		#update to the new active weapon index
		active_weapon_index = new_index
		#enable the newly selected weapon
		weapon = weapons[active_weapon_index]

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
