extends Resource
class_name PlayerProgression

signal xp_changed(new_xp, xp_for_next_level, new_level)  # Add `new_level`

var player: Player
var current_xp: int = 0
var current_level: int = 1
var xp_for_next_level: int = 100

func _init(p):
	player = p

func add_xp(amount: int):
	current_xp += amount
	check_level_up()  # Ensure level up logic runs before emitting the signal
	xp_changed.emit(current_xp, xp_for_next_level, current_level)  # Add level to signal
	print("Added XP: ", amount, " Total XP: ", current_xp, "/", xp_for_next_level)


func check_level_up():
	while current_xp >= xp_for_next_level:
		current_xp -= xp_for_next_level
		current_level += 1
		print("Leveled Up! New Level: %d" % current_level)
		xp_for_next_level = calculate_xp_for_level(current_level)

func calculate_xp_for_level(level: int) -> int:
	return 100 + (level - 1) * 50
