class_name Transition extends CanvasLayer

signal finished_fade_in
signal finished_fade_out
signal finished_solo_fade_out

@onready var fade_rect: ColorRect = $Control/FadeRect
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer
@onready var loading_text: Label = %LoadingText


func fade_in() -> void:
	animation_player.play("CurtainFallFade")
	await animation_player.animation_finished
	finished_fade_in.emit()


func fade_out() -> void:
	animation_player.play("CurtainRiseFade")

	await animation_player.animation_finished

	finished_fade_out.emit()
	Composer.clear_load_screen()


func solo_fade_out() -> void:
	animation_player.play("FadeOut")

	await animation_player.animation_finished

	finished_solo_fade_out.emit()


func solo_curtain_rise() -> void:
	animation_player.play("CurtainRise")

	await animation_player.animation_finished

	finished_fade_out.emit()
	Composer.clear_load_screen()


func _on_finished_loading(_scene: Node) -> void:
	fade_out()
