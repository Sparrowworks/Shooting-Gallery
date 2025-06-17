extends Control

@onready var money_text: Label = %MoneyText
@onready var level_button: LevelButton = $LevelButton

const DUCK_PREVIEW = preload("res://assets/images/UI/duck_preview.png")
const TARGET_PREVIEW = preload("res://assets/images/UI/target_preview.png")

var level_data: Array[Dictionary] = [
	{
		"title": "Duck Hunt",
		"icon": DUCK_PREVIEW,
		"highscore": Globals.highscores["duck_score"],
		"rank": Globals.highscores["duck_rank"],
		"ta_highscore": Globals.highscores["ta_duck_score"],
		"ta_rank": Globals.highscores["ta_duck_rank"],
		"accuracy": Globals.highscores.get("duck_acc", 0),
		"file": "res://src/Game/Level/DuckLevel/DuckLevel.tres",
	},
	{
		"title": "Target Hunt",
		"icon": TARGET_PREVIEW,
		"highscore": Globals.highscores["target_score"],
		"rank": Globals.highscores["target_rank"],
		"ta_highscore": Globals.highscores["ta_target_score"],
		"ta_rank": Globals.highscores["ta_target_rank"],
		"accuracy": Globals.highscores.get("target_acc", 0),
		"file": "res://src/Game/Level/TargetLevel/TargetLevel.tres",
	},
]


func _ready() -> void:
	if not Globals.menu_theme.playing:
		Globals.menu_theme.play()

	money_text.text = str(Globals.money_amount)

	update_level()


func update_level() -> void:
	var level_info: Dictionary = level_data[level_button.level_id]
	level_button.title = level_info["title"]
	level_button.level_img = level_info["icon"]
	level_button.highscore = level_info["highscore"]
	level_button.rank = level_info["rank"]
	level_button.ta_highscore = level_info["ta_highscore"]
	level_button.max_accuracy = level_info["accuracy"]

	if level_info["ta_highscore"] == 0:
		level_button.ta_rank = level_info["ta_rank"]
	else:
		level_button.ta_rank = level_info["ta_rank"] + 1


func _on_level_button_next_pressed() -> void:
	level_button.level_id += 1
	if level_button.level_id > 1:
		level_button.level_id = 0

	update_level()


func _on_level_button_prev_pressed() -> void:
	level_button.level_id -= 1
	if level_button.level_id < 0:
		level_button.level_id = 1

	update_level()


func _on_level_button_normal_pressed(id: int) -> void:
	Globals.menu_theme.stop()
	Globals.go_to_game(
		"res://src/Game/Game.tscn", {"data": level_data[level_button.level_id]["file"], "ta": false}
	)


func _on_level_button_ta_pressed(id: int) -> void:
	Globals.menu_theme.stop()
	Globals.go_to_game(
		"res://src/Game/Game.tscn", {"data": level_data[level_button.level_id]["file"], "ta": true}
	)


func _on_shop_button_pressed() -> void:
	Globals.go_to_with_fade("res://src/Menus/Shop/Shop.tscn")


func _on_back_button_pressed() -> void:
	Globals.go_to_with_fade("res://src/Menus/MainMenu/MainMenu.tscn")
