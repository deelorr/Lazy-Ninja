extends Label

@export var display_time: float = 2.0  # Time the popup stays visible
@export var fade_duration: float = 0.5  # Duration of fade-in and fade-out
@export var move_distance: Vector2 = Vector2(0, -50)  # Movement distance for pop-up effect

#@onready var tween: Tween = get_tree().create_tween()

func _ready():
	# Initially hide the label
	self.visible = false
	self.modulate.a = 0.0  # Set opacity to 0

func show_popup(text: String) -> void:
	self.text = text  # Set the label text
	self.visible = true
	self.position = Vector2.ZERO  # Reset position
	self.modulate.a = 0.0  # Reset opacity

	# Start the pop-up animation
	var tween = create_tween()
	tween.parallel()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", move_distance, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.finished

	await tween.finished

	# Wait for display_time
	await get_tree().create_timer(display_time).timeout

	# Start fade-out animation
	tween = create_tween()
	tween.parallel()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", self.position + Vector2(0, -move_distance.y), fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.finished

	await tween.finished

	visible = false
