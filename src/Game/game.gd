class_name Game extends Node2D

signal game_paused()

@onready var scripts_node: Node = $Scripts
@onready var ui: GameUI = $CanvasLayer/UI
@onready var pause_ui: Control = $CanvasLayer/PauseUi

@onready var game_theme: AudioStreamPlayer = $GameTheme

@onready var weapon: Weapon = $Weapon
@onready var test_target: Target = $TestTarget
@onready var test_duck: Duck = $TestDuck

@onready var time_timer: Timer = $TimeTimer
@onready var restart_timer: Timer = $RestartTimer

var level_file: Level
var is_ta: bool = false

var scripts: Array[GameScript] = []
var active_script: GameScript = null

var is_paused: bool = false
var is_gameover: bool = false

var time: int = 0
var combo: int = 1
var killed: int = 0
var total_shots: int = 0
var correct_shots: int = 0
var accuracy: int = 0

func _ready() -> void:
	kill_input()
	await Globals.transition.finished_solo_fade_out

	Globals.transition.loading_text.show()

	level_file = ResourceLoader.load(get_meta("data")) as Level
	load_background(level_file.background_type)

	# Set flags if playing Time Attack
	is_ta = get_meta("ta") as bool
	ui.is_ta = self.is_ta

	# Load the scripts and instantiate them
	for script in level_file.scripts:
		var instance: GameScript = script.instantiate()
		instance.game = self
		instance.weapon = weapon
		instance.script_finished.connect(_on_script_finished)
		scripts.append(instance)
		scripts_node.add_child(instance)

	# Set up the UI and the music

	if is_ta:
		ui.rank_scores = level_file.ta_rank_scores
		ui.score_text_value = level_file.ta_score
		ui.set_score(level_file.ta_score)
		ui.check_ta_rank(time)
	else:
		ui.rank_scores = level_file.rank_scores

	ui.set_title(level_file.level_title)
	ui.set_bullets(weapon.max_bullets, weapon.max_bullets)
	game_theme.stream = level_file.game_theme

	# If we haven't, precache (play the music for the first time as well as the particle effects for enemies)
	if not Globals.had_precached:
		game_theme.volume_db = linear_to_db(0.0)
		game_theme.play()
		await get_tree().create_timer(0.01).timeout
		game_theme.stop()
		game_theme.volume_db = linear_to_db(1.0)

		weapon.game_preload()
		await weapon.preloaded

		test_duck.game_preload()
		await test_duck.preloaded

		test_target.game_preload()
		await test_target.preloaded

	Globals.had_precached = true
	Globals.transition.loading_text.hide()
	Globals.transition.solo_curtain_rise()
	await Globals.transition.finished_fade_out

	# Play the ready animation
	ui.play_start()
	await ui.start_finished

	game_theme.play()

	time_timer.start()
	weapon.activate()

	activate_next_script()

func kill_input() -> void:
	set_process(false)
	set_process_input(false)

func load_background(type: int) -> void:
	match type:
		1:
			Globals.main.show_water()
		2:
			Globals.main.show_grass()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		kill_input()
		weapon.deactivate()
		Input.set_custom_mouse_cursor(null)
		Globals.go_to_with_fade("res://src/Menus/LevelSelect/LevelSelect.tscn")

	if Input.is_action_just_pressed("pause"):
		set_process_input(false)
		get_tree().paused = true
		game_paused.emit()

func _process(delta: float) -> void:
	# Detect if a player is holding down the reset button in order to restart or if he just wants to reload the weapon
	if Input.is_action_pressed("reset"):
		if restart_timer.time_left <= 0:
			restart_timer.start()

		ui.set_restart_bar(int(((restart_timer.wait_time-restart_timer.time_left)/restart_timer.wait_time)*100))
	else:
		if restart_timer.time_left > 0:
			ui.set_restart_bar(0)
			restart_timer.stop()
			weapon.start_reload()

func activate_next_script() -> void:
	# Grab the first script and activate it
	active_script = scripts.pop_front()

	# If we're playing Time Attack, we put the script back at the end in order to create a loop.
	if is_ta:
		scripts.push_back(active_script)

	# If the script is null, that means we reached the end and it's time to end the game
	if active_script == null:
		# Prevent causing more gameovers in a row
		if is_gameover:
			return

		is_gameover = true
		game_over()
		return

	active_script.activate()

func game_over() -> void:
	accuracy = clampi(roundi((correct_shots * 100) / total_shots), 0, 100)

	weapon.deactivate()
	time_timer.stop()

	await get_tree().create_timer(1).timeout
	Input.set_custom_mouse_cursor(null)
	Globals.go_to_with_fade("res://src/Menus/GameOver/GameOver.tscn", {"title": level_file.level_title, "score": ui.score_text_value, "accuracy": accuracy, "time": time, "rank": ui.rank_value, "id": level_file.level_id, "ta": is_ta})

func _on_weapon_weapon_fired(bullets_left: int) -> void:
	total_shots += 1
	ui.set_bullets(bullets_left, weapon.max_bullets)

func _on_weapon_weapon_reloaded() -> void:
	ui.set_bullets(weapon.max_bullets, weapon.max_bullets)

func _on_script_finished(script: GameScript) -> void:
	await get_tree().create_timer(1).timeout

	activate_next_script()

func _on_enemy_killed(enemy: Enemy) -> void:
	correct_shots += 1
	killed += 1
	ui.update_combo()

	var total_score: int = enemy.kill_score * ui.combo
	var label: KillLabel = enemy.KILL_SCENE.instantiate()
	add_child(label)

	label.global_position = enemy.global_position
	label.set_score_text(total_score)

	ui.score_to_update += total_score

func _on_ui_start_finished() -> void:
	# Allow collecting input from the player after we finish initializing and start-up
	set_process(true)
	set_process_input(true)

func _on_ui_ta_gameover() -> void:
	# Prevent causing more gameovers in a row
	if is_gameover:
		return

	is_gameover = true

	await get_tree().create_timer(1).timeout

	active_script._on_duration_timeout()
	get_tree().call_group("enemies", "gone") # Hide all present enemies
	weapon.deactivate()

	await get_tree().create_timer(0.5).timeout

	game_over()

func _on_pause_ui_game_unpaused() -> void:
	get_tree().paused = false
	Globals.button_click.play()

	await get_tree().create_timer(0.5).timeout
	set_process_input(true)

func _on_time_timer_timeout() -> void:
	time += 1

	ui.set_time(time)

func _on_restart_timer_timeout() -> void:
	ui.set_restart_bar(0)
	kill_input()
	Globals.go_to_game("res://src/Game/Game.tscn", {"data": get_meta("data"), "ta": get_meta("ta")})
