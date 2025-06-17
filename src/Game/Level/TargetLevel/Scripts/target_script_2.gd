extends GameScript

@onready var spawn_timer: Timer = $SpawnTimer
@onready var positions: Node2D = $Positions

var current_position: int = -1
var target_spawn_points: Array[Marker2D]


func activate() -> void:
	super()

	for point: Marker2D in positions.get_children():
		target_spawn_points.append(point)

	spawn_timer.start()


func deactivate_timers() -> void:
	super()

	spawn_timer.stop()


func select_type(target: Target) -> void:
	if total_enemies % 10 == 0:
		target.type = 5
		target.static_duration = 1.5
	elif total_enemies % 5 == 0:
		target.type = 4
		target.static_duration = 2
	elif total_enemies % 3 == 0:
		target.type = 3
		target.static_duration = 3
	elif total_enemies % 2 == 0:
		target.type = 2
		target.static_duration = 3
	else:
		target.type = 1
		target.static_duration = 3


func _on_spawn_timer_timeout() -> void:
	current_position += 1
	if current_position >= target_spawn_points.size():
		spawn_timer.stop()
		return

	var target: Target = spawn_enemy()
	select_type(target)

	target.global_position = target_spawn_points[current_position].global_position
	target.z_index = positions.z_index
	game.add_child(target)
	target.spawn_static()
