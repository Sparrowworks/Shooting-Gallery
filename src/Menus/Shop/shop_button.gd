class_name ShopButton extends TextureRect

signal buy_pressed(button: ShopButton)

@onready var upgrade_title: Label = %UpgradeTitle
@onready var level_text: Label = %Upgrade
@onready var price_text: Label = %Price
@onready var money_particles: CPUParticles2D = $MoneyParticles
@onready var icon: TextureRect = $VBoxContainer/HBoxContainer/Icon

@export var title: String = "":
	set(val):
		title = val
		if upgrade_title:
			upgrade_title.text = title + " Upgrade"

@export_enum("zero: 0", "one: 1", "two: 2", "three: 3") var level: int = 0:
	set(val):
		level = val
		if level_text:
			level_text.text = "Current Level: " + str(level) + "/3"

			if level == 3:
				price_text.text = "Max upgrade level reached!"
				icon.hide()
				$VBoxContainer/BuyButton.hide()

@export var price: int = 100:
	set(val):
		price = val
		if price_text and level < 3:
			price_text.text = "Price: " + str(price)

@export var upgrade_id: String = ""


func _ready() -> void:
	upgrade_title.text = title + " Upgrade"
	level_text.text = "Current Level: " + str(level) + "/3"
	price_text.text = "Price: " + str(price)

	if level == 3:
		price_text.text = "Max upgrade level reached!"
		icon.hide()
		$VBoxContainer/BuyButton.hide()


func _on_buy_button_pressed() -> void:
	$VBoxContainer/BuyButton.release_focus()
	buy_pressed.emit(self)
