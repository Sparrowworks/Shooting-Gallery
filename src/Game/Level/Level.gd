class_name Level extends Resource

@export var level_title: String = "Duck Hunt"
@export var level_id: String = "duck"
@export var game_theme: AudioStream

@export_enum("Water: 1", "Grass: 2") var background_type: int = 1

@export var rank_scores: Array[int] = [0, 500, 1000, 2000, 5000]

@export var ta_rank_scores: Array[int] = [300, 240, 180, 140, 120]

@export var ta_score: int = 50000

@export var scripts: Array[PackedScene] = []
