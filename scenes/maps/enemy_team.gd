extends Control

@onready var enemy_team: Array = get_children()
@onready var player_team: Array = $"../player_team".get_children()

func _ready():
	print(enemy_team)
	print(player_team)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
