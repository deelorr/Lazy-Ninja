extends "res://scripts/items/collectables/collectable.gd"

@onready var animations = $AnimationPlayer
@onready var player = SceneManager.player

func _physics_process(_delta):
	animations.play("idle")

func collect(_inventory: Inventory):
	player.change_gold(10)
	queue_free()
