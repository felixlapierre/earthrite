extends CardData
class_name Sunflower

var tile: Tile

var callback: Callable
var callback2: Callable
var event_type = EventManager.EventType.AfterGrow

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	callback2 = func(args: EventArgs):
		for t_tile in args.farm.get_all_tiles():
			if Helper.is_adjacent(tile.grid_location, t_tile.grid_location):
				t_tile.protected = true
	event_manager.register_listener(EventManager.EventType.OnPlantPlanted, callback2)
	event_manager.register_listener(event_type, callback2)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.OnPlantPlanted, callback2)
	event_manager.unregister_listener(event_type, callback2)

func copy():
	var new = Sunflower.new();
	new.assign(self)
	return new
