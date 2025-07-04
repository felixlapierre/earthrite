extends MageAbility
class_name TimeMageFortune

var icon = preload("res://assets/custom/Time32.png")
static var MAGE_NAME = "Lost in Time"
static var MAGE_ID = 3

var event_type = EventManager.EventType.AfterYearStart
var event_callable: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Add Regrow 3 and +1 [img]res://assets/custom/Time32.png[/img] week of grow time to all seeds.\nAdd a 'Time Bubble' to your deck.", MAGE_ID, icon, 3.0)
	modify_deck_callback = func(deck: Array[CardData]):
		deck.append(load("res://src/cards/data/action/time_bubble.tres"))
	str_inc = 2.0

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	update_text()
	event_callable = func(args: EventArgs):
		for card: CardData in args.cards.deck_cards:
			apply_time(card)
		for card: CardData in args.cards.get_hand_info():
			apply_time(card)
		args.cards.update_hand_display()
		if WildernessFarm.WILDERNESS_PLANT != null:
			for tile: Tile in args.farm.get_all_tiles():
				if tile.seed != null and tile.seed.name == WildernessFarm.WILDERNESS_PLANT.name:
					var effect: Effect2 = apply_time(tile.seed)
					tile.seed_grow_time += 1
					effect.owner = tile.seed
					effect.register(event_manager, tile)
					
	event_manager.register_listener(event_type, event_callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, event_callable)

func apply_time(card: CardData):
	if card.type == "SEED":
		card.time += 1
		var regrow = card.has_effect(Enums.EffectType.Regrow)
		if !regrow:
			var effect = load("res://src/effect2/basic/regrow_3.tres")
			card.effects2.append(effect)
			return effect
		else:
			var eff = card.get_effect(Enums.EffectType.Regrow)
			eff.strength += int(strength)
			eff.base_strength += int(strength)


func upgrade_power():
	strength += str_inc
	update_text()

func update_text():
	text = "Add Regrow " + str(strength) + " and +1 [img]res://assets/custom/Time32.png[/img] week of grow time to all seeds.\nAdd a 'Time Bubble' to your deck."
