extends Effect2
class_name WatermelonEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnPlantHarvest, true, Enums.EffectType.Water, "Watermelon")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var targets = Helper.get_adjacent_active_tiles(args.specific.tile.grid_location, args.farm)
		for t in targets:
			t.irrigate()
		args.specific.tile.irrigate()
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	return WatermelonEffect.new().assign(self)

func get_description(size):
	return get_timing_text() + "[color=gold]Water[/color] 8 adjacent tiles"
