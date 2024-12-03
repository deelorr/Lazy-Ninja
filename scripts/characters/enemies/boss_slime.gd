extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_timer: Timer = $direction_timer

var speed: int = 45
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
	animation_player.play("idle")

func get_direction():
	if abs(velocity.x) > abs(velocity.y):
		return "left" if velocity.x < 0 else "right"
	else:
		return "up" if velocity.y < 0 else "down"

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if not area.is_in_group("weapon"):
		return
	$hit_box.set_deferred("monitorable", false)
	is_dead = true
	animation_player.play("death")
	await animation_player.animation_finished
	Global.enemy_killed.emit("boss_slime")
	print("boss slime destroyed")
	SceneManager.player.add_xp(50)
	queue_free()

func _on_direction_timer_timeout() -> void:
	var angle = randf() * 2 * PI  #random angle
	var new_direction = Vector2(cos(angle), sin(angle)).normalized()
	velocity = new_direction * speed
	direction_timer.start()
