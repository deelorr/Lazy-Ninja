extends Button

@onready var background_sprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer

var items_stack_gui: ItemStackGUI

func insert(isg: ItemStackGUI):
	items_stack_gui = isg
	background_sprite.frame = 1
	container.add_child(items_stack_gui)

	
