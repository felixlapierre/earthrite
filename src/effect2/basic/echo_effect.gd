extends Effect2
class_name EchoEffect

var listener: Listener

func _init():
	super(EventManager.EventType.BeforeCardPlayed, false, Enums.EffectType.Echo, "EchoEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var copy: CardData = args.specific.play_args.card.copy()
		if copy.cost == 0:
			copy.cost = 1
		if copy.get_effect("fleeting") == null:
			copy.effects.append(load("res://src/effect/data/fleeting.tres"))
			var burn = copy.effects.filter(func(eff): return eff.name == "burn")
			if burn.size() > 0:
				copy.effects.erase(burn[0])
		args.cards.draw_specific_card_from(copy, args.cards.get_global_mouse_position())
	)

func unregister(event_manager: EventManager):
	listener.disble()

func copy():
	return Listener.new().assign(self)
