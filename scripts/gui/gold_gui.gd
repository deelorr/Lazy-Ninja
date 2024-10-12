extends HBoxContainer

@onready var gold_label = $gold_label
@onready var player = get_node("/root/World/Player")

func _ready():
	gold_label.text = str(player.gold)

func _process(delta):
	update_gold()

func update_gold():
	if Input.is_action_just_pressed("action"):
		player.gold += 10
		gold_label.text = str(player.gold)
