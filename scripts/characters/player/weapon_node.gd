extends Node2D

var weapon: Area2D
var weapons: Array
var active_weapon_index: int = 0

func _ready():
	# Initialize the array with only Area2D nodes
	weapons = get_children().filter(func(w): return w is Area2D)

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

func change_active_weapon(new_index: int):
	if new_index != active_weapon_index and new_index >= 0 and new_index < weapons.size():
		# Disable the currently active weapon
		weapons[active_weapon_index].disable()
		# Update to the new active weapon index
		active_weapon_index = new_index
		# Set the new active weapon
		weapon = weapons[active_weapon_index]
		# Set the current weapon for the player
		if weapon:
			SceneManager.player.current_weapon = weapon.name
			print("Current Weapon: ", SceneManager.player.current_weapon.capitalize())

func enable():
	if not weapon:
		return
	weapon.enable()

func disable():
	if not weapon:
		return
	weapon.disable()
