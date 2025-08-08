extends Effect2
class_name GoldenDawn

var listener: Listener

func _init(p_delay = false):
	super(EventManager.EventType.OnPlantHarvest, false, Enums.EffectType.Other, "GoldenDawn")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.harvest_args.purple = false
	)
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return "Convert harvested mana to " + Helper.mana_icon()

func preview_yield(tile: Tile, args: EventArgs.HarvestArgs):
	args.purple = false

func copy():
	var copy = GoldenDawn.new()
	copy.assign(self)
	return copy
