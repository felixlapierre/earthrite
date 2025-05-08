extends Effect2
class_name WaterUnwateredAdjacent

var my_tile: Tile

func register(event_manager: EventManager, tile: Tile):
	my_tile = tile
	callback = func(args: EventArgs):
		var candidates = []
		for t in args.farm.get_all_tiles():
			if Helper.is_adjacent(t.grid_location, my_tile.grid_location) and !t.is_watered():
				candidates.append(t)
		var selected: Tile = candidates.pick_random()
		if selected != null:
			selected.irrigate()
		if !my_tile.is_watered():
			my_tile.irrigate()
	event_manager.register_listener(timing, callback)

func unregister(event_manager: EventManager):
	event_manager.unregister_listener(timing, callback)

func copy():
	var c = WaterUnwateredAdjacent.new()
	c.assign(self)
	return c
