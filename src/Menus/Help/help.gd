extends Control

@onready var title: Label = $Text/Title
@onready var main_text: Label = $Text/MainText
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_switching: bool = false
var page: int = 0

var headings: Array[String] = [
	"How to play:",
	"Controls:",
	"Credits:",
]
var content: Array[String] = [
	"""Your goal is to shoot down as many targets as you can. Move the mouse cursor over the enemy and then shoot
	with left mouse button. After each game, you earn coins based on your performance. Spend them in the store
	to upgrade your weapon and make it more powerful for the next rounds!

	Time Attack mode is a special mode where you have to lower the score to 0 as quickly as you can. Faster playthrough
	will earn you more coins than a longer one. This mode loops the waves of enemies until you reach 0 score.""",
	"""Left Mouse Button - Shoot

	Right Mouse Button / Press R - Reload

	Hold R (2 seconds) - Restart Game

	P - Pause/Unpause Game

	Esc - Quit to menu""",
	"""Developed by sparrowworks:
	programmer, game designer - sp4r0w
	game designer, tester - varga

	graphical assets:
	shooting gallery pack by kenney

	music:
	BATTLE OF THE VOID BY MARCELO FERNANDEZ
	ABSTRACTION MUSIC PACK BY BEN BURNES"""
]


func _ready() -> void:
	title.text = headings[page]
	main_text.text = content[page]


func _on_next_button_pressed() -> void:
	if is_switching:
		return

	is_switching = true
	page = (page + 1) % content.size()

	animation_player.play("FadeIn")
	await animation_player.animation_finished

	title.text = headings[page]
	main_text.text = content[page]

	animation_player.play("FadeOut")
	await animation_player.animation_finished

	is_switching = false


func _on_back_button_pressed() -> void:
	Globals.go_to_with_fade("res://src/Menus/MainMenu/MainMenu.tscn")
