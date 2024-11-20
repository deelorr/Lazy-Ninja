extends CharacterBody2D

@export var speed: int = 50

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_timer: Timer = $direction_timer

var is_dead: bool = false

func _ready() -> void:
	velocity = Vector2.DOWN * speed
	direction_timer.start()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	update_animation()
	move_and_slide()

func update_animation() -> void:
	if velocity.length() == 0:
		if animation_player.is_playing():
			animation_player.stop()
		return
	animation_player.play("walk_" + get_direction())

func get_direction():
	if abs(velocity.x) > abs(velocity.y):
		return "left" if velocity.x < 0 else "right"
	else:
		return "up" if velocity.y < 0 else "down"

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if not area.is_in_group("weapon"):
		return
	#load batle scene and return results
	$hit_box.set_deferred("monitorable", false)
	is_dead = true
	animation_player.play("death")
	await animation_player.animation_finished
	Global.enemy_killed.emit("slime")
	Global.slime_count -= 1
	print("slime destroyed", Global.slime_count, "/", Global.max_slimes)
	SceneManager.player.add_xp(5)
	queue_free()

func _on_direction_timer_timeout() -> void:
	var angle = randf() * 2 * PI  #random angle
	var new_direction = Vector2(cos(angle), sin(angle)).normalized()
	velocity = new_direction * speed
	direction_timer.start()
