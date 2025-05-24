extends Effect2
class_name Pinwheel

var listener: Listener

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new(timing, func(args: EventArgs):
		var card = args.specific.play_args.card
		var is_harvest = card.get_effect("harvest") != null or card.get_effect("harvest_delay") != null\
			or card.has_effect(Enums.EffectType.Harvest)
		if is_harvest:
			if randi_range(0, 100) > 50:
				args.turn_manager.energy += 1
				tile.play_effect_particles()
			if randi_range(0, 100) > 50:
				args.cards.drawcard()
				tile.play_effect_particles()
			args.user_interface.update()
		)
	
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return "When you Play a Harvest card, 50% to gain 1 {ENERGY} and 50% chance to draw 1 card"

func copy():
	var copy = Pinwheel.new()
	copy.assign(self)
	return copy
