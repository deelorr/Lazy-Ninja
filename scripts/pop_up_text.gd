extends Label

signal popup_finished

@export var display_time: float = 1.0  # Time the popup stays visible
@export var fade_duration: float = 0.5  # Duration of fade-in and fade-out

func _ready():
	visible = false
	modulate.a = 0.0  # Set opacity to 0

func show_popup(varargs) -> void:
	if typeof(varargs) == TYPE_STRING:  # Single string input
		varargs = [varargs]
	elif typeof(varargs) != TYPE_ARRAY:  # Ensure it's an array
		varargs = [str(varargs)]
	# Concatenate arguments into a single string
	text = ""
	for arg in varargs:
		text += str(arg) + " "
	text = text.strip_edges()  # Remove extra spaces at the start or end

	# Existing popup logic
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
	popup_finished.emit()
