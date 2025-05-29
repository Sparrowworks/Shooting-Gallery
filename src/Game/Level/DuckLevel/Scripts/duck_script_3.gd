extends GameScript

@onready var duck_zone_2: Marker2D = $DuckZone2
@onready var duck_zone_1: Marker2D = $DuckZone1

func activate() -> void:
	super()

	spawn_left_duck()
	spawn_right_duck()

func spawn_left_duck() -> void:
	var duck: Duck = spawn_enemy()

	duck.type = 3
	duck.speed = 1850
	duck.direction = Vector2.RIGHT
	duck.global_position = duck_zone_2.global_position
	duck.z_index = duck_zone_2.z_index
	game.add_child(duck)

func spawn_right_duck() -> void:
	var duck: Duck = spawn_enemy()

	duck.type = 3
	duck.speed = 1850
	duck.direction = Vector2.LEFT
	duck.global_position = duck_zone_1.global_position
	duck.z_index = duck_zone_1.z_index
	game.add_child(duck)
	duck.duck.flip_h = true
