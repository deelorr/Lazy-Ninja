extends Control

@onready var player_team: Array = get_children()
@onready var enemy_team: Array = $"../enemy_team".get_children()
@onready var player = SceneManager.player

func _ready():
	player_team[0] = player

func _process(delta):
	pass
