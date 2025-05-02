extends CustomEvent

func _init():
	super._init("Blight Offering", "You see visions of a beautiful tapestry of purple thorns and blood-gorged roots. The Blight offers you some of its power in hopes that it may convince you to set aside your quest.\n\nIt's an obvious trap, but you could use the blight's power against it, if you dare.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var cards: Array[Node] = []
	var card1 = ShopCard.instantiate()
	card1.card_data = load("res://src/event/unique/blight_rose.tres")
	cards.append(card1)
	var card2 = ShopCard.instantiate()
	card2.card_data = load("res://src/cards/data/unique/dark_visions.tres")
	cards.append(card2)
	var card3 = ShopCard.instantiate()
	card3.card_data = load("res://src/cards/data/unique/bloodrite.tres")
	cards.append(card3)
	
	var option1 = CustomEvent.Option.new("Accept the offering",\
	OptionPreview.instantiate().nodes_preview("Pick one of these three 'Blight' cards to add to your deck", cards), func():
		user_interface._on_upgrade_shop_on_upgrade(Upgrade.new(Upgrade.UpgradeType.GainBlight, "", 20))
		user_interface.pick_cards_event(cards_database.get_element_cards("Blight"))
	)
	var option2 = CustomEvent.Option.new("Reject the offering",\
	OptionPreview.instantiate().text_preview("Remove 20 Blight damage"), func():
		user_interface._on_upgrade_shop_on_upgrade(Upgrade.new(Upgrade.UpgradeType.RemoveBlight, "", 20)))
	return [option1, option2]

func check_prerequisites():
	return turn_manager.blight_damage >= 20 and turn_manager.blight_damage < Global.MAX_HEALTH - 20
