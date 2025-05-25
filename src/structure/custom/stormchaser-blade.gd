extends Effect2
class_name StormchaserBlade

var listener: Listener

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new(timing, func(args: EventArgs):
		var card = args.specific.play_args.card
		if card.cost >= 3 and !args.specific.play_args.external_source:
			args.turn_manager.energy += 2
			args.user_interface.update()
			tile.play_effect_particles()
		)
	
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return "When 3 or more {ENERGY} is spent to play a single card, gain 2 {ENERGY}"

func copy():
	var copy = StormchaserBlade.new()
	copy.assign(self)
	return copy
