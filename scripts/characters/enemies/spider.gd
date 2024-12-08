extends CharacterBody2D

@export var speed: int = 50

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_timer: Timer = $direction_timer

var current_health: int = 2
var is_dead: bool = false
var is_chasing: bool = false
var player: Player = null

func _ready() -> void:
	player = SceneManager.player
	velocity = Vector2.DOWN * speed
	direction_timer.start()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	if is_chasing and player:
		chase_player()
	else:
		move_and_slide()
	update_animation()

func update_animation() -> void:
	if velocity.length() == 0:
		if animation_player.is_playing():
			animation_player.stop()
		return
	animation_player.play("walk_" + get_direction())

func get_direction() -> String:
	if abs(velocity.x) > abs(velocity.y):
		return "left" if velocity.x < 0 else "right"
	else:
		return "up" if velocity.y < 0 else "down"

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if not area.is_in_group("weapon"):
		return
	current_health -= 1
	if current_health <= 0:
		$hit_box.set_deferred("monitorable", false)
		is_dead = true
		animation_player.play("death")
		await animation_player.animation_finished
		Global.enemy_killed.emit("spider")
		Global.spider_count -= 1
		print("spider destroyed", Global.spider_count, "/", Global.max_spiders)
		SceneManager.player.progression.add_xp(10)
		queue_free()

func _on_direction_timer_timeout() -> void:
	if not is_chasing:
		var angle = randf() * 2 * PI  #random angle
		var new_direction = Vector2(cos(angle), sin(angle)).normalized()
		velocity = new_direction * speed
	direction_timer.start()

func chase_player() -> void:
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_detection_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		is_chasing = true

func _on_detection_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		is_chasing = false
