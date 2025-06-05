extends Effect2
class_name Dreamcatcher

var listener: Listener

func _init():
	super(EventManager.EventType.AfterCardPlayed, false, Enums.EffectType.Draw, "Dreamcatcher")

func register_events(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var card = args.specific.play_args.card
		if card.get_effect("burn") != null or card.get_effect("fleeting") != null:
			args.cards.drawcard())
	event_manager.register(listener)

func unregister_events(event_manager: EventManager):
	listener.disable()
	
func get_description(size):
	return "Whenever a Burn or Fleeting card is played, draw a card"

func get_long_description():
	return Helper.get_long_description_type_list([Enums.EffectType.Burn, Enums.EffectType.Fleeting])

func copy():
	var copy = Dreamcatcher.new()
	copy.assign(self)
	return copy
