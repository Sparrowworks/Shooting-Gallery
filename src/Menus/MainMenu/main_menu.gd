extends Control

@onready var version_text: Label = $MarginContainer/VersionText

func _ready() -> void:
	version_text.text = "v" + ProjectSettings.get_setting("application/config/version")

	if OS.has_feature("web"):
		$Buttons/QuitButton.hide()

	await Globals.transition.finished_fade_out

	if not Globals.menu_theme.playing:
		Globals.menu_theme.play()


func _on_play_button_pressed() -> void:
	Globals.go_to_with_fade("res://src/Menus/LevelSelect/LevelSelect.tscn")

func _on_settings_button_pressed() -> void:
	Globals.go_to_with_fade("res://src/Menus/Settings/Settings.tscn")

func _on_help_button_pressed() -> void:
	Globals.go_to_with_fade("res://src/Menus/Help/Help.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
