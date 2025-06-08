extends Effect2
class_name FrozenEffect

var listener: Listener

func _init():
	super(EventManager.EventType.BeforeCardPlayed, false, Enums.EffectType.Frozen, "FrozenEffect")

func register(event_manager: EventManager, tile: Tile):
	pass

func unregister(event_manager: EventManager):
	pass

func get_description(size):
	return "[color=gold]Frozen[/color]"

func copy():
	return FrozenEffect.new().assign(self)
