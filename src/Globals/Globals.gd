extends Node

var had_precached: bool = false

var button_click: AudioStreamPlayer
var menu_theme: AudioStreamPlayer

var master_volume: float = 100.0
var music_volume: float = 100.0
var sfx_volume: float = 100.0
var is_auto_reload: bool = true

var main: Main
var transition: Transition

var DEFAULT_WEAPON_UPGRADES: Dictionary = {
	"ammo": 0,
	"reload": 0,
	"firerate": 0,
}

var DEFAULT_HIGHSCORES: Dictionary = {
	"duck_score": 0,
	"duck_rank": 0,
	"ta_duck_score": 0,
	"ta_duck_rank": 0,
	"duck_acc": 0,
	"target_score": 0,
	"target_rank": 0,
	"ta_target_score": 0,
	"ta_target_rank": 0,
	"target_acc": 0,
}

var weapon_upgrades: Dictionary = {}
var money_amount: int = 0

var highscores: Dictionary = {}

func _ready() -> void:
	await SaveSystem.loaded

	load_data()
	save_data()

func load_data() -> void:
	master_volume = SaveSystem.get_var("master_volume", 100.0)
	music_volume = SaveSystem.get_var("music_volume", 100.0)
	sfx_volume = SaveSystem.get_var("sfx_volume", 100.0)
	is_auto_reload = SaveSystem.get_var("auto_reload", true)
	weapon_upgrades = SaveSystem.get_var("upgrades", DEFAULT_WEAPON_UPGRADES)
	highscores = SaveSystem.get_var("highscores", DEFAULT_HIGHSCORES)
	money_amount = SaveSystem.get_var("money", 0)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume/100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume/100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume/100))

func save_data() -> void:
	SaveSystem.set_var("master_volume", master_volume)
	SaveSystem.set_var("music_volume", music_volume)
	SaveSystem.set_var("sfx_volume", sfx_volume)
	SaveSystem.set_var("auto_reload", is_auto_reload)
	SaveSystem.set_var("upgrades", weapon_upgrades)
	SaveSystem.set_var("money", money_amount)
	SaveSystem.set_var("highscores", highscores)

	SaveSystem.save()

func reset_data() -> void:
	master_volume = 100.0
	music_volume = 100.0
	sfx_volume = 100.0
	is_auto_reload = true
	money_amount = 0

	for key: String in weapon_upgrades.keys():
		weapon_upgrades[key] = 0

	for key: String in highscores.keys():
		highscores[key] = 0

	save_data()

func start_up() -> void:
	transition = Composer.setup_load_screen("res://src/Transition/CurtainTransition.tscn")
	await transition.ready

	if transition:
		Composer.load_scene("res://src/Menus/MainMenu/MainMenu.tscn")
		transition.fade_out()

func go_to_game(scene: String, data: Dictionary[String, Variant] = {}) -> void:
	if transition != null: return

	transition = Composer.setup_load_screen("res://src/Transition/CurtainTransition.tscn")
	await transition.ready

	if transition:
		button_click.play()
		transition.fade_in()
		await transition.finished_fade_in
		Composer.load_scene(scene, data)
		await Composer.finished_loading
		transition.solo_fade_out()
		await transition.finished_solo_fade_out

func go_to_with_fade(scene: String, data: Dictionary[String, Variant] = {}) -> void:
	if transition != null: return

	transition = Composer.setup_load_screen("res://src/Transition/CurtainTransition.tscn")
	await transition.ready

	if transition:
		button_click.play()
		Composer.finished_loading.connect(transition._on_finished_loading)

		transition.fade_in()
		await transition.finished_fade_in
		if data != {}:
			Composer.load_scene(scene, data)
		else:
			Composer.load_scene(scene)
