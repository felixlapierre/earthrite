extends Effect2
class_name WaterUnwateredAdjacent

var my_tile: Tile
var listener: Listener

func _init():
	super(EventManager.EventType.BeforeTurnStart, false, Enums.EffectType.Water)

func register(event_manager: EventManager, tile: Tile):
	my_tile = tile
	listener = Listener.create(self, func(args: EventArgs):
		var candidates = []
		for t in args.farm.get_all_tiles():
			if Helper.is_adjacent(t.grid_location, my_tile.grid_location) and !t.is_watered():
				candidates.append(t)
		var selected: Tile = candidates.pick_random()
		if selected != null:
			selected.irrigate()
		if !my_tile.is_watered():
			my_tile.irrigate())
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return get_timing_text() + "Water an unwatered adjacent tile"

func copy():
	var c = WaterUnwateredAdjacent.new()
	c.assign(self)
	return c
