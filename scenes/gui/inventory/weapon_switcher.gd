extends Control

@onready var weapon_icon = $WeaponSwitchPanel/WeaponIcon
@onready var weapon_name = $WeaponSwitchPanel/WeaponName
@onready var player: Player = SceneManager.player

# Store weapon textures in a dictionary
const WEAPON_TEXTURES = {
	"sword": preload("res://art/items/Sword.png"),
	"axe": preload("res://art/items/Axe.png"),
	"spear": preload("res://art/items/Spear.png"),
	"shuriken": preload("res://art/items/Shuriken.png")
}

var last_weapon = ""

func _process(_delta):
	if player.combat.current_weapon != last_weapon:
		update_weapon_ui(player.combat.current_weapon)

func update_weapon_ui(weapon: String):
	last_weapon = weapon
	weapon_icon.texture = WEAPON_TEXTURES.get(weapon, null)
	weapon_name.text = weapon.capitalize() if weapon in WEAPON_TEXTURES else "None"

	# Set a fixed size for all icons
	weapon_icon.custom_minimum_size = Vector2(15, 15)  # Adjust to your preferred size
	weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # Keeps aspect ratio
