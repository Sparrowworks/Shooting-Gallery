extends GameScript

@onready var left_timer: Timer = $LeftTimer
@onready var right_timer: Timer = $RightTimer
@onready var up_timer: Timer = $UpTimer

@onready var positions_left: Node2D = $PositionsLeft
@onready var positions_right: Node2D = $PositionsRight
@onready var positions_up: Node2D = $PositionsUp

var spawn_points_left: Dictionary[Marker2D, Target] = {}

var spawn_points_right: Dictionary[Marker2D, Target] = {}

var spawn_points_up: Dictionary[Marker2D, Target] = {}


func activate() -> void:
	super()

	for point: Marker2D in positions_left.get_children():
		spawn_points_left[point] = null

	for point: Marker2D in positions_right.get_children():
		spawn_points_right[point] = null

	for point: Marker2D in positions_up.get_children():
		spawn_points_up[point] = null

	left_timer.start()
	right_timer.start()
	up_timer.start()


func deactivate_timers() -> void:
	super()

	left_timer.stop()
	right_timer.stop()
	up_timer.stop()


func select_type(target: Target) -> void:
	if total_enemies % 15 == 0:
		target.type = 5
		target.speed = 1500
	elif total_enemies % 10 == 0:
		target.type = 4
		target.speed = 1250
	elif total_enemies % 5 == 0:
		target.type = 3
		target.speed = 1000
	elif total_enemies % 3 == 0:
		target.type = 2
		target.speed = 900
	else:
		target.type = 1
		target.speed = 800


func get_free_position(list: Dictionary[Marker2D, Target]) -> Marker2D:
	# Get the first available free position to spawn the enemy at.
	var marker: Marker2D

	while true:
		marker = list.keys().pick_random()
		if list[marker] == null:
			break

	return marker


func _on_killed(target: Target) -> void:
	var key1: Marker2D = spawn_points_left.find_key(target)
	if key1 != null:
		spawn_points_left[key1] = null
		return

	var key2: Marker2D = spawn_points_right.find_key(target)
	if key2 != null:
		spawn_points_right[key2] = null
		return

	var key3: Marker2D = spawn_points_up.find_key(target)
	if key3 != null:
		spawn_points_up[key3] = null
		return


func _on_left_timer_timeout() -> void:
	var target: Target = spawn_enemy()
	target.enemy_killed.connect(_on_killed)
	select_type(target)

	var pos: Marker2D = get_free_position(spawn_points_left)
	spawn_points_left[pos] = target

	target.direction = Vector2.RIGHT
	target.global_position = pos.global_position
	target.z_index = positions_left.z_index
	game.add_child(target)
	target.animation_player.play("Show")


func _on_right_timer_timeout() -> void:
	var target: Target = spawn_enemy()
	target.enemy_killed.connect(_on_killed)
	select_type(target)

	var pos: Marker2D = get_free_position(spawn_points_right)
	spawn_points_right[pos] = target

	target.direction = Vector2.LEFT
	target.global_position = pos.global_position
	target.z_index = positions_left.z_index
	game.add_child(target)
	target.animation_player.play("Show")


func _on_up_timer_timeout() -> void:
	var target: Target = spawn_enemy()
	target.enemy_killed.connect(_on_killed)
	select_type(target)

	var pos: Marker2D = get_free_position(spawn_points_up)
	spawn_points_up[pos] = target

	target.direction = Vector2.DOWN
	target.global_position = pos.global_position
	target.z_index = positions_left.z_index
	game.add_child(target)
	target.animation_player.play("Show")
