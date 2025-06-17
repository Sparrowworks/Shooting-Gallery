class_name Duck extends Enemy

@export_enum("Yellow: 1", "Brown: 2", "White: 3") var type: int = 1:
	set(val):
		type = val
		if duck:
			set_animation()

@onready var duck: AnimatedSprite2D = $MainPivot/StickPivot/Stick/DuckPivot/Duck


func on_ready() -> void:
	set_animation()


func set_animation() -> void:
	match type:
		1:
			kill_score = 25
			duck.animation = "yellow"
			cpu_particles_2d.texture = duck.sprite_frames.get_frame_texture("yellow", 0)
		2:
			kill_score = 50
			duck.animation = "brown"
			cpu_particles_2d.texture = duck.sprite_frames.get_frame_texture("brown", 0)
		3:
			kill_score = 100
			duck.animation = "white"
			cpu_particles_2d.texture = duck.sprite_frames.get_frame_texture("white", 0)


func spawn_static() -> void:
	hide()
	is_static = true

	if animation_player == null:
		await ready

	animation_player.play("show")
	await animation_player.animation_finished

	super()


func gone() -> void:
	direction = Vector2.ZERO
	animation_player.play("hide")


func on_enemy_gone() -> void:
	super()

	animation_player.play("hide")
	await animation_player.animation_finished
	queue_free()


func kill(quiet_kill: bool = false) -> void:
	super()

	animation_player.play("shot")
	await animation_player.animation_finished
	queue_free()
