extends Effect2
class_name Pinwheel

var listener: Listener

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new("pinwheel", timing, func(args: EventArgs):
		if args.specific.play_args.card.get_effect("harvest") != null\
			or args.specific.play_args.card.get_effect("harvest_delay") != null:
			if randi_range(0, 100) > 50:
				args.turn_manager.energy += 1
				args.user_interface.update()
		)
	
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	var copy = Pinwheel.new()
	copy.assign(self)
	return copy
