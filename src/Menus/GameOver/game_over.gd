extends Control

@onready var level_title: Label = %LevelTitle
@onready var score_text: Label = %ScoreText
@onready var accuracy_text: Label = %AccuracyText
@onready var time_text: Label = %TimeText
@onready var coin_text: Label = %CoinText
@onready var rank_text: Label = %RankText
@onready var hi_text: Label = %HIText
@onready var win_theme: AudioStreamPlayer = $WinTheme


func _ready() -> void:
	var time: int = get_meta("time") as int
	var accuracy: int = get_meta("accuracy") as int
	var score: int = get_meta("score") as int
	var is_ta: bool = get_meta("ta") as bool

	if is_ta:
		level_title.text = "You played: " + get_meta("title") + " in Time Attack mode"
	else:
		level_title.text = "You played: " + get_meta("title")

	var coins: int

	if is_ta:
		coins = get_ta_coins(get_meta("rank"))
		score_text.hide()
		coin_text.text = "You earned: " + str(coins) + " coins"
	else:
		coins = get_coins(score)
		score_text.text = "Total Score: " + str(score)
		coin_text.text = "You earned: " + str(coins) + " coins"

	accuracy_text.text = "Your accuracy: " + str(accuracy) + "%"
	time_text.text = "Time Spent: " + str(time)

	check_accuracy(accuracy)

	if is_ta:
		set_ta_rank()
		check_highscore(time, is_ta)
	else:
		set_rank()
		check_highscore(score, is_ta)

	Globals.money_amount += coins
	Globals.save_data()

	win_theme.play()


func set_rank() -> void:
	var rank: int = get_meta("rank") as int

	var rank_id: String = get_meta("id") + "_rank"
	Globals.highscores[rank_id] = rank

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


func set_ta_rank() -> void:
	var rank: int = get_meta("rank") as int

	var rank_id: String = "ta_" + get_meta("id") + "_rank"
	Globals.highscores[rank_id] = rank

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


func get_coins(score: int) -> int:
	return int(score / 100 * 0.65)


func get_ta_coins(rank: int) -> int:
	match rank:
		0:
			return 100
		1:
			return 250
		2:
			return 350
		3:
			return 500
		_:
			return 0


func check_highscore(score: int, ta: bool) -> void:
	var score_id: String
	if ta:
		score_id += "ta_"

	score_id += get_meta("id") + "_score"

	if Globals.highscores[score_id] < score:
		Globals.highscores[score_id] = score

		hi_text.show()


func check_accuracy(accuracy: int) -> void:
	var acc_id: String = get_meta("id") + "_acc"
	var cur_acc: int = Globals.highscores.get(acc_id, 0)

	if cur_acc < accuracy:
		Globals.highscores[acc_id] = accuracy


func _on_back_button_pressed() -> void:
	Globals.go_to_with_fade("res://src/Menus/LevelSelect/LevelSelect.tscn")
