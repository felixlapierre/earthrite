extends Effect2
class_name EchoEffect

var listener: Listener

func _init():
	super(EventManager.EventType.AfterCardPlayed, false, Enums.EffectType.Echo, "EchoEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var copy: CardData = args.specific.play_args.card.copy()
		if copy.cost == 0:
			copy.cost = 1
		if !copy.has_effect(Enums.EffectType.Fleeting):
			copy.effects2.append(load("res://src/effect2/basic/data/fleeting_effect.tres"))
			var burn = copy.effects2.filter(func(eff): return eff.name == "BurnEffect")
			if burn.size() > 0:
				copy.effects.erase(burn[0])
		args.cards.draw_specific_card_from(copy, args.cards.get_global_mouse_position())
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return "[color=gold]Echo[/color]"

func copy():
	return EchoEffect.new().assign(self)
