extends Control

# 📌 UI References
@onready var health_bar: ProgressBar = $BackgroundPanel/MarginContainer/MainUILayout/Stats/HealthUI/HealthBar
@onready var xp_bar: ProgressBar = $BackgroundPanel/MarginContainer/MainUILayout/Stats/ExpUI/ExpBar
@onready var current_lvl: Label = $BackgroundPanel/MarginContainer/MainUILayout/Stats/ExpUI/LevelContainer/LevelText/LevelNumber
@onready var xp_popup_label: Label = $XPPopUp  # Reference to XP pop-up


@onready var mana_bar: ProgressBar = $BackgroundPanel/MarginContainer/MainUILayout/Stats/ManaUI/ManaBar
# 📌 Player Reference
@onready var player: Player = SceneManager.player

# 📌 Track Previous Values
var previous_xp: int = 0  # Stores XP before changes to prevent unnecessary pop-ups
var low_health_tween: Tween  # Stores tween reference to stop flashing when health improves

### --------------------------- 🔹 INITIALIZATION 🔹 --------------------------- ###

func _ready():
	# Defer UI initialization to ensure player and inventory are loaded
	call_deferred("_initialize_ui")
	
func _initialize_ui():
	# Ensure player and progression exist before updating UI
	if player and player.progression:
		# Initialize UI elements
		update_health(player.current_health, player.max_health)
		update_xp(player.progression.current_xp, player.progression.xp_for_next_level)
		update_lvl(player.progression.current_level)
		
		update_mana(player.current_mana, player.max_mana)  # 🆕 Mana Bar!

		# Store the initial XP to avoid missing the first gain
		previous_xp = player.progression.current_xp  

		# Connect signals for updates when XP or health changes
		player.progression.connect("xp_changed", Callable(self, "_on_xp_changed"))
		player.connect("health_changed", Callable(self, "_on_health_changed"))

		player.connect("mana_changed", Callable(self, "_on_mana_changed"))


### --------------------------- 🔹 HEALTH UPDATES 🔹 --------------------------- ###

""" Updates the health bar and triggers low health warning if needed. """
func update_health(health: int, max_health: int):
	health_bar.max_value = max_health
	animate_bar(health_bar, health)  # Smooth bar animation

	# Determine health percentage and color
	var health_ratio = float(health) / max_health
	var new_color = get_health_color(health_ratio)
	animate_color(health_bar, new_color)  # Smooth color transition

	# Trigger low health warning if needed
	low_health_warning(health_ratio)

""" Triggers a flashing effect when health is critically low (< 20%). """
func low_health_warning(health_ratio: float):
	if health_ratio < 0.2:  # Health is below 20%
		if low_health_tween and low_health_tween.is_running():
			return  # Avoid restarting the tween unnecessarily

		# Start flashing effect
		low_health_tween = create_tween().set_loops()
		low_health_tween.tween_property(health_bar, "modulate", Color(1, 0, 0), 0.3)  # Flash red
		low_health_tween.tween_property(health_bar, "modulate", Color(1, 1, 1), 0.3)  # Return to normal
	else:
		# Stop flashing if health is restored
		if low_health_tween and low_health_tween.is_running():
			low_health_tween.kill()
		health_bar.modulate = Color(1, 1, 1)  # Reset color

""" Returns a color based on the player's health percentage. """
func get_health_color(health_ratio: float) -> Color:
	if health_ratio >= 0.66:  # High health → Green
		return Color(1, 1, 0).lerp(Color(0, 1, 0), (health_ratio - 0.66) / 0.34)
	elif health_ratio >= 0.33:  # Medium health → Yellow
		return Color(1, 0, 0).lerp(Color(1, 1, 0), (health_ratio - 0.33) / 0.33)
	else:  # Low health → Red
		return Color(1, 0, 0)

### --------------------------- 🔹 XP UPDATES 🔹 --------------------------- ###

""" Updates the XP bar, level display, and shows an XP gain pop-up if applicable. """
func update_xp(current_xp: int, xp_for_next_level: int):
	xp_bar.max_value = xp_for_next_level
	animate_bar(xp_bar, current_xp)  # Smooth bar animation

	# Determine XP percentage and color transition
	var xp_ratio = float(current_xp) / xp_for_next_level
	var new_color = Color(0, 0.5, 1).lerp(Color(0.6, 0, 1), xp_ratio)
	animate_color(xp_bar, new_color)  # Smooth color transition

	# Update level display
	update_lvl(player.progression.current_level)

	# Ensure first XP gain is properly detected
	if previous_xp == 0 and current_xp > 0:  # Handle first XP gain case
		show_xp_popup("+%d XP" % current_xp)  
	elif previous_xp > 0 and current_xp > previous_xp:  # Normal XP gain case
		show_xp_popup("+%d XP" % (current_xp - previous_xp))

	# Update previous XP **after** detecting the gain
	previous_xp = current_xp


""" Displays a floating XP pop-up above the XP bar. """
func show_xp_popup(text: String):
	xp_popup_label.text = text
	xp_popup_label.visible = true
	xp_popup_label.modulate = Color(1, 1, 1, 1)  # Full opacity

	# Store the original position before animation
	var original_position = xp_popup_label.position
	var end_position = original_position + Vector2(0, -1)  # Move up slightly

	# Animate movement and fade-out
	var tween = create_tween()
	tween.tween_property(xp_popup_label, "position", end_position, 1.0)
	tween.tween_property(xp_popup_label, "modulate", Color(1, 1, 1, 0), 1.0)  # Fade out

	await tween.finished
	xp_popup_label.visible = false  # Hide pop-up after animation

	# Reset position for the next pop-up
	xp_popup_label.position = original_position


""" Updates the player's displayed level. """
func update_lvl(level: int):
	current_lvl.text = str(level)
	
func update_mana(current_mana: int, max_mana: int):
	mana_bar.max_value = max_mana
	animate_bar(mana_bar, current_mana)  # Smooth bar animation

	# Optional: Change mana bar color (Blue → Purple)
	var mana_ratio = float(current_mana) / max_mana
	var new_color = Color(0, 0.5, 1).lerp(Color(0.6, 0, 1), mana_ratio)
	animate_color(mana_bar, new_color)  # Smooth transition


### --------------------------- 🔹 ANIMATIONS 🔹 --------------------------- ###

""" Smoothly animates a progress bar's value change. """
func animate_bar(bar: ProgressBar, new_value: float):
	var tween = create_tween()
	tween.tween_property(bar, "value", new_value, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

""" Smoothly animates a progress bar's color transition. """
func animate_color(bar: ProgressBar, new_color: Color):
	var tween = create_tween()
	tween.tween_property(bar, "modulate", new_color, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

### --------------------------- 🔹 SIGNAL CALLBACKS 🔹 --------------------------- ###

""" Triggered when XP changes; updates the XP bar and level. """
func _on_xp_changed(current_xp, xp_for_next_level):
	update_xp(current_xp, xp_for_next_level)

""" Triggered when health changes; updates the health bar and warnings. """
func _on_health_changed(new_health, new_max_health):
	update_health(new_health, new_max_health)

func _on_mana_changed(current_mana, max_mana):
	update_mana(current_mana, max_mana)
