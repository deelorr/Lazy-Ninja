extends HBoxContainer

@onready var heart_GUI = preload("res://scenes/gui/heart.tscn")

func set_max_hearts(max_hearts):
	for i in range(max_hearts):
		var heart = heart_GUI.instantiate()
		add_child(heart)

func update_hearts(current_health):
	var hearts = get_children()
	for i in range (current_health):
		hearts[i].update(true)
	for i in range (current_health, hearts.size()):
		hearts[i].update(false)
