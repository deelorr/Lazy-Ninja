extends CharacterBody2D

func _physics_process(delta: float) -> void:
	open_store()
	
func _on_area_2d_body_entered(body) -> void:
	if body is CharacterBody2D:
		Global.in_shop_range = true
		print(Global.in_shop_range)
		$AnimationPlayer.play("bubble_pop_up")
		print("can access store")

func open_store():
	if Global.in_shop_range == true and Input.is_action_just_pressed("action"):
		print("opening store")


func _on_area_2d_body_exited(body) -> void:
	if body is CharacterBody2D:
		Global.in_shop_range = false
		print(Global.in_shop_range)
		$AnimationPlayer.play("bubble_pop_down")
		print("cannot access store")
