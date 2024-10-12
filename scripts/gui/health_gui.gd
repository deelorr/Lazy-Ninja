extends HBoxContainer

@onready var health_bar = $Label2/ProgressBar
#@onready var player = $Player

func _ready():
	#health_bar.value = 0
	#print(player)
	pass

func _process(_delta):
	#update_health(player.current_health, player.max_health)
	pass

#func update_health(health: int, max_health: int):
	#health_bar.value = health
	#health_bar.max_value = max_health
