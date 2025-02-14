extends Control

@onready var weapon_icon = $WeaponSwitchPanel/WeaponIcon
@onready var weapon_name = $WeaponSwitchPanel/WeaponName
@onready var shuriken_count: Label = $WeaponSwitchPanel/ShurikenCount
@onready var player: Player = SceneManager.player

# Store weapon textures in a dictionary
const WEAPON_TEXTURES = {
	"sword": preload("res://art/items/Sword.png"),
	"axe": preload("res://art/items/Axe.png"),
	"spear": preload("res://art/items/Spear.png"),
	"shuriken": preload("res://art/items/Shuriken.png")
}

const DEFAULT_TEXTURE = preload("res://art/items/Treasure/GoldCoin.png") # Use a fallback texture

var last_weapon = ""

func _process(_delta):
	var current_weapon = player.combat.current_weapon
	if current_weapon != last_weapon:
		update_weapon_ui(current_weapon)
	
	# Show shuriken count only when needed
	shuriken_count.visible = current_weapon == "shuriken"
	if shuriken_count.visible:
		shuriken_count.text = str(player.combat.ninja_star_count)

func update_weapon_ui(weapon: String):
	last_weapon = weapon
	var tween = create_tween()  # Create a new tween instance

	# Fade out weapon icon and name
	tween.tween_property(weapon_icon, "modulate:a", 0, 0.1)
	tween.parallel().tween_property(weapon_name, "modulate:a", 0, 0.1)
	await tween.finished  # Wait until fade-out is complete

	# Update texture and weapon name
	weapon_icon.texture = WEAPON_TEXTURES.get(weapon, DEFAULT_TEXTURE)
	weapon_name.text = weapon.capitalize() if weapon in WEAPON_TEXTURES else "Unknown Weapon"

	# Fade in weapon icon and name
	tween = create_tween()
	tween.tween_property(weapon_icon, "modulate:a", 1, 0.1)
	tween.parallel().tween_property(weapon_name, "modulate:a", 1, 0.1)

	# Scale pop effect (Slight enlargement then back to normal)
	tween = create_tween()
	tween.tween_property(weapon_icon, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(weapon_icon, "scale", Vector2(1.0, 1.0), 0.05)
