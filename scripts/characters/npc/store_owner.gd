extends CharacterBody2D

@onready var store_gui = $"../CanvasLayer/StoreInventoryGUI"

var store_open: bool = false

func _physics_process(_delta: float) -> void:
	if Global.in_shop_range == true and Input.is_action_just_pressed("action"):
		DialogueManager.show_dialogue_balloon(load("res://dialogue/store_owner.dialogue"), "start")
		toggle_store()

func toggle_store():
	if store_open:
		store_gui.close()
		store_open = false
	else:
		store_gui.open()
		store_open = true

func _on_area_2d_body_entered(body) -> void:
	if body is CharacterBody2D:
		Global.in_shop_range = true
		$AnimationPlayer.play("bubble_pop_up")

func _on_area_2d_body_exited(body) -> void:
	if body is CharacterBody2D:
		Global.in_shop_range = false
		store_open = false
		$AnimationPlayer.play("bubble_pop_down")
