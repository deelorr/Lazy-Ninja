extends Label

signal popup_finished

var log: Array = []  # To store all messages

@export var display_time: float = 2.0  # Time the popup stays visible
@export var fade_duration: float = 0.5  # Duration of fade-in and fade-out
@export var move_distance: Vector2 = Vector2(55, -95)  # Movement distance for pop-up effect

func _ready():
	# Initially hide the label
	visible = false
	modulate.a = 0.0  # Set opacity to 0

func show_popup(text: String) -> void:
	self.text = text  # Set the label text
	visible = true
	position = Vector2(55, 145)  # Ensure it starts at the correct position
	modulate.a = 0.0  # Reset opacity to fully transparent

	# Fade-in animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	await tween.finished

	# Wait for display_time
	await get_tree().create_timer(display_time).timeout

	# Fade-out animation
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	await tween.finished

	visible = false  # Hide the label after fading out
	emit_signal("popup_finished")
