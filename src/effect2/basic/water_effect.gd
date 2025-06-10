extends Effect2
class_name WaterEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Water, "WaterEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.tile.irrigate()
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return get_timing_text() + "[color=gold]Water[/color] " + str(size) + " tiles"

func copy():
	return WaterEffect.new().assign(self)
