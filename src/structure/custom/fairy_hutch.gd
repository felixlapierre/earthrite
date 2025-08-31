extends Structure
class_name FairyHutch

var callback: Callable
var strength = load("res://src/enhance/data/strength.tres")

var event_type = EventManager.EventType.BeforeTurnStart

var card: CardBase

func _init():
	super()

func copy():
	var copy = FairyHutch.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		var eligible = []
		for card: CardBase in args.cards.HAND_CARDS.get_children():
			if can_strengthen(card.card_info):
				eligible.append(card)
		if eligible.size() == 0:
			return
		eligible.shuffle()
		var chosen = eligible[0]
		var copy: CardData = chosen.card_info.apply_enhance(strength)
		chosen.set_card_info(copy)
		chosen.play_effect_particles()
		tile.play_effect_particles()
	event_manager.register_listener(event_type, callback)

func can_strengthen(card_data):
	if card_data.can_strengthen_custom_effect():
		return true
	for effect in card_data.effects:
		if effect.strength != 0:
			return true
	return false
func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
