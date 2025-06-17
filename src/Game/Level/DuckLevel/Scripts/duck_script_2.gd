extends GameScript

@onready var left: Timer = $Left
@onready var right: Timer = $Right

@onready var duck_zone_2: Marker2D = $DuckZone2
@onready var duck_zone_1: Marker2D = $DuckZone1


func activate() -> void:
	super()

	left.start()
	right.start()


func deactivate_timers() -> void:
	super()

	left.stop()
	right.stop()


func select_type(duck: Duck) -> void:
	if total_enemies % 10 == 0:
		duck.type = 3
		duck.speed = 1250
	elif total_enemies % 5 == 0:
		duck.type = 2
		duck.speed = 850
	else:
		duck.type = 1
		duck.speed = 600


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
