extends GameScript

@onready var spawn_timer: Timer = $SpawnTimer
@onready var positions: Node2D = $Positions


func activate() -> void:
	super()

	spawn_timer.start()


func deactivate_timers() -> void:
	super()

	spawn_timer.stop()


func _on_spawn_timer_timeout() -> void:
	for position: Marker2D in positions.get_children():
		var target: Target = spawn_enemy()
		target.type = 5
		target.static_duration = 0.75

		target.global_position = position.global_position
		target.z_index = positions.z_index
		game.add_child(target)
		target.spawn_static()
