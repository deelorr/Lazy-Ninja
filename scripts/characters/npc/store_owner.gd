extends CharacterBody2D

@onready var store_gui: Control = $"../HUD/StoreInventoryGUI"
@onready var store_owner_dialogue: Resource = preload("res://dialogue/store_owner.dialogue")
@onready var animations: AnimationPlayer = $AnimationPlayer

var store_open: bool = false
var in_shop_range: bool = false
var waiting_for_dialogue: bool = false
var dialogue_mode: String = "welcome"  #tracks the current dialogue mode
var player: Player

func _physics_process(_delta: float) -> void:
	if in_shop_range and Input.is_action_just_pressed("action") and not waiting_for_dialogue:
		start_dialogue()

func start_dialogue() -> void:
	waiting_for_dialogue = true
	if dialogue_mode == "welcome":
		DialogueManager.show_dialogue_balloon(store_owner_dialogue, "start")
	elif dialogue_mode == "goodbye":
		DialogueManager.show_dialogue_balloon(store_owner_dialogue, "goodbye")
	if player:
		player.set_physics_process(false)
	DialogueManager.dialogue_ended.connect(Callable(self, "_on_dialogue_ended"))

func _on_dialogue_ended(_resource: DialogueResource):
	#disconnect to prevent multiple triggers
	DialogueManager.dialogue_ended.disconnect(Callable(self, "_on_dialogue_ended"))
	waiting_for_dialogue = false
	if dialogue_mode == "welcome":
		toggle_store()
		dialogue_mode = "goodbye"
	elif dialogue_mode == "goodbye":
		toggle_store()
		dialogue_mode = "welcome"
	if player and dialogue_mode == "welcome":
		player.set_physics_process(true)

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
		player = body  #store player reference
		animations.play("bubble_pop_up")

func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		in_shop_range = false
		player = null  #clear player reference
		animations.play("bubble_pop_down")
