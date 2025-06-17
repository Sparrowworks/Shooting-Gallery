class_name Weapon extends AnimatedSprite2D

signal preloaded
signal weapon_fired(bullets_left: int)
signal weapon_reloaded

@export var weight: float = 0.5

@export var max_bullets: int = 3
@export var bullets: int = 3

@onready var firerate_timer: Timer = $FirerateTimer
@onready var reload_timer: Timer = $ReloadTimer
@onready var width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

@onready var shoot_sound: AudioStreamPlayer = $Shoot
@onready var dry_shoot: AudioStreamPlayer = $DryShoot
@onready var reload_sound: AudioStreamPlayer = $Reload

const CROSSHAIR = preload("res://assets/images/Game/crosshair.png")
const SANDCLOCK = preload("res://assets/images/Game/sandclock.png")

var can_shoot: bool = false


func _ready() -> void:
	set_upgrades()

	hide()
	set_process(false)


func game_preload() -> void:
	# Prevents lag by preloading sounds
	for sound: AudioStreamPlayer in [shoot_sound, dry_shoot, reload_sound]:
		sound.volume_db = linear_to_db(0.0)
		sound.play()
		await get_tree().create_timer(0.01).timeout
		sound.stop()
		sound.volume_db = linear_to_db(1.0)

	preloaded.emit()


func set_upgrades() -> void:
	# Buff the weapon stats according to bought upgrades

	match int(Globals.weapon_upgrades["reload"]):
		0:
			reload_timer.wait_time = 1
		1:
			reload_timer.wait_time = 0.85
		2:
			reload_timer.wait_time = 0.7
		3:
			reload_timer.wait_time = 0.5

	match int(Globals.weapon_upgrades["firerate"]):
		0:
			firerate_timer.wait_time = 0.85
		1:
			firerate_timer.wait_time = 0.65
		2:
			firerate_timer.wait_time = 0.5
		3:
			firerate_timer.wait_time = 0.4

	max_bullets = 3 + (1 * int(Globals.weapon_upgrades["ammo"]))
	bullets = max_bullets


func activate() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(CROSSHAIR, Input.CURSOR_ARROW, Vector2(32, 32))

	show()
	set_process(true)
	can_shoot = true


func deactivate() -> void:
	Input.set_custom_mouse_cursor(null)
	animation = "default"

	can_shoot = false

	reload_timer.stop()
	firerate_timer.stop()


func _process(delta: float) -> void:
	# Reduce the area where the weapon can follow the mouse
	global_position = Vector2(
		lerp(
			global_position.x,
			clamp(get_global_mouse_position().x, width * 0.05, width * 0.85),
			weight
		),
		lerp(
			global_position.y,
			clamp(get_global_mouse_position().y, height * 0.35, height * 0.9),
			weight
		)
	)

	if not can_shoot:
		return

	if Input.is_action_just_pressed("reload"):
		start_reload()

	if Input.is_action_pressed("shoot"):
		if bullets == 0:
			if Globals.is_auto_reload:
				start_reload()
			else:
				if firerate_timer.time_left <= 0 and reload_timer.time_left <= 0:
					firerate_timer.start()
					dry_shoot.play()
			return

		# Make sure we aren't reloading or waiting for the firerate cooldown
		if firerate_timer.time_left <= 0 and reload_timer.time_left <= 0:
			shoot()


func shoot() -> void:
	Input.set_custom_mouse_cursor(SANDCLOCK, Input.CURSOR_ARROW, Vector2(32, 32))

	shoot_sound.play()
	bullets -= 1
	weapon_fired.emit(bullets)

	if bullets == 0 and Globals.is_auto_reload:
		start_reload()
	else:
		animation = "empty"
		firerate_timer.start()


func start_reload() -> void:
	if reload_timer.time_left <= 0 and bullets < max_bullets and firerate_timer.time_left <= 0:
		Input.set_custom_mouse_cursor(SANDCLOCK, Input.CURSOR_ARROW, Vector2(32, 32))
		animation = "empty"

		reload_timer.start()
		reload_sound.play()


func _on_reload_timer_timeout() -> void:
	Input.set_custom_mouse_cursor(CROSSHAIR, Input.CURSOR_ARROW, Vector2(32, 32))
	animation = "default"

	bullets = max_bullets
	weapon_reloaded.emit()


func _on_firerate_timer_timeout() -> void:
	animation = "default"
	Input.set_custom_mouse_cursor(CROSSHAIR, Input.CURSOR_ARROW, Vector2(32, 32))
