extends NinePatchRect

@onready var player = $"../../Player"
@onready var gold_label = $VBoxContainer/Gold/gold_label
@onready var health_bar = $VBoxContainer/Health/Label2/ProgressBar

func _ready():
	#print(player)
	#print(player.gold)
	#print(health_bar.value)
	gold_label.text = str(player.gold)
	health_bar.value = 0

func _process(delta):
	update_health(player.current_health, player.max_health)
	update_gold()
	
func update_health(health: int, max_health: int):
	health_bar.value = health
	health_bar.max_value = max_health

func update_gold():
	if Input.is_action_just_pressed("action"):
		player.gold += 10
		gold_label.text = str(player.gold)
