extends Effect2
class_name BurnEffect

var listener: Listener

func _init():
	super(EventManager.EventType.BeforeCardPlayed, false, Enums.EffectType.Burn, "BurnEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.cards.burn_card(args.specific.play_args.card))

func unregister(event_manager: EventManager):
	listener.disble()

func copy():
	return Listener.new().assign(self)
