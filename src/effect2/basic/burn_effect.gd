extends Effect2
class_name BurnEffect

var listener: Listener

func _init():
	super(EventManager.EventType.BeforeCardPlayed, false, Enums.EffectType.Burn, "BurnEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.cards.burn_played_card())
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return "[color=gold]Burn[/color]"

func copy():
	return BurnEffect.new().assign(self)
