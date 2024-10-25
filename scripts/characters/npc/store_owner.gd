extends CharacterBody2D

@onready var store_gui: Control = $"../CanvasLayer/StoreInventoryGUI"
@onready var store_owner_dialogue: Resource = preload("res://dialogue/store_owner.dialogue")
@onready var animations: AnimationPlayer = $AnimationPlayer

var store_open: bool = false
var in_shop_range: bool = false

func _physics_process(_delta: float) -> void:
	if in_shop_range == true and Input.is_action_just_pressed("action"):
		DialogueManager.show_dialogue_balloon(store_owner_dialogue, "start")
		toggle_store()

func toggle_store() -> void:
	if store_open:
		store_gui.close()
		store_open = false
	else:
		store_gui.open()
		store_open = true

func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		in_shop_range = true
		animations.play("bubble_pop_up")

func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		if store_open:
			toggle_store()
			in_shop_range = false
			animations.play("bubble_pop_down")
