extends Control

# References to UI nodes.
# health_bar: The ProgressBar that shows the player's health.
@onready var health_bar: ProgressBar = $BackgroundPanel/MarginContainer/MainUILayout/Stats/HealthUI/HealthBar
# xp_bar: The ProgressBar that shows the player's XP progress.
@onready var xp_bar: ProgressBar = $BackgroundPanel/MarginContainer/MainUILayout/Stats/ExpUI/ExpBar
# current_lvl: The Label that displays the player's current level.
@onready var current_lvl: Label = $BackgroundPanel/MarginContainer/MainUILayout/Stats/ExpUI/LevelContainer/LevelText/LevelNumber
# player: A reference to the player instance, fetched from the SceneManager.
@onready var player: Player = SceneManager.player

func _ready():
	# Defer UI initialization to ensure the player and its progression are fully initialized.
	call_deferred("_initialize_ui")
	
func _initialize_ui():
	# Check that both the player and its progression resource exist.
	if player and player.progression:
		# Update the health bar with the player's current and maximum health.
		update_health(player.current_health, player.max_health)
		# Update the XP bar with the player's current XP and the XP required for the next level.
		update_xp(player.progression.current_xp, player.progression.xp_for_next_level)
		# Update the level display with the player's current level.
		update_lvl(player.progression.current_level)
		# Connect the xp_changed signal to update the XP bar and level when XP changes.
		player.progression.connect("xp_changed", Callable(self, "_on_xp_changed"))
		# Connect the health_changed signal to update the health bar when health changes.
		player.connect("health_changed", Callable(self, "_on_health_changed"))

func update_health(health: int, max_health: int):
	# Set the maximum value of the health bar.
	health_bar.max_value = max_health
	# Animate the health bar to the new health value.
	animate_bar(health_bar, health)

	# Calculate the ratio of current health to maximum health.
	var health_ratio = float(health) / max_health
	# Get a color based on the health ratio (green for high, yellow for medium, red for low).
	var new_color = get_health_color(health_ratio)
	# Animate the health bar color change.
	animate_color(health_bar, new_color)

func update_xp(current_xp: int, xp_for_next_level: int):
	# Set the maximum value of the XP bar.
	xp_bar.max_value = xp_for_next_level
	# Animate the XP bar to the current XP value.
	animate_bar(xp_bar, current_xp)

	# Calculate the XP ratio (progress towards the next level).
	var xp_ratio = float(current_xp) / xp_for_next_level
	# Interpolate between two colors (blue to purple) based on the XP ratio.
	var new_color = Color(0, 0.5, 1).lerp(Color(0.6, 0, 1), xp_ratio)
	# Animate the XP bar color change.
	animate_color(xp_bar, new_color)
	
	# Update the level display based on the player's current level.
	update_lvl(player.progression.current_level)

func update_lvl(level: int):
	# Update the level label text with the current level.
	current_lvl.text = str(level)

func get_health_color(health_ratio: float) -> Color:
	# Returns a color based on the health ratio:
	# - For high health (>= 66%), interpolate between yellow and green.
	if health_ratio >= 0.66:
		var t = (health_ratio - 0.66) / (1.0 - 0.66)
		return Color(1, 1, 0).lerp(Color(0, 1, 0), t)
	# - For medium health (>= 33%), interpolate between red and yellow.
	elif health_ratio >= 0.33:
		var t = (health_ratio - 0.33) / (0.66 - 0.33)
		return Color(1, 0, 0).lerp(Color(1, 1, 0), t)
	# - For low health (< 33%), return solid red.
	else:
		return Color(1, 0, 0)

func animate_bar(bar: ProgressBar, new_value: float):
	# Create a tween to animate the bar's "value" property.
	# The tween smoothly transitions the value over 0.5 seconds using a sine easing function.
	var tween = create_tween()
	tween.tween_property(bar, "value", new_value, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func animate_color(bar: ProgressBar, new_color: Color):
	# Create a tween to animate the bar's "modulate" property (its color).
	# The tween smoothly transitions the color over 0.3 seconds using a sine easing function.
	var tween = create_tween()
	tween.tween_property(bar, "modulate", new_color, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_xp_changed(current_xp, xp_for_next_level):
	# Callback function when XP changes:
	# Update the XP bar and level display with the new values.
	update_xp(current_xp, xp_for_next_level)

func _on_health_changed(new_health, new_max_health):
	# Callback function when health changes:
	# Update the health bar with the new health values.
	update_health(new_health, new_max_health)
