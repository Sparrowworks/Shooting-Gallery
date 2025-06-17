extends Control

@onready var firerate_button: ShopButton = %FirerateButton
@onready var ammo_button: ShopButton = %AmmoButton
@onready var reload_button: ShopButton = %ReloadButton
@onready var money_text: Label = %MoneyText

@onready var message_panel: MessagePanel = $MessagePanel

var base_prices: Dictionary[String, int] = {"firerate": 100, "ammo": 125, "reload": 150}

var boost_prices: Dictionary[String, int] = {"firerate": 125, "ammo": 150, "reload": 200}


func _ready() -> void:
	money_text.text = str(Globals.money_amount)

	firerate_button.level = Globals.weapon_upgrades["firerate"]
	ammo_button.level = Globals.weapon_upgrades["ammo"]
	reload_button.level = Globals.weapon_upgrades["reload"]

	firerate_button.price = (
		base_prices["firerate"] + (firerate_button.level * boost_prices["firerate"])
	)
	ammo_button.price = base_prices["ammo"] + (ammo_button.level * boost_prices["ammo"])
	reload_button.price = base_prices["reload"] + (reload_button.level * boost_prices["reload"])


func _on_shop_button_buy_pressed(button: ShopButton) -> void:
	if Globals.money_amount < button.price:
		$Fail.play()
		message_panel.show_message("No Cash", "You don't have enough cash to buy this upgrade!")
		return

	$Buy.play()
	if button.money_particles.emitting:
		button.money_particles.restart()
	else:
		button.money_particles.emitting = true

	var id: String = button.upgrade_id

	Globals.money_amount -= button.price
	Globals.weapon_upgrades[id] += 1

	button.level = Globals.weapon_upgrades[id]
	button.price = base_prices[id] + (button.level * boost_prices[id])
	money_text.text = str(Globals.money_amount)

	Globals.save_data()


func _on_back_button_pressed() -> void:
	Globals.save_data()

	Globals.go_to_with_fade("res://src/Menus/LevelSelect/LevelSelect.tscn")
