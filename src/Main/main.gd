class_name Main extends Control

@onready var menu_theme: AudioStreamPlayer = $MenuTheme
@onready var button_click: AudioStreamPlayer = $ButtonClick

@onready var water: Parallax2D = $Water
@onready var water_2: Parallax2D = $Water2

@onready var grass: Parallax2D = $Grass
@onready var grass_2: Parallax2D = $Grass2

func _ready() -> void:
	Globals.main = self
	Globals.menu_theme = menu_theme
	Globals.button_click = button_click

	# Prevents lag by preloading and pre-playing music
	Globals.menu_theme.volume_db = linear_to_db(0.0)
	Globals.menu_theme.play()
	await get_tree().create_timer(0.01).timeout
	Globals.menu_theme.stop()
	Globals.menu_theme.volume_db = linear_to_db(1.0)

	Globals.button_click.volume_db = linear_to_db(0.0)
	Globals.button_click.play()
	await get_tree().create_timer(0.01).timeout
	Globals.button_click.stop()
	Globals.button_click.volume_db = linear_to_db(1.0)

	show_water()
	Globals.start_up()

func show_water() -> void:
	water.show()
	water_2.show()

	grass.hide()
	grass_2.hide()

func show_grass() -> void:
	grass.show()
	grass_2.show()

	water.hide()
	water_2.hide()
