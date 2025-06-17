class_name GameScript extends Node

signal script_activated(script: GameScript)
signal script_finished(script: GameScript)

@export var game: Game
@export var weapon: Weapon
@export var enemy_scene: PackedScene
@onready var duration: Timer = $Duration

var enemies_count: int = 0
var total_enemies: int = 0

var is_deactivated: bool = false


func _ready() -> void:
	if enemy_scene == null:
		printerr(
			"Warning! No enemy scene exists for ",
			name,
			". Make sure you assign one before trying to spawn an enemy."
		)


func activate() -> void:
	is_deactivated = false
	script_activated.emit(self)
	duration.start()


func deactivate_timers() -> void:
	pass


func deactivate() -> void:
	is_deactivated = true
	script_finished.emit(self)


func spawn_enemy() -> Enemy:
	if enemy_scene == null:
		printerr(
			"Warning! No enemy scene has been assigned to script ",
			name,
			". Failed trying to spawn an enemy."
		)
		return null

	total_enemies += 1
	enemies_count += 1

	var instance: Enemy = enemy_scene.instantiate()
	instance.enemy_killed.connect(enemy_killed_or_gone)
	instance.enemy_gone.connect(enemy_killed_or_gone)
	instance.enemy_killed.connect(game._on_enemy_killed)
	weapon.weapon_fired.connect(instance._on_weapon_fired)

	return instance


func enemy_killed_or_gone(enemy: Enemy) -> void:
	enemies_count -= 1
	# Checks If the last enemy is gone when the script is waiting to cleanup.
	if enemies_count <= 0 and duration.time_left <= 0 and not is_deactivated:
		deactivate()


func _on_duration_timeout() -> void:
	deactivate_timers()

	# Deactive the script if we got rid of all enemies, else wait till they're all gone
	if enemies_count <= 0 and not is_deactivated:
		deactivate()
