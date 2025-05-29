class_name GameUI extends Control

signal start_finished()
signal ta_gameover()

@onready var ready_text: TextureRect = $ReadyText
@onready var go_text: TextureRect = $Go

@onready var level_title: Label = %LevelTitle

@onready var time_text: Label = %TimeText
@onready var score_text: Label = %ScoreText
@onready var rank_text: Label = %RankText
@onready var rank_animation: AnimationPlayer = %RankAnimation

@onready var combo_text: Label = %ComboText
@onready var combo_animation: AnimationPlayer = %ComboAnimation

@onready var bonus_text: Label = %BonusText
@onready var bonus_animation: AnimationPlayer = %BonusAnimation

@onready var bullets: HBoxContainer = %Bullets

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var combo_timer: Timer = $ComboTimer

@onready var restart_bar: HBoxContainer = %RestartBar
@onready var restart_progress_bar: ProgressBar = %RestartProgressBar

const BULLET = preload("res://assets/images/UI/Bullet.png")
const EMPTY_BULLET = preload("res://assets/images/UI/EmptyBullet.png")

const SMALL_MAX_CLAMP_VALUE: int = 10
const MEDIUM_MAX_CLAMP_VALUE: int = 50
const BIG_MAX_CLAMP_VALUE: int = 100

var time_value: int = 0
var score_to_update: int = 0
var score_text_value: int = 0

var combo: int = 0
var combo_font_size: int = 72

var is_ta: bool = false

var rank_scores: Array[int]
var rank_value: int = 0

func _ready() -> void:
	set_rank(0)

func _process(delta: float) -> void:
	var update_value: int = 0

	# Clamp the score update value in order to prevent any slowdowns if the score is too big
	if score_to_update > 0 and score_to_update <= 500:
		update_value = clamp(score_to_update,1,SMALL_MAX_CLAMP_VALUE)
	elif score_to_update > 500 and score_to_update <= 2500:
		update_value = clamp(score_to_update,1,MEDIUM_MAX_CLAMP_VALUE)
	elif score_to_update > 2500:
		update_value = clamp(score_to_update,1,BIG_MAX_CLAMP_VALUE)

	if update_value > 0:
		score_to_update -= update_value

		if is_ta:
			# Make sure we don't go beyond 0 when reducing the score in Time Attack mode
			score_text_value = clampi(score_text_value - update_value, 0, 9999999999)
			if score_text_value <= 0:
				ta_gameover.emit()
		else:
			score_text_value += update_value
			check_rank(score_text_value)

		set_score(score_text_value)

func set_restart_bar(value: int) -> void:
	if value > 0:
		restart_bar.modulate = Color.WHITE
	else:
		restart_bar.modulate = Color.TRANSPARENT

	restart_progress_bar.value = value

func _on_combo_timer_timeout() -> void:
	combo = 0
	update_combo()

func play_start() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	animation_player.play("Start")
	await animation_player.animation_finished
	start_finished.emit()

func update_combo() -> void:
	combo += 1
	combo_timer.start()

	if combo > 2:
		combo_text.show()
		combo_text.text = "Combo x" + str(combo)
		combo_font_size = clamp(combo_font_size + 2, 72, 192) # Make the combo text bigger with a bigger combo
		combo_animation.play("Rotate")
	else:
		if combo_text.visible:
			combo_animation.play("FadeOut")

			await combo_animation.animation_finished

		combo_font_size = 72
		combo_timer.stop()

	combo_text.add_theme_font_size_override("font_size",combo_font_size)
	combo_text.add_theme_constant_override("outline_size",int(combo_font_size / 4))

func check_for_bonus(killed: int) -> void:
	# Special score bonuses for hitting special kill amounts
	if killed % 300 == 0:
		bonus_text.text = "300 ENEMIES SHOT - +30000 POINTS BONUS"
		score_to_update += 30000
	elif killed % 200 == 0:
		bonus_text.text = "200 ENEMIES SHOT - +20000 POINTS BONUS"
		score_to_update += 20000
	elif killed % 100 == 0:
		bonus_text.text = "100 ENEMIES SHOT - +10000 POINTS BONUS"
		score_to_update += 10000

	bonus_animation.play("Bonus")

	await bonus_animation.animation_finished
	bonus_animation.play("FadeOut")

func set_title(title: String) -> void:
	level_title.text = title

func set_time(time: int) -> void:
	if is_ta:
		# If the difference between the lower rank in Time Attack is 5 seconds then play a blinking animation indicating the incoming change
		var diff: int = rank_scores[rank_value] - time
		if diff <= 5 and not rank_animation.is_playing():
			rank_animation.play("Blink")
		elif diff > 5:
			rank_animation.stop()

	time_value = time
	time_text.text = "Time: " + str(time)

	if is_ta:
		check_ta_rank(time_value)

func set_score(score: int) -> void:
	score_text.text = "Score: " + str(score)

func set_bullets(bullets_left: int, max_bullets: int) -> void:
	# Show the amount of bullets that the weapon can hold and update their sprites (indicating the amount left in the "magazine")
	for x in range(0, max_bullets):
		var bullet: TextureRect = bullets.get_child(x)
		bullet.show()
		if x > bullets_left-1:
			bullet.texture = EMPTY_BULLET
		else:
			bullet.texture = BULLET

func check_rank(score: int) -> void:
	for x in range(rank_scores.size()-1, -1, -1):
		var score_to_check: int = rank_scores[x]
		if score >= score_to_check:
			set_rank(x)
			return

	set_rank(0)

func check_ta_rank(time: int) -> void:
	for x in range(rank_scores.size()-1, -1, -1):
		var time_to_check: int = rank_scores[x]
		if time <= time_to_check:
			set_ta_rank(x)
			return

	set_rank(0)

func set_rank(rank: int) -> void:
	rank_value = rank

	match rank:
		0:
			rank_text.text = "Rank: None"
			rank_text.add_theme_color_override("font_outline_color", Color.BLACK)
		1:
			rank_text.text = "Rank: Bronze"
			rank_text.add_theme_color_override("font_outline_color", Color.SADDLE_BROWN)
		2:
			rank_text.text = "Rank: Silver"
			rank_text.add_theme_color_override("font_outline_color", Color.SILVER)
		3:
			rank_text.text = "Rank: Gold"
			rank_text.add_theme_color_override("font_outline_color", Color.GOLD)
		4:
			rank_text.text = "Rank: Platinum"
			rank_text.add_theme_color_override("font_outline_color", Color.SKY_BLUE)

func set_ta_rank(rank: int) -> void:
	rank_value = rank

	match rank:
		0:
			rank_text.text = "Rank: Bronze"
			rank_text.add_theme_color_override("font_outline_color", Color.SADDLE_BROWN)
		1:
			rank_text.text = "Rank: Silver"
			rank_text.add_theme_color_override("font_outline_color", Color.SILVER)
		2:
			rank_text.text = "Rank: Gold"
			rank_text.add_theme_color_override("font_outline_color", Color.GOLD)
		3:
			rank_text.text = "Rank: Platinum"
			rank_text.add_theme_color_override("font_outline_color", Color.SKY_BLUE)
