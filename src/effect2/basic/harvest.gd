extends Effect2
class_name HarvestEffect

var listener: Listener

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new(timing, func(args: EventArgs):
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
	return HarvestEffect.new().assign(self)
