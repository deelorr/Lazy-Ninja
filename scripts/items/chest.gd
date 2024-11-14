extends Area2D

var in_zone: bool = false
var chest_open: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var chest_noise: AudioStreamPlayer2D = $chest_noise

func _process(_delta):
	if in_zone and Input.is_action_just_pressed("action"):
		if chest_open:
			close_chest()
		else:
			open_chest()

func _on_body_entered(body):
	if body.is_in_group("player"):
		in_zone = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		in_zone = false
		if chest_open:
			close_chest()

func open_chest():
	if not chest_open:
		print("Opening chest!")
		if animation_player:
			animation_player.play("open")
			chest_noise.play()
		chest_open = true

func close_chest():
	if chest_open:
		print("Closing chest!")
		if animation_player:
			animation_player.play("close")
			chest_noise.play()
		chest_open = false
