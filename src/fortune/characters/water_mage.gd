extends MageAbility
class_name WaterMage

var icon = preload("res://assets/mage/water_mage.png")
var potion = preload("res://src/cards/data/unique/potion.tres")
var elixir = preload("res://src/cards/data/unique/elixir.tres")
var strength_enhance = preload("res://src/enhance/data/strength.tres")

static var MAGE_NAME = "Alchemist"
static var MAGE_ID = 5

var event_type = EventManager.EventType.OnTileWatered
var callback: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Add a 'Dewdrop' to your deck.\n\nWhenever a tile is Watered, add a Potion to your hand.\n\nIf you already have a Potion in hand, Strengthen it instead.\n\n[color=gold]Unlock:[/color] Win on Normal difficulty or higher", MAGE_ID, icon, 1.0)
	modify_deck_callback = func(deck: Array[CardData]):
		deck.append(load("res://src/cards/data/action/dewdrop.tres"))

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	callback = func(args: EventArgs):
		var already_has_potion = false
		var potion_data = potion if strength == 1.0 else elixir
		for card: CardBase in args.cards.HAND_CARDS.get_children():
			var card_data: CardData = card.card_info
			if card_data.name == potion_data.name:
				already_has_potion = true
				var copy: CardData = card_data.copy().apply_strength(strength_enhance)
				card.set_card_info(copy)
				break
		if !already_has_potion:
			args.cards.draw_specific_card_from(potion_data.copy(), args.specific.tile.grid_location)
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func update_text():
	text = "Whenever a tile is Watered, add " + ("a Potion" if strength == 1.0 else "an Elixir") + " to your hand.\n\nIf you already have a Potion in hand, Strengthen it instead."
