extends Node2D

var weapon: Area2D
var weapons: Array
var active_weapon_index: int = 0
var bow

func _ready():
	bow = $BowPivot/bow
	weapons = get_children()
	if weapons.size() > 0:
		for w in weapons:
			if w == Area2D:
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
		# Disable the currently active weapon
		weapons[active_weapon_index].disable()
		
		# Update to the new active weapon index
		active_weapon_index = new_index
		
		# Get the selected weapon node
		var selected_weapon = weapons[active_weapon_index]
		
		# Check if the selected weapon is a Node2D (for the bow)
		if selected_weapon is Node2D:
			# Iterate through the children to find an Area2D (the actual bow)
			for child in selected_weapon.get_children():
				if child is Area2D:
					weapon = child
					break
		else:
			# Otherwise, assign the selected weapon directly (for sword or axe)
			weapon = selected_weapon

		# Set the current weapon for the player
		if weapon:
			SceneManager.player.current_weapon = weapon.name
			print("Current Weapon: ", SceneManager.player.current_weapon.capitalize())

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
