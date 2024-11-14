extends "res://scripts/items/collectables/collectable.gd"

@onready var animations = $AnimationPlayer
@onready var player = SceneManager.player
@onready var coin_noise: AudioStreamPlayer2D = $coin_noise

func _physics_process(_delta):
	animations.play("idle")

func collect(_inventory: Inventory):
	player.change_gold(10)
	coin_noise.play()
	await coin_noise.finished
	queue_free()
