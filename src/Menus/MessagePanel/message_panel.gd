class_name MessagePanel extends Control

signal button_pressed

@onready var title_text: Label = %Title
@onready var contents: Label = %Contents
@onready var ok_button: TextureButton = %OkButton
@onready var no_button: TextureButton = %NoButton

var last_button_pressed: String = ""


func show_message(
	title: String, content: String, ok_text: String = "OK", show_no: bool = false
) -> void:
	show()

	title_text.text = title
	contents.text = content

	$Panel/VBoxContainer/HBoxContainer/OkButton/Label.text = ok_text
	no_button.visible = show_no


func _on_ok_button_pressed() -> void:
	Globals.button_click.play()
	button_pressed.emit()
	last_button_pressed = "Yes"
	hide()


func _on_no_button_pressed() -> void:
	Globals.button_click.play()
	button_pressed.emit()
	last_button_pressed = "No"
	hide()
