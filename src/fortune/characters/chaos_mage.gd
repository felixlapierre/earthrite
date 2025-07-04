extends MageAbility
class_name ChaosMageFortune

var icon = preload("res://assets/card/wild-magic.png")
var cards_database = preload("res://src/cards/cards_database.gd")
static var MAGE_NAME = "Spawn of Chaos"
static var MAGE_ID = 8

var event_type = EventManager.EventType.BeforeTurnStart
var event_callable: Callable

# Note: UserInterface.start_year() is hardcoded to call the randomize deck function
# at the start of each year if the chaos mage is selected
func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Randomize non-enhanced cards in your deck at the start of each year\n\n[color=gold]Unlock: [/color]Win after embracing chaos", MAGE_ID, icon, 1.0)
	modify_deck_callback = func(deck: Array[CardData]):
		ChaosMageFortune.randomize_deck(deck)

func register_fortune(event_manager: EventManager):
	event_callable = func(args: EventArgs):
		if strength >= 2.0:
			var card: CardData = cards_database.get_random_cards(null, 1)[0]
			var copy = card.copy()
			copy.effects.append(load("res://src/effect/data/fleeting.tres"))
			args.cards.draw_specific_card(copy)
			
	event_manager.register_listener(event_type, event_callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, event_callable)

func upgrade_power():
	strength += 1.0
	update_text()

func update_text():
	if strength >= 2.0:
		text = "Randomize non-enhanced cards in your deck at the start of each year.\n\nTurn Start: Add a random Fleeting card to your hand."
	else:
		text = "Randomize non-enhanced cards in your deck at the start of each year."

static func randomize_deck(deck: Array[CardData]):
	var scythes = []
	var seeds = []
	var actions = []
	for card in DataFetcher.get_all_cards():
		if card.type == "SEED":
			seeds.append(card)
		elif card.has_effect(Enums.EffectType.Harvest):
			scythes.append(card)
		else:
			actions.append(card)
	var new_deck = []
	for card in deck:
		var replacement_card
		if card.enhances.size() > 0 or card.rarity == "unique" or card.rarity == "legendary":
			replacement_card = card
		elif card.type == "SEED":
			replacement_card = seeds[randi_range(0, seeds.size() - 1)]
		elif card.has_effect(Enums.EffectType.Harvest):
			replacement_card = scythes[randi_range(0, scythes.size() - 1)]
		else:
			replacement_card = actions[randi_range(0, actions.size() - 1)]
		new_deck.append(replacement_card)
	deck.clear()
	deck.append_array(new_deck)
