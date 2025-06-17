class_name KillLabel extends Node2D

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $Label/AnimationPlayer


func _ready() -> void:
	animation_player.play("Show")
	label.rotation_degrees = randf_range(-7.5, 7.5)


func set_score_text(score: int) -> void:
	label.text = "+" + str(score)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
