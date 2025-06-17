class_name Target extends Enemy

@export_enum("Red1: 1", "Red2: 2", "Red3: 3", "White: 4", "Color: 5") var type: int = 1:
	set(val):
		type = val
		if target:
			set_animation()

@export_enum("Fade: 1", "Static: 2") var spawn_type: int = 1

@onready var target: AnimatedSprite2D = $AnimatedSprite2D


func on_ready() -> void:
	set_animation()


func set_animation() -> void:
	match type:
		1:
			kill_score = 15
			target.animation = "red1"
			cpu_particles_2d.texture = target.sprite_frames.get_frame_texture("red1", 0)
		2:
			kill_score = 25
			target.animation = "red2"
			cpu_particles_2d.texture = target.sprite_frames.get_frame_texture("red2", 0)
		3:
			kill_score = 50
			target.animation = "red3"
			cpu_particles_2d.texture = target.sprite_frames.get_frame_texture("red3", 0)
		4:
			kill_score = 75
			target.animation = "white"
			cpu_particles_2d.texture = target.sprite_frames.get_frame_texture("white", 0)
		5:
			kill_score = 100
			target.animation = "color"
			cpu_particles_2d.texture = target.sprite_frames.get_frame_texture("color", 0)


func spawn_static() -> void:
	is_static = true
	spawn_type = 2

	if animation_player == null:
		await ready

	var prev_anim: String = target.animation

	animation_player.play("Show_start")
	await animation_player.animation_finished

	target.animation = prev_anim
	animation_player.play("Show_end")
	await animation_player.animation_finished

	super()


func spawn_fade_static() -> void:
	is_static = true
	spawn_type = 1

	if animation_player == null:
		await ready

	animation_player.play("FadeIn")
	await animation_player.animation_finished

	gone_timer.wait_time = static_duration
	gone_timer.start()


func gone() -> void:
	direction = Vector2.ZERO
	animation_player.play("Hide")


func on_enemy_gone() -> void:
	super()

	match spawn_type:
		1:
			animation_player.play("FadeOut")
		2:
			animation_player.play("Hide")

	await animation_player.animation_finished
	queue_free()


func kill(quiet_kill: bool = false) -> void:
	super()

	target.hide()
	cpu_particles_2d.emitting = true
	await cpu_particles_2d.finished

	queue_free()
