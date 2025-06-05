extends Structure
class_name ImperfectTourmaline

var callback: Callable

var event_type = EventManager.EventType.BeforeTurnStart

func _init():
	super()

func copy():
	var copy = ImperfectTourmaline.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		var all_tiles = args.farm.get_all_tiles()
		var adjacent_tiles: Array[Tile] = []
		for t in all_tiles:
			if Helper.is_adjacent(t.grid_location, tile.grid_location)\
				and t.state == Enums.TileState.Growing:
				adjacent_tiles.append(t)
		for atile in adjacent_tiles:
			await atile.grow_one_week()
		tile.play_effect_particles()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
