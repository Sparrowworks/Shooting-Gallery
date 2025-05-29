extends GameScript

@onready var spawn_up: Timer = $SpawnUp
@onready var spawn_down: Timer = $SpawnDown
@onready var left: Timer = $Left
@onready var right: Timer = $Right

@onready var duck_zone_2: Marker2D = $DuckZone2
@onready var duck_zone_1: Marker2D = $DuckZone1
@onready var positions_up: Node2D = $PositionsUp
@onready var positions_down: Node2D = $PositionsDown

var spawn_points_up: Dictionary[Marker2D, Duck] = {

}

var spawn_points_down: Dictionary[Marker2D, Duck] = {

}

func activate() -> void:
	super()

	for point: Marker2D in positions_up.get_children():
		spawn_points_up[point] = null

	for point: Marker2D in positions_down.get_children():
		spawn_points_down[point] = null

	spawn_up.start()
	spawn_down.start()
	left.start()
	right.start()

func deactivate_timers() -> void:
	super()

	spawn_up.stop()
	spawn_down.stop()
	left.stop()
	right.stop()

func select_type(duck: Duck) -> void:
	if total_enemies % 15 == 0:
		duck.type = 3
		duck.static_duration = 1
		duck.speed = 1650
	elif total_enemies % 10 == 0:
		duck.type = 2
		duck.static_duration = 1.5
		duck.speed = 1350
	else:
		duck.type = 1
		duck.static_duration = 2.5
		duck.speed = 1000

func get_free_position(list: Dictionary[Marker2D, Duck]) -> Marker2D:
	# Get the first available free position to spawn the enemy at.
	var marker: Marker2D

	while true:
		marker = list.keys().pick_random()
		if list[marker] == null:
			break

	return marker

func _on_killed(duck: Duck) -> void:
	var key1: Marker2D = spawn_points_up.find_key(duck)
	if key1 != null:
		spawn_points_up[key1] = null
		return

	var key2: Marker2D = spawn_points_down.find_key(duck)
	if key2 != null:
		spawn_points_down[key2] = null
		return

func _on_spawn_up_timeout() -> void:
	var duck: Duck = spawn_enemy()
	duck.enemy_killed.connect(_on_killed)
	select_type(duck)

	var pos: Marker2D = get_free_position(spawn_points_up)
	spawn_points_up[pos] = duck

	duck.global_position = pos.global_position
	duck.z_index = positions_up.z_index
	game.add_child(duck)
	duck.spawn_static()

func _on_spawn_down_timeout() -> void:
	var duck: Duck = spawn_enemy()
	duck.enemy_killed.connect(_on_killed)
	select_type(duck)

	var pos: Marker2D = get_free_position(spawn_points_down)
	spawn_points_down[pos] = duck

	duck.global_position = pos.global_position
	duck.z_index = positions_down.z_index
	game.add_child(duck)
	duck.spawn_static()
	duck.duck.flip_h = true

func _on_left_timeout() -> void:
	var duck: Duck = spawn_enemy()
	select_type(duck)

	duck.direction = Vector2.RIGHT
	duck.global_position = duck_zone_2.global_position
	duck.z_index = duck_zone_2.z_index
	game.add_child(duck)

func _on_right_timeout() -> void:
	var duck: Duck = spawn_enemy()
	select_type(duck)

	duck.direction = Vector2.LEFT
	duck.global_position = duck_zone_1.global_position
	duck.z_index = duck_zone_1.z_index
	game.add_child(duck)
	duck.duck.flip_h = true
