extends Structure
class_name FrostTotem

var callback: Callable
var callback2: Callable

var event_type = EventManager.EventType.BeforeTurnStart
var event_type2 = EventManager.EventType.BeforeGrow

var card: CardBase

func _init():
	super()

func copy():
	var copy = FrostTotem.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		for card: CardBase in args.cards.HAND_CARDS.get_children():
			card.frozen = false
	callback2 = func(args: EventArgs):
		for card: CardBase in args.cards.HAND_CARDS.get_children():
			if !card.card_info.has_effect(Enums.EffectType.Frozen) and !card.frozen:
				card.frozen = true
				tile.play_effect_particles()
				return
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(event_type2, callback2)
	
func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
	event_manager.register_listener(event_type2, callback2)
