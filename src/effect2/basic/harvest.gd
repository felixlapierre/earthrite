extends Effect2
class_name HarvestEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Harvest, "Harvest")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.tile.harvest(false)
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return "Harvest " + str(size) + " tile(s)"

func get_type():
	return Enums.EffectType.Harvest

func copy():
	var copy = HarvestEffect.new()
	copy.assign(self)
	return copy
