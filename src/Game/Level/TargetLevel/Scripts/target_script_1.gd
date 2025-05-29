extends GameScript

@onready var positions: Node2D = $Positions
@onready var spawn_timer: Timer = $SpawnTimer

var spawn_points: Dictionary[Marker2D, Target] = {

}

func activate() -> void:
	super()

	for point: Marker2D in positions.get_children():
		spawn_points[point] = null

	spawn_timer.start()

func deactivate_timers() -> void:
	super()

	spawn_timer.stop()

func get_free_position(list: Dictionary[Marker2D, Target]) -> Marker2D:
	# Get the first available free position to spawn the enemy at.
	var marker: Marker2D

	while true:
		marker = list.keys().pick_random()
		if list[marker] == null:
			break

	return marker

func select_type(target: Target) -> void:
	if total_enemies % 20 == 0:
		target.type = 5
		target.static_duration = 1.5
	elif total_enemies % 15 == 0:
		target.type = 4
		target.static_duration = 2.25
	elif total_enemies % 10 == 0:
		target.type = 3
		target.static_duration = 3
	elif total_enemies % 5 == 0:
		target.type = 2
		target.static_duration = 4
	else:
		target.type = 1
		target.static_duration = 5

func _on_killed(target: Target) -> void:
	var key: Marker2D = spawn_points.find_key(target)
	if key != null:
		spawn_points[key] = null
		return

func _on_spawn_timer_timeout() -> void:
	var target: Target = spawn_enemy()
	target.enemy_killed.connect(_on_killed)
	select_type(target)

	var pos: Marker2D = get_free_position(spawn_points)
	spawn_points[pos] = target

	target.global_position = pos.global_position
	target.z_index = positions.z_index
	game.add_child(target)
	target.spawn_fade_static()
