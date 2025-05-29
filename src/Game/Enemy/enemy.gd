class_name Enemy extends Node2D

signal preloaded()
signal enemy_killed(enemy: Enemy)
signal enemy_gone(enemy: Enemy)

static var KILL_SCENE: PackedScene = preload("res://src/Game/Enemy/KillLabel/KillLabel.tscn")

@export var game_scene: Game = null

@export var kill_score: int = 100
@export var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 500
@export var is_static: bool = false:
	set(val):
		is_static = val
		set_physics_process(!is_static)

@export var static_duration: float = 1.0:
	set(val):
		static_duration = val

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gone_timer: Timer = $GoneTimer
@onready var shoot_sound: AudioStreamPlayer = $ShootSound

var is_being_targeted: bool = false

func game_preload() -> void:
	# Prevents lag by preloading sounds
	shoot_sound.volume_db = linear_to_db(0.0)
	shoot_sound.play()
	await get_tree().create_timer(0.01).timeout
	shoot_sound.stop()
	shoot_sound.volume_db = linear_to_db(1.0)

	cpu_particles_2d.emitting = true
	await cpu_particles_2d.finished
	preloaded.emit()

func _ready() -> void:
	set_physics_process(!is_static)
	set_process_input(false)

	if is_static:
		spawn_static()

	on_ready()

func on_ready() -> void:
	# Allow setting up stuff in _ready without overriding it again
	pass

func _physics_process(delta: float) -> void:
	# Only move the enemy if it isn't a static one
	global_position += direction * speed * delta

func _on_area_2d_mouse_entered() -> void:
	is_being_targeted = true

func _on_area_2d_mouse_exited() -> void:
	is_being_targeted = false

func _on_gone_timer_timeout() -> void:
	on_enemy_gone()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_enemy_gone()

func _on_weapon_fired(bullets: int) -> void:
	if is_being_targeted:
		kill()

func spawn_static() -> void:
	gone_timer.wait_time = static_duration
	gone_timer.start()

func gone() -> void:
	# Called when Time Attack mode is ending.
	pass

func on_enemy_gone() -> void:
	# This is called when the enemy goes off-screen or when the static time has ended
	enemy_gone.emit(self)

func kill() -> void:
	shoot_sound.play()
	gone_timer.stop()
	direction = Vector2.ZERO

	enemy_killed.emit(self)
