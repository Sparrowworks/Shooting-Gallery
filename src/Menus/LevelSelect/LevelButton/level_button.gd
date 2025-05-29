class_name LevelButton extends VBoxContainer

signal next_pressed()
signal prev_pressed()
signal normal_pressed(id: int)
signal ta_pressed(id: int)

@export var level_id: int = 0

@export var title: String = "":
	set(val):
		title = val
		if level_title:
			level_title.text = title

@export var level_img: CompressedTexture2D = null:
	set(val):
		level_img = val
		if level_icon:
			level_icon.texture = level_img

@export var highscore: int = 0:
	set(val):
		highscore = val
		if highscore_text:
			highscore_text.text = "Highscore: " + str(highscore)

@export var ta_highscore: int = 0:
	set(val):
		ta_highscore = val
		if ta_highscore_text:
			ta_highscore_text.text = "TA Fastest Time: " + str(ta_highscore)

@export var max_accuracy: int = 0:
	set(val):
		max_accuracy = val
		if accuracy_text:
			accuracy_text.text = "Highest accuracy: " + str(max_accuracy) + "%"

@export_enum("none: 0", "brown: 1", "silver: 2", "gold: 3", "platinum: 4") var rank: int = 4:
	set(val):
		rank = val
		set_rank_text()

@export_enum("none: 0", "brown: 1", "silver: 2", "gold: 3", "platinum: 4") var ta_rank: int = 0:
	set(val):
		ta_rank = val
		set_rank_text()

@onready var level_title: Label = %LevelTitle
@onready var level_icon: TextureRect = %LevelIcon
@onready var highscore_text: Label = %HighscoreText
@onready var rank_text: Label = %RankText
@onready var ta_highscore_text: Label = %TaHighscoreText
@onready var ta_rank_text: Label = %TaRankText
@onready var accuracy_text: Label = %AccuracyText

func _ready() -> void:
	highscore_text.text = "Highscore: " + str(highscore)
	ta_highscore_text.text = "TA Fastest Time: " + str(ta_highscore)
	accuracy_text.text = "Highest accuracy: " + str(max_accuracy) + "%"

	set_rank_text()

func set_rank_text() -> void:
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

	match ta_rank:
		0:
			ta_rank_text.text = "TA Rank: None"
			ta_rank_text.add_theme_color_override("font_outline_color", Color.BLACK)
		1:
			ta_rank_text.text = "TA Rank: Bronze"
			ta_rank_text.add_theme_color_override("font_outline_color", Color.SADDLE_BROWN)
		2:
			ta_rank_text.text = "TA Rank: Silver"
			ta_rank_text.add_theme_color_override("font_outline_color", Color.SILVER)
		3:
			ta_rank_text.text = "TA Rank: Gold"
			ta_rank_text.add_theme_color_override("font_outline_color", Color.GOLD)
		4:
			ta_rank_text.text = "TA Rank: Platinum"
			ta_rank_text.add_theme_color_override("font_outline_color", Color.SKY_BLUE)

func _on_left_button_pressed() -> void:
	Globals.button_click.play()
	next_pressed.emit()

func _on_right_button_pressed() -> void:
	Globals.button_click.play()
	prev_pressed.emit()

func _on_normal_button_pressed() -> void:
	normal_pressed.emit(level_id)

func _on_ta_button_pressed() -> void:
	ta_pressed.emit(level_id)
